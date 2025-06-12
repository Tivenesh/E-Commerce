import 'package:e_commerce/presentation/seller/seller_registration_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  _SellerRegistrationPageState createState() => _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Provider.of<SellerRegistrationViewModel>(context, listen: false)
          .registerAsSeller(
            _businessNameController.text.trim(),
            _businessAddressController.text.trim(),
          )
          .then((_) {
            final viewModel = Provider.of<SellerRegistrationViewModel>(
              context,
              listen: false,
            );
            if (viewModel.isRegistrationSuccessful) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Registration successful! You are now a seller.',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(
                context,
              ).pop(); // Go back to profile page after success
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SellerRegistrationViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Become a Seller')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tell us about your business',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name / Your Store Name',
                ),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Please enter a business name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessAddressController,
                decoration: const InputDecoration(
                  labelText: 'Contact Information / Address',
                ),
                validator:
                    (value) =>
                        value!.isEmpty
                            ? 'Please enter your contact details'
                            : null,
              ),
              const SizedBox(height: 24),
              if (viewModel.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Register as Seller'),
                ),
              if (viewModel.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    viewModel.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
