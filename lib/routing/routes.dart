import 'package:flutter/material.dart';
import 'package:e_commerce/presentation/old/cart_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // '/': (context) => const HomeScreen(),
      // '/settings': (context) => const SettingsScreen(),
      // '/profile': (context) => const ProfileScreen(),
      '/cart': (context) =>  CartPage(),
    };
  }
}


// Usage
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       initialRoute: AppRoutes.home,
//       routes: AppRoutes.getRoutes(), // Use the centralized routes
//     );
//   }
// }