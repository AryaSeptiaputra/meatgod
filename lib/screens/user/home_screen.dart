import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatgod/widgets/map_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _quantityController = TextEditingController();
  List<QueryDocumentSnapshot> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _quantityController.text = '1'; // Default quantity
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _quantityController.dispose();
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

  // Add order to Firestore
  Future<void> _addOrder(QueryDocumentSnapshot product, int quantity) async {
    try {
      // Calculate total amount
      double price = product['price'];
      double totalAmount = price * quantity;

      // Create order document
      await _firestore.collection('orders').add({
        'orderDate': Timestamp.now(),
        'status': 'pending',
        'totalAmount': totalAmount,
        'items': [
          {
            'name': product['name'],
            'quantity': quantity,
            'price': price,
          }
        ],
        'productId': product.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e')),
        );
      }
    }
  }

  void _showBuyDialog(QueryDocumentSnapshot product) {
    _quantityController.text = '1'; // Reset quantity to 1

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buy Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('Price: \$${product['price']}'),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Quantity: '),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      // Ensure quantity is at least 1
                      if (value.isEmpty || int.parse(value) < 1) {
                        _quantityController.text = '1';
                      }
                      // Force rebuild to update total price
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Total: \$${(product['price'] * int.parse(_quantityController.text)).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get quantity from controller
              int quantity = int.parse(_quantityController.text);

              // Close dialog
              Navigator.of(context).pop();

              // Add order to Firestore
              await _addOrder(product, quantity);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Order'),
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
        actions: [
          // Add Orders button
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/orders');
            },
          ),
        ],
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Map Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: MapCard(), // Use MapCard instead of WeatherCard
            ),
          ),

          // Featured Products Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Our Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Products Grid
          _products.isEmpty
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _calculateCrossAxisCount(context),
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var product = _products[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: product['image'] != null
                                        ? Image.memory(
                                            base64Decode(product['image']),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.image,
                                                        size: 40),
                                          )
                                        : const Icon(Icons.image, size: 40),
                                  ),
                                ),
                              ),

                              // Product Details
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${product['price']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.shopping_cart,
                                              size: 18),
                                          label: const Text('Buy Now',
                                              style: TextStyle(fontSize: 12)),
                                          onPressed: () =>
                                              _showBuyDialog(product),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
