import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For accessing use cases
import 'package:e_commerce/utils/logger.dart'; // For logging

/// A screen for user authentication (Login and Sign Up).
/// This is a View in the MVVM pattern. It interacts with use cases
/// provided via the Provider package.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLogin = true; // Toggle between login and signup view
  bool _isLoading = false; // To show loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  /// Handles the authentication process (login or sign up) based on _isLogin state.
  void _authenticate() async {
    // Access the use cases from the Provider tree
    final SignUpUseCase signUpUseCase = Provider.of<SignUpUseCase>(context, listen: false);
    final SignInUseCase signInUseCase = Provider.of<SignInUseCase>(context, listen: false);

    setState(() {
      _isLoading = true; // Set loading state
    });

    try {
      if (_isLogin) {
        // Attempt to sign in
        await signInUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // After successful login, navigate to home and replace the current route
        if (mounted) { // Check if widget is still mounted before navigation
          appLogger.i('AuthScreen: User logged in successfully. Navigating to home.');
          Navigator.of(context).pushReplacementNamed(AppRoutes.homeRoute);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully!')),
          );
        }
      } else {
        // Attempt to sign up
        await signUpUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
        // After successful sign up, navigate to home and replace the current route
        if (mounted) { // Check if widget is still mounted before navigation
          appLogger.i('AuthScreen: User signed up successfully. Navigating to home.');
          Navigator.of(context).pushReplacementNamed(AppRoutes.homeRoute);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed up and logged in successfully!')),
          );
        }
      }
    } catch (e) {
      appLogger.e('AuthScreen: Authentication failed: $e', error: e); // Log the error
      // Only show SnackBar if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.toString()}')),
        );
      } else {
        appLogger.w('AuthScreen: Widget no longer mounted after auth error. SnackBar not shown.');
      }
    } finally {
      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _isLoading = false; // Reset loading state
        });
      } else {
        appLogger.w('AuthScreen: Widget no longer mounted in finally block. Skipping setState.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Your Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.blueGrey[700]),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading, // Disable during loading
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !_isLoading, // Disable during loading
              ),
              const SizedBox(height: 16),
              if (!_isLogin) // Show username field only for sign-up
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person),
                  ),
                  enabled: !_isLoading, // Disable during loading
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _authenticate, // Disable button during loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
                    : Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () { // Disable button during loading
                  setState(() {
                    _isLogin = !_isLogin;
                    // Clear fields when toggling
                    _emailController.clear();
                    _passwordController.clear();
                    _usernameController.clear();
                  });
                },
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Login',
                  style: TextStyle(color: Colors.blueGrey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
