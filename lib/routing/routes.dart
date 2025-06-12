import 'package:e_commerce/data/services/item_repo.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/data/usecases/items/add_item_to_cart_usecase.dart';
import 'package:e_commerce/data/usecases/user/upgrade_to_seller_usecase.dart';
import 'package:e_commerce/presentation/authscreen.dart';
import 'package:e_commerce/presentation/carts/cartview.dart';
import 'package:e_commerce/presentation/items/item_detail_vm.dart';
import 'package:e_commerce/presentation/items/itemlistview.dart';
import 'package:e_commerce/presentation/orders/orderlistview.dart';
import 'package:e_commerce/presentation/seller/seller_dashboard_view.dart';
import 'package:e_commerce/presentation/seller/seller_registration_view.dart';
import 'package:e_commerce/presentation/seller/seller_registration_vm.dart';
import 'package:e_commerce/presentation/testhome.dart';
import 'package:e_commerce/presentation/users/profileview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:e_commerce/presentation/items/item_detail_view.dart';

class AppRoutes {
  static const String authRoute = '/';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String itemListRoute = '/items';
  static const String itemDetailRoute = '/item-detail';
  static const String cartRoute = '/cart';
  static const String ordersRoute = '/orders';
  static const String sellerRegistrationRoute = '/seller-registration';
  static const String sellerDashboardRoute = '/seller-dashboard';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final firebase_auth.User? user =
        firebase_auth.FirebaseAuth.instance.currentUser;

    // A small helper to wrap routes that need auth
    Widget authGuard(Widget page) {
      return user != null ? page : const AuthScreen();
    }

    switch (settings.name) {
      case AppRoutes.authRoute:
        return MaterialPageRoute(
          builder:
              (context) =>
                  user != null ? const HomeScreen() : const AuthScreen(),
        );

      case AppRoutes.homeRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const HomeScreen()),
        );

      case AppRoutes.profileRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const ProfilePage()),
        );

      case AppRoutes.itemListRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const ItemListPage()),
        );

      case AppRoutes.itemDetailRoute:
        final itemId = settings.arguments as String?;
        if (itemId == null) {
          return MaterialPageRoute(
            builder:
                (context) => const Scaffold(
                  body: Center(child: Text('Error: Item ID is missing')),
                ),
          );
        }
        return MaterialPageRoute(
          builder:
              (context) => authGuard(
                ChangeNotifierProvider(
                  create:
                      (context) => ItemDetailViewModel(
                        Provider.of<ItemRepo>(context, listen: false),
                        Provider.of<AddItemToCartUseCase>(
                          context,
                          listen: false,
                        ),
                      ),
                  child: ItemDetailPage(itemId: itemId),
                ),
              ),
        );

      case AppRoutes.cartRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const CartPage()),
        );

      case AppRoutes.ordersRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const OrderListPage()),
        );

      case AppRoutes.sellerRegistrationRoute:
        return MaterialPageRoute(
          builder:
              (context) => authGuard(
                ChangeNotifierProvider(
                  create:
                      (context) => SellerRegistrationViewModel(
                        Provider.of<UpgradeToSellerUseCase>(
                          context,
                          listen: false,
                        ),
                        Provider.of<UserRepo>(context, listen: false),
                      ),
                  child: const SellerRegistrationPage(),
                ),
              ),
        );

      case AppRoutes.sellerDashboardRoute:
        return MaterialPageRoute(
          builder: (context) => authGuard(const SellerDashboardView()),
        );

      default:
        return MaterialPageRoute(
          builder:
              (context) => const Scaffold(
                body: Center(child: Text('Error: Unknown Route')),
              ),
        );
    }
  }
}
