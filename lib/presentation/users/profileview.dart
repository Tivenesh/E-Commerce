import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/users/profilevm.dart';

/// The user profile page (View) for displaying and editing user information.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _profileImageUrlController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current profile data when available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      if (viewModel.currentUserProfile != null) {
        _usernameController.text = viewModel.currentUserProfile!.username;
        _addressController.text = viewModel.currentUserProfile!.address ?? '';
        _phoneNumberController.text =
            viewModel.currentUserProfile!.phoneNumber ?? '';
        _profileImageUrlController.text =
            viewModel.currentUserProfile!.profileImageUrl ?? '';
      }
      // Listen to changes in the profile data
      viewModel.addListener(_updateControllers);
    });
  }

  void _updateControllers() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    if (viewModel.currentUserProfile != null) {
      // Only update if the content has actually changed to avoid cursor jumps
      if (_usernameController.text != viewModel.currentUserProfile!.username) {
        _usernameController.text = viewModel.currentUserProfile!.username;
      }
      if (_addressController.text !=
          (viewModel.currentUserProfile!.address ?? '')) {
        _addressController.text = viewModel.currentUserProfile!.address ?? '';
      }
      if (_phoneNumberController.text !=
          (viewModel.currentUserProfile!.phoneNumber ?? '')) {
        _phoneNumberController.text =
            viewModel.currentUserProfile!.phoneNumber ?? '';
      }
      if (_profileImageUrlController.text !=
          (viewModel.currentUserProfile!.profileImageUrl ?? '')) {
        _profileImageUrlController.text =
            viewModel.currentUserProfile!.profileImageUrl ?? '';
      }
    }
  }

  @override
  void dispose() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.removeListener(_updateControllers);
    _usernameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _profileImageUrlController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.updateProfile(
      username: _usernameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      profileImageUrl: _profileImageUrlController.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          viewModel.errorMessage ?? 'Profile updated successfully!',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          final user = viewModel.currentUserProfile;
          if (user == null) {
            return const Center(child: Text('User profile not available.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        user.profileImageUrl != null &&
                                user.profileImageUrl!.isNotEmpty
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                    child:
                        (user.profileImageUrl == null ||
                                user.profileImageUrl!.isEmpty)
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blueGrey,
                            )
                            : null,
                    backgroundColor: Colors.blueGrey[50],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(_usernameController, 'Username', Icons.person),
                const SizedBox(height: 16),
                _buildTextField(
                  _addressController,
                  'Address',
                  Icons.location_on,
                ),
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
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      viewModel.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(icon),
      ),
      keyboardType: keyboardType,
    );
  }
}
