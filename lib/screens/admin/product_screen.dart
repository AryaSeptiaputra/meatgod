import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  Uint8List? _imageBytes;
  List<QueryDocumentSnapshot> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    setState(() {
      _products = snapshot.docs;
    });
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
      return;
    }

    try {
      await _firestore.collection('products').add({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'image': base64Encode(_imageBytes!),
      });
      _clearControllers();
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product added')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
    }
  }

  Future<void> _updateProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        if (_imageBytes != null) 'image': base64Encode(_imageBytes!),
      });
      _clearControllers();
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating product: $e')));
    }
  }

  Future<void> _deleteProduct(String id) async {
    try {
      await _firestore.collection('products').doc(id).delete();
      _fetchProducts();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
    }
  }

  void _clearControllers() {
    _nameController.clear();
    _priceController.clear();
    _imageBytes = null;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _showProductDialog({String? productId}) async {
    if (productId != null) {
      var product = _products.firstWhere((product) => product.id == productId);
      _nameController.text = product['name'];
      _priceController.text = product['price'].toString();
      _imageBytes = base64Decode(product['image']);
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(productId == null ? 'Add New Product' : 'Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Product Name')),
              TextField(controller: _priceController, decoration: InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
              ElevatedButton(onPressed: _pickImage, child: Text('Pick Image')),
              if (_imageBytes != null) Image.memory(_imageBytes!, height: 100, fit: BoxFit.cover),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (productId == null) _addProduct();
              else _updateProduct(productId);
              Navigator.of(context).pop();
            },
            child: Text(productId == null ? 'Add Product' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        child: Icon(Icons.add),
        tooltip: 'Add Product',
      ),
      body: _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index];
                return Card(
                  child: InkWell(
                    onTap: () => _showProductDialog(productId: product.id),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.memory(base64Decode(product['image']), fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(product['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${product['price']}', style: TextStyle(color: Colors.green)),
                              Row(
                                children: [
                                  IconButton(onPressed: () => _showProductDialog(productId: product.id), icon: Icon(Icons.edit)),
                                  IconButton(onPressed: () => _deleteProduct(product.id), icon: Icon(Icons.delete)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
