import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/presentation/authscreen.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/item_detail_vm.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/testhome.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:e_commerce/presentation/items/item_detail_view.dart';

/// Defines constants for all named routes in the application.
class AppRoutes {
  static const String authRoute = '/';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String itemListRoute = '/items';
  static const String itemDetailRoute = '/item-detail'; // New route
  static const String cartRoute = '/cart';
  static const String ordersRoute = '/orders';
}

/// A class that handles all route generation for the application.
class AppRouter {
  /// The [onGenerateRoute] function for [MaterialApp].
  /// This centralizes route handling and ensures the correct page is shown
  /// based on authentication state, making sure it's always within a Navigator context.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Get the current user from Firebase Auth
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;

    // Handle the initial route based on authentication state
    if (settings.name == AppRoutes.authRoute) {
      if (user != null) {
        // User is already logged in, redirect to home screen
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      } else {
        // No user logged in, show authentication screen
        return MaterialPageRoute(builder: (context) => const AuthScreen());
      }
    }

    // Handle other named routes (assuming user is authenticated to reach these)
    switch (settings.name) {
      case AppRoutes.homeRoute:
      // Ensure only authenticated users can access home, otherwise redirect to auth
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const AuthScreen());
        } else {
          return MaterialPageRoute(builder: (context) => const HomeScreen());
        }

      case AppRoutes.profileRoute:
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const AuthScreen());
        }
        return MaterialPageRoute(builder: (context) => const ProfilePage());

    // UPDATED: The itemListRoute case has been removed as requested.

      case AppRoutes.itemDetailRoute:
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const AuthScreen());
        }
        final itemId = settings.arguments as String?;
        if (itemId == null) {
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Error: Item ID is missing')),
            ),
          );
        }
        // Create a page-specific provider for the ItemDetailViewModel
        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => ItemDetailViewModel(
              Provider.of<ItemRepo>(context, listen: false),
              Provider.of<AddItemToCartUseCase>(context, listen: false),
            ),
            child: ItemDetailPage(itemId: itemId),
          ),
        );

      case AppRoutes.cartRoute:
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const AuthScreen());
        }
        return MaterialPageRoute(builder: (context) => const CartPage());

      case AppRoutes.ordersRoute:
        if (user == null) {
          return MaterialPageRoute(builder: (context) => const AuthScreen());
        }
        return MaterialPageRoute(builder: (context) => const OrderListPage());

      default:
      // Fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Error: Unknown Route')),
          ),
        );
    }
  }
}