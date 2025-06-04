import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cart = prefs.getStringList('cart') ?? [];

    setState(() {
      _cartItems = cart.map((item) => json.decode(item)).toList();
      _isLoading = false;
    });
  }

  double get _totalPrice {
    return _cartItems.fold(0, (total, item) {
      return total + (item['price'] ?? 0) * item['quantity'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 246, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple[200],
        title: const Text('Your Cart', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.pinkAccent),
            )
          : Column(
              children: [
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Image
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.deepPurple[50],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: item['image'] != null
                                          ? Image.network(
                                              item['image'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/images/img (10).jpg',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                            )
                                          : const Icon(
                                              Icons.shopping_bag,
                                              size: 30,
                                              color: Colors.purple,
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'] ?? 'Product',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: \$${(item['price'])}',
                                            style: TextStyle(
                                              color: Colors.pinkAccent[200],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'Total: \$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: Colors.deepPurple[300],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Quantity: ${item['quantity']}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Quantity + delete buttons
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                              onPressed: () => _updateQuantity(
                                                index,
                                                item['quantity'] - 1,
                                              ),
                                              color: Colors.purple[300],
                                            ),
                                            Text(
                                              item['quantity'].toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                              onPressed: () => _updateQuantity(
                                                index,
                                                item['quantity'] + 1,
                                              ),
                                              color: Colors.pinkAccent[200],
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              _removeFromCart(index),
                                          color: Colors.red[300],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                if (_cartItems.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '\$${_totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent[200],
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Place Order',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity < 1) {
      await _removeFromCart(index);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final updatedItem = {..._cartItems[index], 'quantity': newQuantity};

    setState(() {
      _cartItems[index] = updatedItem;
    });

    await prefs.setStringList(
      'cart',
      _cartItems.map((item) => json.encode(item)).toList(),
    );
  }

  Future<void> _removeFromCart(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _cartItems.removeAt(index));
    await prefs.setStringList(
      'cart',
      _cartItems.map((item) => json.encode(item)).toList(),
    );
  }

  Future<void> _placeOrder() async {
    final prefs = await SharedPreferences.getInstance();

    // Create a local order history
    final orders = prefs.getStringList('orders') ?? [];
    final newOrder = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'items': _cartItems,
      'total': _totalPrice,
      'date': DateTime.now().toIso8601String(),
    };
    orders.add(json.encode(newOrder));
    await prefs.setStringList('orders', orders);

    // Clear the cart
    await prefs.remove('cart');
    setState(() => _cartItems.clear());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order placed successfully (locally)')),
    );

    // Navigate to orders screen if needed
    // Navigator.pushNamed(context, '/orders');
  }
}
