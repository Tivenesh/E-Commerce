import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart'), backgroundColor: Colors.blue),
      body: Center(
        child: Text("This is the cart page. Display the user's cart here."),
      ),
    );
  }
}
