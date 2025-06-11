import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Product 1', 'price': 20.0, 'quantity': 1},
    {'name': 'Product 2', 'price': 15.0, 'quantity': 2},
    {'name': 'Product 3', 'price': 50.0, 'quantity': 1},
  ];

  double get totalPrice {
    double total = 0;
    for (var item in cartItems) {
      total += item['price'] * item['quantity'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                cartItems.clear();
              });
            },
          ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? Center(
                child: Text(
                  'Your cart is empty.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return CartItemCard(
                    item: cartItems[index],
                    onQuantityChanged: (newQuantity) {
                      setState(() {
                        cartItems[index]['quantity'] = newQuantity;
                      });
                    },
                  );
                },
              ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: RM ${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed:
                    totalPrice > 0
                        ? () {
                          // Navigate to payment screen
                          Navigator.pushNamed(context, '/payment');
                        }
                        : null,
                child: Text('Proceed to Checkout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(int) onQuantityChanged;

  CartItemCard({required this.item, required this.onQuantityChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.shopping_cart, size: 40, color: Colors.blue),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('RM ${item['price'].toStringAsFixed(2)} each'),
                SizedBox(height: 8),
                Text(
                  'Subtotal: RM ${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed:
                      item['quantity'] > 1
                          ? () => onQuantityChanged(item['quantity'] - 1)
                          : null,
                ),
                Text(item['quantity'].toString()),
                IconButton(
                  icon: Icon(Icons.add_circle),
                  onPressed: () => onQuantityChanged(item['quantity'] + 1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
