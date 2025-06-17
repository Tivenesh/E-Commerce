import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_commerce/data/usecases/auth/signout.dart';

import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:e_commerce/presentation/sell/sell_items_list_page.dart'; // <--- UPDATED IMPORT

import 'package:e_commerce/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ItemListPage(),
    CartPage(),
    OrderListPage(),
    SellItemsListPage(), // <--- USE THE NEW LIST PAGE HERE
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SignOutUseCase signOutUseCase = Provider.of<SignOutUseCase>(
      context,
      listen: false,
    );

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
              } catch (e) {
                appLogger.e('Error signing out from HomeScreen: $e', error: e);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to sign out: ${e.toString()}'),
                  ),
                );
              }
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Sell',
          ), // This icon stays the same
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
