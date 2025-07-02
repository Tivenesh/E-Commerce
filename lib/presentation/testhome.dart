import 'package:e_commerce/presentation/carts/cartvm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:e_commerce/presentation/sell/sell_items_list_page.dart';
import 'package:e_commerce/utils/logger.dart';

// The HomeScreen is now a StatefulWidget to manage the state of the GlobalKey
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // A GlobalKey is used to uniquely identify the cart icon widget and get its position on the screen for the animation.
  final GlobalKey _cartKey = GlobalKey();

  // A method to programmatically switch to the 'Shop' tab.
  void _goToShopTab() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // The list of pages for the BottomNavigationBar.
  late final List<Widget> _pages;

  // This is the single, correct initState method.
  @override
  void initState() {
    super.initState();
    // We initialize the pages list here.
    // The cartKey is passed to the ItemListPage so the animation knows its destination.
    _pages = <Widget>[
      ItemListPage(cartKey: _cartKey), // Pass the key here
      CartPage(onStartShopping: _goToShopTab),
      const OrderListPage(),
      const SellItemsListPage(),
      const ProfilePage(),
    ];
  }

  static const String _appBarTitle = '🛍️ LokaLaku';

  // This method handles the tap on a BottomNavigationBar item and updates the selected index.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We get the SignOutUseCase from the provider to handle logout.
    final SignOutUseCase signOutUseCase = Provider.of<SignOutUseCase>(context, listen: false);

    return Scaffold(
      // The main AppBar for the application.
      appBar: AppBar(
        title: const Text(
          _appBarTitle,
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
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
        toolbarHeight: 80,
        actions: [
          // The logout button in the AppBar.
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white, size: 28),
            onPressed: () async {
              try {
                await signOutUseCase();
                // After signing out, replace the current screen with the authentication route.
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.authRoute);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('You have been logged out.'),
                      backgroundColor: Colors.blueGrey[600],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                appLogger.e('Error signing out from HomeScreen: $e', error: e);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: Colors.redAccent,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              }
            },
            tooltip: 'Sign Out',
          ),
          const SizedBox(width: 8),
        ],
      ),
      // The body of the Scaffold displays the currently selected page.
      body: Center(child: _pages.elementAt(_selectedIndex)),
      // The BottomNavigationBar for navigating between pages.
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          // UPDATED: The Cart icon is now wrapped with the Badge widget.
          BottomNavigationBarItem(
            icon: Consumer<CartViewModel>(
              builder: (context, cartViewModel, child) {
                // The Badge widget shows a small notification circle with the number of items in the cart.
                return badges.Badge(
                  key: _cartKey, // We assign the GlobalKey here so the animation can find it.
                  badgeContent: Text(
                    cartViewModel.cartItems.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  // The badge is only shown if there are items in the cart.
                  showBadge: cartViewModel.cartItems.isNotEmpty,
                  position: badges.BadgePosition.topEnd(top: -12, end: -12),
                  child: const Icon(Icons.shopping_cart),
                );
              },
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.add_shopping_cart), label: 'Sell'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrangeAccent,
        unselectedItemColor: Colors.blueGrey[400],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 15,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}