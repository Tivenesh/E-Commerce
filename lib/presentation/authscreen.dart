import 'package:e_commerce/data/usecases/auth/signin.dart';
import 'package:e_commerce/data/usecases/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// ** FIX: Import your routing file **
import 'package:e_commerce/routing/routes.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  String _email = '';
  String _password = '';
  String _username = '';

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      try {
        if (_isLogin) {
          final signInUseCase = context.read<SignInUseCase>();
          await signInUseCase.call(_email, _password);
        } else {
          final signUpUseCase = context.read<SignUpUseCase>();
          await signUpUseCase.call(_email, _password, _username);
        }
        // On successful login/signup, navigate to the home screen
        if (mounted) {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppRouter.homeRoute); // Use AppRouter here
        }
      } catch (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (!_isLogin)
                      TextFormField(
                        key: const ValueKey('username'),
                        validator: (value) {
                          if (value!.isEmpty || value.length < 4) {
                            return 'Please enter at least 4 characters.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        onSaved: (value) {
                          _username = value!;
                        },
                      ),
                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                      ),
                      onSaved: (value) {
                        _email = value!;
                      },
                    ),
                    TextFormField(
                      key: const ValueKey('password'),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 7) {
                          return 'Password must be at least 7 characters long.';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (value) {
                        _password = value!;
                      },
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: Text(_isLogin ? 'Login' : 'Signup'),
                    ),
                    TextButton(
                      child: Text(
                        _isLogin
                            ? 'Create new account'
                            : 'I already have an account',
                      ),
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
