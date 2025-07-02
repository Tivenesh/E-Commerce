// lib/presentation/users/profileview.dart

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

  bool _isImageUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      _initializeControllers(viewModel);
      viewModel.addListener(_updateControllers);
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
      _isImageUploading = true;
    });

    try {
      final SupabaseImageUploader imageUploader = SupabaseImageUploader();
      final url = await imageUploader.pickAndUploadImage();

      if (url != null) {
        final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
        await viewModel.updateProfile(profileImageUrl: url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully!')),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e'))
        );
      }
    } finally {
      setState(() {
        _isImageUploading = false;
      });
    }
  }

  void _saveProfile() async {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final String? currentImageUrlInViewModel =
        viewModel.currentUserProfile?.profileImageUrl;

    await viewModel.updateProfile(
      username: _usernameController.text.trim(),
      address: _addressController.text.trim(),
      phoneNumber: _phoneNumberController.text.trim(),
      profileImageUrl: currentImageUrlInViewModel,
    );

    if (mounted && viewModel.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else if (mounted) {
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
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, child) {
        final bool showOverallLoadingOverlay =
            viewModel.isLoading && viewModel.currentUserProfile != null;
        final bool showInitialLoading =
            viewModel.isLoading && viewModel.currentUserProfile == null;

        if (showInitialLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6200EE),
              ),
            ),
          );
        }
        if (viewModel.errorMessage != null &&
            viewModel.currentUserProfile == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        () => viewModel.fetchUserProfile(),
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap:
                      _isImageUploading
                          ? null
                          : _uploadProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 75,
                            backgroundColor: const Color(
                              0xFFE0E0E0,
                            ),
                            backgroundImage:
                            currentProfileImageUrl != null &&
                                currentProfileImageUrl.isNotEmpty
                                ? NetworkImage(currentProfileImageUrl)
                                : null,
                            child:
                            (currentProfileImageUrl == null ||
                                currentProfileImageUrl.isEmpty)
                                ? const Icon(
                              Icons
                                  .person_rounded,
                              size: 75,
                              color: Color(
                                0xFFB0B0B0,
                              ),
                            )
                                : null,
                          ),
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
                                // UPDATED: Changed color to orange
                                color: Colors.deepOrangeAccent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(
                                  8.0,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  // UPDATED: Icon is now white
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
                  ),

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
                    onPressed:
                    (viewModel.isLoading || _isImageUploading)
                        ? null
                        : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      // UPDATED: Changed color to orange
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      elevation: 4,
                      // UPDATED: Shadow color to match
                      shadowColor: Colors.deepOrangeAccent.withOpacity(0.3),
                    ),
                    child:
                    (viewModel.isLoading || _isImageUploading)
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth:
                        2.5,
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
            if (showOverallLoadingOverlay &&
                !_isImageUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(
                    0.3,
                  ),
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
        floatingLabelBehavior:
        FloatingLabelBehavior.auto,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF888888),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF6200EE),
            width: 2,
          ),
        ),
      ),
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFF333333),
        fontSize: 16,
      ),
      cursorColor: const Color(0xFF6200EE),
    );
  }
}