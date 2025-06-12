import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/presentation/authscreen.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
// import 'package:e_commerce/presentation/items/item_detail_view.dart';
// import 'package:e_commerce/presentation/items/itemlistview.dart';
// import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/seller/seller_dashboard_view.dart';
import 'package:e_commerce/presentation/seller/seller_registration_view.dart';
import 'package:e_commerce/presentation/testhome.dart';
import 'package:e_commerce/presentation/users/edit_profile_view.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

/// A utility class for handling named routes in the application.
class AppRoutes {
  static const String authRoute = '/';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String editProfileRoute = '/edit-profile'; // New Route
  static const String itemListRoute = '/items';
  static const String itemDetailRoute = '/item-detail';
  static const String cartRoute = '/cart';
  static const String orderListRoute = '/orders';
  static const String sellerRegistrationRoute = '/seller-registration';
  static const String sellerDashboardRoute = '/seller-dashboard';

  /// A wrapper to protect routes that require authentication.
  static Widget authGuard(Widget page) {
    return auth.FirebaseAuth.instance.currentUser != null
        ? page
        : const AuthScreen();
  }

  /// Generates routes based on the provided [RouteSettings].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case authRoute:
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      case homeRoute:
        return MaterialPageRoute(builder: (_) => authGuard(const HomeScreen()));

      case profileRoute:
        return MaterialPageRoute(
          builder: (_) => authGuard(const ProfilePage()),
        );

      case editProfileRoute: // New Route Handler
        final user = settings.arguments as User?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (_) => authGuard(const EditProfilePage()),
            settings: settings,
          );
        }
        return _errorRoute('User argument missing for edit profile route.');

      case itemListRoute:
        return MaterialPageRoute(
          builder: (_) => authGuard(const EditProfilePage()),
        );

      case cartRoute:
        return MaterialPageRoute(
          builder: (_) => authGuard(const EditProfilePage()),
        );

      case orderListRoute:
        return MaterialPageRoute(
          builder: (_) => authGuard(const OrderListPage()),
        );

      case itemDetailRoute:
        final itemId = settings.arguments as String?;
        if (itemId != null) {
          return MaterialPageRoute(
            builder: (_) => authGuard(const EditProfilePage()),
          );
        }
        return _errorRoute('Item ID missing for item detail route.');

      case sellerRegistrationRoute:
        final user = settings.arguments as User?;
        if (user != null) {
          return MaterialPageRoute(
            builder: (_) => authGuard(const SellerRegistrationView()),
            settings: settings,
          );
        }
        return _errorRoute('User argument missing for seller registration.');

      case sellerDashboardRoute:
        return MaterialPageRoute(
          builder: (_) => authGuard(const SellerDashboardView()),
        );

      default:
        return _errorRoute('Unknown Route: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder:
          (_) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(message)),
          ),
    );
  }
}
