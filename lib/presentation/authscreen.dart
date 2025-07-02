import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:e_commerce/utils/logger.dart';

/// A screen for user authentication (Login and Sign Up).
/// This is a View in the MVVM pattern. It interacts with use cases provided via the Provider package.
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
    final signUpUseCase = Provider.of<SignUpUseCase>(context, listen: false);
    final signInUseCase = Provider.of<SignInUseCase>(context, listen: false);

    // Basic validation
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Email and password cannot be empty.');
      return;
    }

    if (!_isLogin && _usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty for sign up.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await signInUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        _navigateToHome('Logged in successfully!');
      } else {
        await signUpUseCase(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _usernameController.text.trim(),
        );
        _navigateToHome('Signed up and logged in successfully!');
      }
    } catch (e) {
      appLogger.e('AuthScreen: Authentication failed: $e', error: e);
      _showSnackBar('Authentication failed: ${_getErrorMessage(e)}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Displays a snack bar with the provided message.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  /// Cleans up error message to display in snack bar.
  String _getErrorMessage(dynamic e) {
    return e.toString().contains(']')
        ? e.toString().split(']').last.trim()
        : e.toString();
  }

  /// Navigates to the home route and shows a success snack bar.
  void _navigateToHome(String message) {
    if (mounted) {
      appLogger.i('AuthScreen: User action successful. Navigating to home.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.homeRoute);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green, // Success color
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTitle(),
                const SizedBox(height: 40),
                _buildAuthCard(),
                const SizedBox(height: 24),
                _buildToggleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the title with animation for smoother transitions.
  Widget _buildTitle() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: SizedBox(
        // Use SizedBox to give the Text widget a defined width
        width: double.infinity, // Make it take full available width
        key: ValueKey<bool>(_isLogin),
        child: Text(
          _isLogin ? 'Welcome to 🛍️ LokaLaku!' : 'Create Your Account',
          textAlign: TextAlign.center, // Center the text within its bounds
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  /// Builds the card for text fields and login/signup button.
  Widget _buildAuthCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 25), // Increased gap here
            _buildTextField(
              controller: _passwordController,
              labelText: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            if (!_isLogin) // Show username field only for sign-up
              Column(
                children: [
                  const SizedBox(height: 25), // Added gap before username field
                  _buildTextField(
                    controller: _usernameController,
                    labelText: 'Username',
                    icon: Icons.person,
                  ),
                ],
              ),
            const SizedBox(height: 30), // Gap before submit button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// Builds a submit button for login or signup.
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _authenticate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
      ),
      child:
          _isLoading
              ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
              : Text(
                _isLogin ? 'Login' : 'Sign Up',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }

  /// Builds the text fields for input.
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blueGrey[700]),
        hintStyle: TextStyle(color: Colors.blueGrey[400]),
        filled: true,
        fillColor: Colors.blueGrey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blueGrey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.purpleAccent, width: 2.0),
        ),
        prefixIcon: Icon(icon, color: Colors.blueGrey[600]),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(color: Colors.blueGrey[900], fontSize: 16),
      cursorColor: Colors.purpleAccent,
    );
  }

  /// Toggles between login and signup views.
  Widget _buildToggleButton() {
    return TextButton(
      onPressed:
          _isLoading
              ? null
              : () {
                setState(() {
                  _isLogin = !_isLogin;
                  _emailController.clear();
                  _passwordController.clear();
                  _usernameController.clear();
                });
              },
      style: TextButton.styleFrom(
        foregroundColor: Colors.blueGrey[600],
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      child: Text(
        _isLogin
            ? "Don't have an account? Sign Up"
            : 'Already have an account? Login',
      ),
    );
  }
}
