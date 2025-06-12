import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/usecases/user/upgrade_to_seller_usecase.dart';
import 'package:e_commerce/presentation/seller/seller_registration_vm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SellerRegistrationView extends StatelessWidget {
  const SellerRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Assuming the current User object is passed via arguments
    final currentUser = ModalRoute.of(context)!.settings.arguments as User;

    return ChangeNotifierProvider(
      create:
          (context) => SellerRegistrationViewModel(
            upgradeToSellerUseCase: context.read<UpgradeToSellerUseCase>(),
            currentUser: currentUser,
          ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Become a Seller')),
        body: Consumer<SellerRegistrationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isRegistrationSuccessful) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Congratulations!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You are now a seller.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Pop until we get back to the profile screen or home
                        Navigator.of(context).pop();
                      },
                      child: const Text('Go to Dashboard'),
                    ),
                  ],
                ),
              );
            }

            return _RegistrationForm();
          },
        ),
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  @override
  __RegistrationFormState createState() => __RegistrationFormState();
}

class __RegistrationFormState extends State<_RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessDescController = TextEditingController();

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _businessDescController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final viewModel = Provider.of<SellerRegistrationViewModel>(
        context,
        listen: false,
      );
      viewModel.registerAsSeller(
        businessName: _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        businessContactEmail: _businessEmailController.text.trim(),
        businessPhoneNumber: _businessPhoneController.text.trim(),
        businessDescription: _businessDescController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SellerRegistrationViewModel>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Tell us about your business",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name*'),
              validator:
                  (value) =>
                      value!.isEmpty ? 'Please enter your business name' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessAddressController,
              decoration: const InputDecoration(labelText: 'Business Address*'),
              validator:
                  (value) =>
                      value!.isEmpty
                          ? 'Please enter your business address'
                          : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessEmailController,
              decoration: const InputDecoration(
                labelText: 'Business Contact Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessPhoneController,
              decoration: const InputDecoration(
                labelText: 'Business Phone Number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessDescController,
              decoration: const InputDecoration(
                labelText: 'Business Description',
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Register as Seller'),
              ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  viewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
