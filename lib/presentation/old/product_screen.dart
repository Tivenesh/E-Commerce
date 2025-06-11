// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ProductPage extends StatefulWidget {
//   final String productId;

//   ProductPage({required this.productId});

//   @override
//   _ProductPageState createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   Map<String, dynamic>? productData;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProductData();
//   }

//   // Fetch product data from Firebase based on productId
//   Future<void> _fetchProductData() async {
//     try {
//       DocumentSnapshot snapshot =
//           await FirebaseFirestore.instance
//               .collection('products')
//               .doc(widget.productId)
//               .get();
//       if (snapshot.exists) {
//         setState(() {
//           productData = snapshot.data() as Map<String, dynamic>;
//         });
//       }
//     } catch (e) {
//       print("Error fetching product data: $e");
//     }
//   }

//   // Add the product to the user's cart (simple version)
//   Future<void> _addToCart() async {
//     if (productData != null) {
//       // Here you can add logic to add this product to the user's cart in Firestore
//       print("Product added to cart: ${productData?['name']}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (productData == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Product Details'),
//           backgroundColor: Colors.blue,
//         ),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product Details'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product Image
//             Center(
//               child: Image.network(
//                 productData!['image_url'], // Image URL from Firestore
//                 height: 250,
//                 fit: BoxFit.contain,
//               ),
//             ),
//             SizedBox(height: 16),

//             // Product Name
//             Text(
//               productData!['name'],
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: 8),

//             // Product Price
//             Text(
//               'RM ${productData!['price'].toString()}',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.green,
//               ),
//             ),
//             SizedBox(height: 16),

//             // Product Description
//             Text(
//               productData!['description'],
//               style: TextStyle(fontSize: 16, color: Colors.black87),
//             ),
//             SizedBox(height: 32),

//             // Add to Cart Button
//             Center(
//               child: ElevatedButton(
//                 onPressed: _addToCart,
//                 child: Text('Add to Cart'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor:
//                       Colors.blue, // Corrected to 'backgroundColor'
//                   padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                   textStyle: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_detail_page.dart'; // Assuming this is where your ProductPage is located.

class ProductListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product List'), backgroundColor: Colors.blue),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var products = snapshot.data!.docs;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return ListTile(
                title: Text(product['name']),
                subtitle: Text('RM ${product['price'].toString()}'),
                leading: Image.network(
                  product['image_url'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                onTap: () {
                  // Navigate to the Product Detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductPage(productId: product.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
