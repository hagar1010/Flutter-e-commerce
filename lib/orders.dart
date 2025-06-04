// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// class OrdersScreen extends StatefulWidget {
//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
// }

// class _OrdersScreenState extends State<OrdersScreen> {
//   List<dynamic> _orders = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadOrders();
//   }

//   Future<void> _loadOrders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final orders = prefs.getStringList('orders') ?? [];

//     setState(() {
//       _orders = orders.map((order) => json.decode(order)).toList();
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 255, 238, 255),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.deepPurple[200],
//         title: Text('Your Orders', style: TextStyle(color: Colors.white)),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _orders.isEmpty
//           ? Center(child: Text('No orders yet'))
//           : ListView.builder(
//               itemCount: _orders.length,
//               itemBuilder: (context, index) {
//                 final order = _orders[index];
//                 return Card(
//                   margin: EdgeInsets.all(8),
//                   child: ExpansionTile(
//                     title: Text('Order #${order['id']}'),
//                     subtitle: Text(
//                       '\$${order['total'].toStringAsFixed(2)} - ${DateTime.parse(order['date']).toLocal().toString()}',
//                     ),
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Column(
//                           children: (order['items'] as List).map<Widget>((
//                             item,
//                           ) {
//                             return ListTile(
//                               leading: item['image'] != null
//                                   ? Image.network(
//                                       item['image'],
//                                       width: 40,
//                                       height: 40,
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                             return Image.asset(
//                                               'assets/images/img (10).jpg',
//                                               fit: BoxFit.cover,
//                                             );
//                                           },
//                                     )
//                                   : Icon(Icons.shopping_bag),
//                               title: Text(item['name'] ?? 'Product'),
//                               subtitle: Text(
//                                 'Quantity: ${item['quantity']} - \$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final orders = prefs.getStringList('orders') ?? [];

    setState(() {
      _orders = orders.map((order) => json.decode(order)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color(0xFFFFF1FA),
      backgroundColor: Color.fromARGB(255, 255, 246, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple[200],
        title: Text('Your Orders', style: TextStyle(color: Colors.white)),
        // centerTitle: true,
        elevation: 4,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.white,
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.symmetric(horizontal: 16),
                        title: Text(
                          'Order #${order['id']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                        subtitle: Text(
                          '\$${order['total'].toStringAsFixed(2)} • ${DateTime.parse(order['date']).toLocal().toString().split(".")[0]}',
                          style: TextStyle(
                            color: Colors.purple[200],
                          ),
                        ),
                        children: [
                          Divider(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: (order['items'] as List)
                                  .map<Widget>((item) {
                                return ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 0,
                                  ),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: item['image'] != null
                                        ? Image.network(
                                            item['image'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, _) {
                                              return Image.asset(
                                                'assets/images/img (10).jpg',
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.shopping_bag,
                                            color: Colors.purple[300],
                                          ),
                                  ),
                                  title: Text(
                                    item['name'] ?? 'Product',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Quantity: ${item['quantity']} • \$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.purple[200],
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

