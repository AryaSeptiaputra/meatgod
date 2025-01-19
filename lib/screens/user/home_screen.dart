import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatgod/widgets/weather_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  List<QueryDocumentSnapshot> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Fetch products from Firestore
  Future<void> _fetchProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      setState(() {
        _products = snapshot.docs;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  void _showBuyDialog(QueryDocumentSnapshot product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Buy Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product['name']}'),
            SizedBox(height: 6),
            Text('Price: \$${product['price']}'),
            SizedBox(height: 12),
            Text('Are you sure you want to buy this product?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement buy functionality here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchase successful!')),
              );
            },
            child: Text('Buy Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 5;
    if (screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        elevation: 2,
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Weather Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(12), // Reduced padding
              child: WeatherCard(),
            ),
          ),

          // Featured Products Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding
              child: Text(
                'Our Products',
                style: TextStyle(
                  fontSize: 20, // Smaller font size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Products Grid
          _products.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.all(12), // Reduced padding
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12, // Reduced spacing
                      mainAxisSpacing: 12, // Reduced spacing
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var product = _products[index];
                        return Card(
                          elevation: 2, // Reduced elevation
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Smaller radius
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10), // Smaller radius
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: product['image'] != null
                                        ? Image.memory(
                                            base64Decode(product['image']),
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.image, size: 40), // Smaller icon
                                          )
                                        : Icon(Icons.image, size: 40), // Smaller icon
                                  ),
                                ),
                              ),
                              
                              // Product Details
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.all(8), // Reduced padding
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: TextStyle(
                                          fontSize: 14, // Smaller font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '\$${product['price']}',
                                        style: TextStyle(
                                          fontSize: 12, // Smaller font size
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.shopping_cart, size: 18), // Smaller icon
                                          label: Text('Buy Now', style: TextStyle(fontSize: 12)), // Smaller text
                                          onPressed: () => _showBuyDialog(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: _products.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
