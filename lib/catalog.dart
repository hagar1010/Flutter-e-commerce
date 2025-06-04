import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'card.dart';
import 'proDetails.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String category;

  const CategoryProductsScreen({required this.category});

  @override
  _CategoryProductsScreenState createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final dio = Dio();
      final String apiUrl;

      // Determine which API endpoint to use based on category
      if (widget.category.toLowerCase() == 'all') {
        apiUrl = 'https://ib.jamalmoallart.com/api/v1/all/products';
      } else {
        apiUrl =
            'https://ib.jamalmoallart.com/api/v1/products/category/${widget.category}';
      }

      final response = await dio.get(
        apiUrl,
        options: Options(headers: {'Accept': 'application/json'}),
      );

      setState(() {
        _products = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.category == 'all' ? 'All Products' : widget.category,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple[200],
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: IconButton(
              icon: Icon(Icons.search),
              color: Colors.white,
              style: IconButton.styleFrom(
                backgroundColor: Colors.pink[200],
                padding: EdgeInsets.all(5),
              ),
              onPressed: () => showSearch(
                context: context,
                delegate: ProductSearchDelegate(_products),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? Center(child: Text('No products found'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailScreen(product: product),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// Keep your existing ProductSearchDelegate class

class ProductSearchDelegate extends SearchDelegate {
  final List<dynamic> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = '')];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = products
        .where(
          (product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return _buildResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = products
        .where(
          (product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return _buildResults(suggestions);
  }

  Widget _buildResults(List<dynamic> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: product['image_url'] != null
              ? Image.network(product['image_url'], width: 50, height: 50)
              : Icon(Icons.shopping_bag),
          title: Text(product['name']),
          subtitle: Text('\$${product['price']}'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }
}
