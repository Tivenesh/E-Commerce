import 'package:e_commerce/data/models/user.dart' as model_user;
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
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
    // Listen to profile view model to get user role
    final profileViewModel = Provider.of<ProfileViewModel>(context);
    final model_user.User? user = profileViewModel.currentUserProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.isSeller ?? false ? 'E-commerce Seller' : 'E-commerce Buyer',
        ),
        actions: [
          if (user?.isSeller ?? false)
            IconButton(
              icon: const Icon(Icons.dashboard),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.sellerDashboardRoute);
              },
              tooltip: 'Seller Dashboard',
            ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              try {
                await signOutUseCase();
                appLogger.i('User successfully signed out from HomeScreen.');
              } catch (e) {
                appLogger.e('Error signing out from HomeScreen: $e', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                    ),
                  );
                }
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
