import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For accessing signOutUseCase

// Domain Use Cases
import 'package:e_commerce/data/usecases/auth/signout.dart';

// Presentation Layer - Pages
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/users/profileview.dart';

import 'package:e_commerce/utils/logger.dart';

/// The main screen for authenticated users, acting as a navigation shell.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Current selected tab index

  // List of pages to display in the BottomNavigationBar
  static const List<Widget> _pages = <Widget>[
    ItemListPage(), // Displays all items/products
    CartPage(),     // Displays user's cart
    OrderListPage(), // Displays user's orders
    ProfilePage(),  // User profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the SignOutUseCase from the Provider tree
    final SignOutUseCase signOutUseCase = Provider.of<SignOutUseCase>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-commerce Buyer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              try {
                await signOutUseCase();
                appLogger.i('User successfully signed out from HomeScreen.');
                // Firebase Auth StreamBuilder in MyApp will handle navigation
              } catch (e) {
                appLogger.e('Error signing out from HomeScreen: $e', error: e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: _pages.elementAt(_selectedIndex), // Display the selected page
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
