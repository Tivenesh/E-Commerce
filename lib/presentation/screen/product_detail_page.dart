import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_page.dart'; // Assuming this is where your CartPage is located.

class ProductPage extends StatefulWidget {
  final String productId;

  ProductPage({required this.productId});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Map<String, dynamic>? productData;

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  // Fetch product data from Firebase based on productId
  Future<void> _fetchProductData() async {
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.productId)
              .get();
      if (snapshot.exists) {
        setState(() {
          productData = snapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching product data: $e");
    }
  }

  // Add the product to the user's cart (you may want to store this in Firestore or local state)
  Future<void> _addToCart() async {
    if (productData != null) {
      // Logic to add product to the user's cart (Firestore or local storage)
      print("Product added to cart: ${productData?['name']}");
      // Optionally, you can update the Firestore database here
    }
  }

  @override
  Widget build(BuildContext context) {
    if (productData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Details'),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Image.network(
                productData!['image_url'], // Image URL from Firestore
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16),

            // Product Name
            Text(
              productData!['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),

            // Product Price
            Text(
              'RM ${productData!['price'].toString()}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),

            // Product Description
            Text(
              productData!['description'],
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 32),

            // Add to Cart Button
            Center(
              child: ElevatedButton(
                onPressed: _addToCart,
                child: Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Buy Button (Navigates to the Cart Page)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartPage(),
                    ), // Navigate to Cart Page
                  );
                },
                child: Text('Buy Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
