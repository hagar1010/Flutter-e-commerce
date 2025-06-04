import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;

  const ProductCard({required this.product, required this.onTap});

  void _showAddedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 50),
            SizedBox(height: 16),
            Text('Item added to cart!'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _addToCart(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];

    // Check if product already exists in cart
    final existingIndex = cart.indexWhere((item) {
      final cartItem = json.decode(item);
      return cartItem['product_id'] == product['id'];
    });

    if (existingIndex >= 0) {
      // Update quantity if product exists
      final existingItem = json.decode(cart[existingIndex]);
      existingItem['quantity'] += 1;
      cart[existingIndex] = json.encode(existingItem);
    } else {
      // Add new item to cart
      final newItem = {
        'product_id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': 1,
        'added_at': DateTime.now().toIso8601String(),
      };
      cart.add(json.encode(newItem));
    }

    await prefs.setStringList('cart', cart);

    _showAddedDialog(context);
    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(SnackBar(content: Text('Added to cart')));
  }

  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Discount Badge
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product['image'] != null
                        ? Image.network(
                            product['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/img (10).jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(Icons.shopping_bag, size: 50),
                            ),
                          ),
                  ),
                  // Discount Badge
                  if (product['discount'] != null && product['discount'] > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${product['discount']}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Name and Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${product['price']}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Add to Cart Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  _addToCart(context);
                },
                icon: const Icon(
                  Icons.add_shopping_cart,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[300],
                  minimumSize: const Size.fromHeight(36),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
