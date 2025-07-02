// home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:e_commerce/presentation/sell/sell_items_list_page.dart';

import 'package:e_commerce/utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Add a method to change the selected index
  void _goToShopTab() {
    setState(() {
      _selectedIndex = 0; // 0 is the index for the 'Shop' tab (ItemListPage)
    });
  }

  late final List<Widget> _pages; // Make it late final

  @override
  void initState() {
    super.initState();
    // Initialize _pages here, so we can pass the callback to CartPage
    _pages = <Widget>[
      const ItemListPage(),
      CartPage(onStartShopping: _goToShopTab), // Pass the callback here
      const OrderListPage(),
      const SellItemsListPage(),
      const ProfilePage(),
    ];
  }

  // Removed redundancy: now only one title string is needed
  static const String _appBarTitle = '🛍️ LokaLaku';

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
        title: Text(
          _appBarTitle, // Using the single title string
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 120, 205), Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        toolbarHeight: 80, // Increase AppBar height for prominence
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_outlined,
              color: Colors.white, // Ensure icon color matches text
              size: 28, // Slightly larger icon
            ),
            onPressed: () async {
              try {
                await signOutUseCase();
                appLogger.i('User successfully signed out from HomeScreen.');
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(AppRoutes.authRoute);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('You have been logged out.'),
                      backgroundColor:
                          Colors.blueGrey[600], // Consistent snackbar color
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              } catch (e) {
                appLogger.e('Error signing out from HomeScreen: $e', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: Colors.redAccent, // Error color
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8), // Add some spacing
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
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrangeAccent, // Vibrant selected color
        unselectedItemColor: Colors.blueGrey[400], // Softer unselected color
        onTap: _onItemTapped,
        type:
            BottomNavigationBarType
                .fixed, // Ensures all labels are always visible
        backgroundColor: Colors.white, // Explicit background color for nav bar
        elevation: 15, // Add elevation for a lifted effect
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
