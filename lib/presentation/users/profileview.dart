import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ensure this import is present
import 'package:e_commerce/presentation/users/profilevm.dart';
import '../../data/services/supabase_image_uploader.dart';

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

  // Removed: String? _profileImageUrl;
  // The image URL will now be directly sourced from the ProfileViewModel.

  // Declared and initialized _imageUploader as a class member
  final SupabaseImageUploader _imageUploader = SupabaseImageUploader();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      _initializeControllers(viewModel); // Initial setup of text fields
      viewModel.addListener(_updateControllers); // Listen for ViewModel updates
    });
  }

  void _initializeControllers(ProfileViewModel viewModel) {
    if (viewModel.currentUserProfile != null) {
      _usernameController.text = viewModel.currentUserProfile!.username;
      _addressController.text = viewModel.currentUserProfile!.address ?? '';
      _phoneNumberController.text =
          viewModel.currentUserProfile!.phoneNumber ?? '';
      _profileImageUrlController.text =
          viewModel.currentUserProfile!.profileImageUrl ?? '';
      print(
        'DEBUG ProfilePage: Initializing controllers with URL: ${_profileImageUrlController.text}',
      );
    }
  }

  void _updateControllers() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    if (viewModel.currentUserProfile != null) {
      // Only update if the text in controller is different from ViewModel
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
      // Update the image URL controller and trigger UI rebuild via Consumer
      if (_profileImageUrlController.text !=
          (viewModel.currentUserProfile!.profileImageUrl ?? '')) {
        _profileImageUrlController.text =
            viewModel.currentUserProfile!.profileImageUrl ?? '';
        print(
          'DEBUG ProfilePage: Controllers updated by ViewModel listener. New URL: ${_profileImageUrlController.text}',
        );
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    // Current working implementation using pickAndUploadImage:
    final url = await _imageUploader.pickAndUploadImage();

    print('DEBUG ProfilePage: URL returned from SupabaseImageUploader: $url');

    if (url != null) {
      // Use Provider to get the ViewModel and update the profileImageUrl
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      await viewModel.updateProfile(profileImageUrl: url);
      print(
        'DEBUG ProfilePage: ViewModel updateProfile called with new image URL.',
      );
    } else {
      print(
        'DEBUG ProfilePage: Supabase upload failed, no URL returned to UI.',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload image.')));
    }
  }

  void _saveProfile() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final String? urlToSave =
        _profileImageUrlController.text.trim().isEmpty
            ? null
            : _profileImageUrlController.text.trim();

    print('DEBUG ProfilePage: Calling updateProfile with URL: $urlToSave');
    viewModel.updateProfile(
      username: _usernameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      profileImageUrl: urlToSave,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(viewModel.errorMessage ?? 'Profile update initiated.'),
      ),
    );
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

          // IMPORTANT: Directly use the profileImageUrl from the ViewModel
          final String? currentProfileImageUrl =
              viewModel.currentUserProfile?.profileImageUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _uploadProfileImage,
                    child: CircleAvatar(
                      radius: 60,
                      // Use currentProfileImageUrl from ViewModel for display
                      backgroundImage:
                          currentProfileImageUrl != null &&
                                  currentProfileImageUrl.isNotEmpty
                              ? NetworkImage(currentProfileImageUrl)
                              : null,
                      child:
                          (currentProfileImageUrl == null ||
                                  currentProfileImageUrl.isEmpty)
                              ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.blueGrey,
                              )
                              : null,
                      backgroundColor: Colors.blueGrey[50],
                    ),
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
