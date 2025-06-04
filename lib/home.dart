import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'card.dart';
import 'proDetails.dart';
import 'catalog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  Map<String, dynamic>? _user;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      setState(() => _user = json.decode(userJson));
    }
  }

  Future<void> _loadData() async {
    try {
      final dio = Dio();
      final productsResponse = await dio.get(
        'https://ib.jamalmoallart.com/api/v1/all/products',
      );
      final categoriesResponse = await dio.get(
        'https://ib.jamalmoallart.com/api/v1/all/categories',
        options: Options(headers: {'Accept': 'application/json'}),
      );

      setState(() {
        _products = productsResponse.data;
        _categories = categoriesResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Home', style: TextStyle(color: Colors.white)),
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
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_user != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Welcome, ${_user!['first_name']}', //${_user!['last_name']}
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.deepPurple[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  // Product Carousel
                  Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: 3,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/img (${index + 1}).jpg',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Dots Indicator
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 12 : 8,
                            height: _currentPage == index ? 12 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.pink[300]
                                  : Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Categories',
                      // style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoryProductsScreen(category: category),
                              ),
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: AssetImage(
                                    'assets/images/img (${3 + index}).jpg',
                                  ),
                                ),
                                Text(category, style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Featured Products
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Featured Products',
                      // style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _products.length > 6 ? 6 : _products.length,
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
                ],
              ),
            ),
    );
  }
}
