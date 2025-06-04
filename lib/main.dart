import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/screen/login_page.dart';
import 'presentation/screen/account_details_page.dart';

import './ui/itempage/add_item_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String loginRoute = '/login';
  static const String accountDetailsRoute = '/accountDetails';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: loginRoute, // Starting route
      routes: {
        loginRoute: (context) => const LoginPage(),
        accountDetailsRoute: (context) => const AccountDetailsPage(),
      },
    );
  }
}
