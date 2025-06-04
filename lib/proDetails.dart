
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;

  const ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final double price = widget.product['price']?.toDouble() ?? 0.0;
    final double discount = widget.product['discount']?.toDouble() ?? 0.0;
    final double finalPrice = (price - (price * discount / 100)).clamp(
      0,
      price,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product['name'],
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            widget.product['image'] != null
                ? Image.network(
                    widget.product['image'],
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/img (10).jpg',
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: Icon(Icons.shopping_bag, size: 100),
                  ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${finalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink[300],
                        ),
                      ),
                      if (discount > 0) ...[
                        SizedBox(width: 10),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${discount.toStringAsFixed(0)}% OFF',
                            style: TextStyle(color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Category : ${widget.product['category'] ?? 'No category'}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    widget.product['description'] ?? 'No description',
                    style: TextStyle(color: Colors.grey[800]),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Quantity:', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.purple),
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Text('$_quantity', style: TextStyle(fontSize: 16)),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.purple),
                            onPressed: () {
                              setState(() => _quantity++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _addToCart(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[300],
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Add to Cart',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      return cartItem['product_id'] == widget.product['id'];
    });

    if (existingIndex >= 0) {
      // Update quantity if product exists
      final existingItem = json.decode(cart[existingIndex]);
      existingItem['quantity'] += 1;
      cart[existingIndex] = json.encode(existingItem);
    } else {
      // Add new item to cart
      final newItem = {
        'product_id': widget.product['id'],
        'name': widget.product['name'],
        'price': widget.product['price'],
        'image': widget.product['image'],
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
}
