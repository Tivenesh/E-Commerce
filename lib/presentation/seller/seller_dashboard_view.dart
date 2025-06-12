import 'package:flutter/material.dart';

class SellerDashboardView extends StatelessWidget {
  const SellerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Dashboard')),
      body: const Center(
        child: Text('Welcome, Seller! Manage your items and services here.'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to add item/service page
        },
        label: const Text('List Something'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
