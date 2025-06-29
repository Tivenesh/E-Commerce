// lib/presentation/users/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/utils/logger.dart'; // Import logger
import 'package:e_commerce/presentation/users/profilevm.dart';
import '../../data/services/supabase_image_uploader.dart';

// Renamed from ProfilePage to EditProfilePage
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key}); // Use super.key

  @override
  State<EditProfilePage> createState() => _EditProfilePageState(); // Renamed state class
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Renamed state class
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final SupabaseImageUploader _imageUploader = SupabaseImageUploader();

  // Local state to manage image upload loading
  bool _isImageUploading = false; // Keep this local state here

  // Store the ProfileViewModel instance
  late ProfileViewModel _profileViewModel; // Declare a late variable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileViewModel = Provider.of<ProfileViewModel>(
        context,
        listen: false,
      ); // Initialize here
      _initializeControllers(_profileViewModel);
      _profileViewModel.addListener(_updateControllers);
      // Ensure profile data is fetched for editing if not already loaded
      _profileViewModel.fetchUserProfile();
    });
  }

  void _initializeControllers(ProfileViewModel viewModel) {
    if (viewModel.currentUserProfile != null) {
      _usernameController.text = viewModel.currentUserProfile!.username;
      _addressController.text = viewModel.currentUserProfile!.address ?? '';
      _phoneNumberController.text =
          viewModel.currentUserProfile!.phoneNumber ?? '';
    }
  }

  void _updateControllers() {
    // Check if the widget is still mounted before accessing context or viewModel
    if (!mounted) return;

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
    }
  }

  Future<void> _uploadProfileImage() async {
    setState(() {
      _isImageUploading = true; // Start local loading for image upload
    });

    try {
      final url = await _imageUploader.pickAndUploadImage();

      if (url != null) {
        // Use the stored _profileViewModel instead of Provider.of(context)
        await _profileViewModel.updateProfile(profileImageUrl: url);
        // It's generally safe to use context after an await if the widget is still mounted.
        // However, a mounted check can be added for robustness.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile image updated successfully!'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image upload cancelled or failed.')),
          );
        }
      }
    } catch (e) {
      appLogger.e('Error uploading image: $e'); // Use logger
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
      }
    } finally {
      setState(() {
        _isImageUploading = false; // End local loading
      });
    }
  }

  void _saveProfile() async {
    // Use the stored _profileViewModel instead of Provider.of(context)
    final String? currentImageUrlInViewModel =
        _profileViewModel.currentUserProfile?.profileImageUrl;

    await _profileViewModel.updateProfile(
      username: _usernameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      profileImageUrl: currentImageUrlInViewModel,
    );

    if (mounted) {
      // Check if widget is mounted before showing SnackBar or popping
      if (_profileViewModel.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Pop back to the display page after successful save
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_profileViewModel.errorMessage!)),
        );
      }
    }
  }

  @override
  void dispose() {
    // Use the stored _profileViewModel instance directly
    _profileViewModel.removeListener(_updateControllers);
    _usernameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Very light grey background
      appBar: AppBar(
        title: const Text(
          'Edit Profile', // Changed title to 'Edit Profile'
          style: TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xFF555555)),
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.withAlpha(
              (255 * 0.2).round(),
            ), // Fix deprecated withOpacity
            width: 1,
          ),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          // Combined loading state: either initial data loading or a save operation
          final bool showOverallLoadingOverlay =
              viewModel.isLoading && viewModel.currentUserProfile != null;
          final bool showInitialLoading =
              viewModel.isLoading && viewModel.currentUserProfile == null;

          if (showInitialLoading) {
            // Show full screen loader only if profile data hasn't loaded yet
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
              ),
            );
          }
          if (viewModel.errorMessage != null &&
              viewModel.currentUserProfile == null) {
            // Show error if initial load failed
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed:
                          () => viewModel.fetchUserProfile(), // Retry button
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final String? currentProfileImageUrl =
              viewModel.currentUserProfile?.profileImageUrl;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24.0, 32.0, 24.0, 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap:
                            _isImageUploading
                                ? null
                                : _uploadProfileImage, // Disable tap during upload
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 75,
                              backgroundColor: const Color(0xFFE0E0E0),
                              backgroundImage:
                                  currentProfileImageUrl != null &&
                                          currentProfileImageUrl.isNotEmpty
                                      ? NetworkImage(currentProfileImageUrl)
                                      : null,
                              child:
                                  (currentProfileImageUrl == null ||
                                          currentProfileImageUrl.isEmpty)
                                      ? const Icon(
                                        Icons.person_rounded,
                                        size: 75,
                                        color: Color(0xFFB0B0B0),
                                      )
                                      : null,
                            ),
                            // Show a small loader on the avatar during image upload
                            if (_isImageUploading)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6200EE),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    _buildTextField(
                      _usernameController,
                      'Username',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _addressController,
                      'Address',
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _phoneNumberController,
                      'Phone Number',
                      Icons.phone_outlined,
                      TextInputType.phone,
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      // Disable if ViewModel is currently loading (e.g., saving) or if image is uploading
                      onPressed:
                          (viewModel.isLoading || _isImageUploading)
                              ? null
                              : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF6200EE).withOpacity(0.3),
                      ),
                      child:
                          (viewModel.isLoading || _isImageUploading)
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              // Conditional overlay for general loading (e.g., saving other profile details)
              if (showOverallLoadingOverlay && !_isImageUploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
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
        labelStyle: const TextStyle(
          color: Color(0xFF888888),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        prefixIcon: Icon(icon, color: const Color(0xFF888888)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey.withAlpha((255 * 0.3).round()),
            width: 1,
          ), // Fix deprecated withOpacity
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6200EE), width: 2),
        ),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFF333333), fontSize: 16),
      cursorColor: const Color(0xFF6200EE),
    );
  }
}
