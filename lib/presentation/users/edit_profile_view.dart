import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/presentation/users/profilevm.dart'; // Correct import
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A form for editing the current user's profile details.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _profileImageUrlController;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to access arguments safely after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get the user passed as an argument
      final user = ModalRoute.of(context)!.settings.arguments as User;

      // Initialize controllers with current profile data
      _usernameController = TextEditingController(text: user.username);
      _fullNameController = TextEditingController(text: user.fullName ?? '');
      _addressController = TextEditingController(text: user.address ?? '');
      _phoneNumberController = TextEditingController(
        text: user.phoneNumber ?? '',
      );
      _profileImageUrlController = TextEditingController(
        text: user.profileImageUrl ?? '',
      );
      // We call setState to ensure the UI rebuilds with the initialized controllers
      setState(() {});
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // The error was here. Now it's fixed because ProfileViewModel is a real class.
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      viewModel
          .updateProfile(
            username: _usernameController.text.trim(),
            fullName: _fullNameController.text.trim(),
            address: _addressController.text.trim(),
            phoneNumber: _phoneNumberController.text.trim(),
            profileImageUrl: _profileImageUrlController.text.trim(),
          )
          .then((_) {
            // Check if the widget is still in the tree before showing SnackBar or popping
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully!')),
              );
              Navigator.of(context).pop();
            }
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update profile: $error')),
              );
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We get the view model to check the loading state for the button.
    final viewModel = Provider.of<UserRepo>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildTextField(_usernameController, 'Username', Icons.person),
              const SizedBox(height: 16),
              _buildTextField(_fullNameController, 'Full Name', Icons.badge),
              const SizedBox(height: 16),
              _buildTextField(_addressController, 'Address', Icons.location_on),
              const SizedBox(height: 16),
              _buildTextField(
                _phoneNumberController,
                'Phone Number',
                Icons.phone,
                TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _profileImageUrlController,
                'Profile Image URL',
                Icons.image,
                TextInputType.url,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: viewModel.isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    viewModel.isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (label == 'Username' && (value == null || value.isEmpty)) {
          return 'Username cannot be empty';
        }
        return null;
      },
    );
  }
}
