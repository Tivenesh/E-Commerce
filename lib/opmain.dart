import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/users/profilevm.dart';
import 'presentation/users/profileview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Setup dependency injection
  setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppHome(),
      routes: {
        '/profile':
            (context) => ChangeNotifierProvider(
              create: (context) => getIt<ProfileViewModel>(),
              child: const ProfileView(),
            ),
        // Add other routes as needed
      },
    );
  }
}

class AppHome extends StatelessWidget {
  const AppHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('E-commerce Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to E-commerce App'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: const Text('Go to Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative if you prefer to use the DIContainer approach
class MyAppWithDIContainer extends StatelessWidget {
  const MyAppWithDIContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-commerce App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AppHome(),
      routes: {
        '/profile':
            (context) => ChangeNotifierProvider(
              create: (context) => DIContainer().createProfileViewModel(),
              child: const ProfileView(),
            ),
      },
    );
  }
}
