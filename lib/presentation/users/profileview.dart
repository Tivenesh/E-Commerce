import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final SupabaseImageUploader _imageUploader = SupabaseImageUploader();

  // Local state to manage image upload loading
  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      _initializeControllers(viewModel);
      viewModel.addListener(_updateControllers);
      // Ensure profile data is fetched when the page loads
      viewModel.fetchUserProfile();
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
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    if (viewModel.currentUserProfile != null) {
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
        final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
        // This will set viewModel.isLoading internally if updateProfile does so
        await viewModel.updateProfile(profileImageUrl: url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile image updated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload cancelled or failed.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() {
        _isImageUploading = false; // End local loading
      });
    }
  }

  void _saveProfile() async {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final String? currentImageUrlInViewModel =
        viewModel.currentUserProfile?.profileImageUrl;

    // viewModel.updateProfile will handle its own loading state.
    await viewModel.updateProfile(
      username: _usernameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      profileImageUrl: currentImageUrlInViewModel,
    );

    if (viewModel.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
    }
  }

  @override
  void dispose() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    viewModel.removeListener(_updateControllers);
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
          'My Profile',
          style: TextStyle(
            color: Color(0xFF333333), // Darker grey for primary text
            fontWeight: FontWeight.bold, // Bolder title
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0, // Flat app bar
        backgroundColor: const Color(0xFFFFFFFF), // White app bar
        iconTheme: const IconThemeData(
          color: Color(0xFF555555),
        ), // Medium grey icons
        // Add a subtle bottom border to the app bar
        shape: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
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
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6200EE),
                ), // A common app primary color
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
                padding: const EdgeInsets.fromLTRB(
                  24.0,
                  32.0,
                  24.0,
                  24.0,
                ), // More top padding
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
                              radius: 75, // Slightly larger avatar
                              backgroundColor: const Color(
                                0xFFE0E0E0,
                              ), // Lighter grey for placeholder
                              backgroundImage:
                                  currentProfileImageUrl != null &&
                                          currentProfileImageUrl.isNotEmpty
                                      ? NetworkImage(currentProfileImageUrl)
                                      : null,
                              child:
                                  (currentProfileImageUrl == null ||
                                          currentProfileImageUrl.isEmpty)
                                      ? Icon(
                                        Icons
                                            .person_rounded, // Filled icon for stronger presence
                                        size: 75,
                                        color: const Color(
                                          0xFFB0B0B0,
                                        ), // Softer grey for icon
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
                                  color: const Color(
                                    0xFF6200EE,
                                  ), // Use primary brand color
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ), // Slightly larger tap area
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
                    const SizedBox(
                      height: 40,
                    ), // More spacing for visual breathing room

                    _buildTextField(
                      _usernameController,
                      'Username',
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 20), // Consistent vertical spacing
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

                    const SizedBox(
                      height: 40,
                    ), // Increased spacing before button

                    ElevatedButton(
                      // Disable if ViewModel is currently loading (e.g., saving) or if image is uploading
                      onPressed:
                          (viewModel.isLoading || _isImageUploading)
                              ? null
                              : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF6200EE,
                        ), // Use primary brand color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                        ), // Taller button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Slightly more rounded for a friendly feel
                        ),
                        elevation: 4, // Subtle shadow for depth
                        shadowColor: const Color(
                          0xFF6200EE,
                        ).withOpacity(0.3), // Shadow matching button color
                      ),
                      child:
                          (viewModel.isLoading || _isImageUploading)
                              ? const SizedBox(
                                width: 24, // Larger loader
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth:
                                      2.5, // Slightly thicker progress indicator
                                ),
                              )
                              : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ), // Bolder text
                              ),
                    ),
                    const SizedBox(height: 30), // Bottom padding
                  ],
                ),
              ),
              // Conditional overlay for general loading (e.g., saving other profile details)
              if (showOverallLoadingOverlay &&
                  !_isImageUploading) // Don't show if only image is uploading
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(
                      0.3,
                    ), // Semi-transparent overlay
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
        labelStyle: TextStyle(
          color: const Color(0xFF888888), // Medium grey for labels
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior:
            FloatingLabelBehavior.auto, // Label moves above on focus
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none, // Still no default border
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF), // White fill for text fields
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF888888),
        ), // Match label color
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ), // More internal padding
        enabledBorder: OutlineInputBorder(
          // Subtle border when enabled
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          // Stronger border on focus
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF6200EE),
            width: 2,
          ), // Brand color border on focus
        ),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFF333333), // Dark text for input
        fontSize: 16,
      ),
      cursorColor: const Color(0xFF6200EE), // Cursor matches brand color
    );
  }
}
