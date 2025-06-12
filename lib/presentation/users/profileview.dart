import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profilevm.dart';
import 'seller_registration_dialog.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Load user profile when the view initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProfileViewModel>().refreshProfile();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<ProfileViewModel>().signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${viewModel.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.clearError();
                      viewModel.refreshProfile();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.currentUserProfile == null) {
            return const Center(child: Text('No user profile found'));
          }

          final user = viewModel.currentUserProfile!;

          return RefreshIndicator(
            onRefresh: viewModel.refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture and Basic Info
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              user.profileImageUrl != null
                                  ? NetworkImage(user.profileImageUrl!)
                                  : null,
                          child:
                              user.profileImageUrl == null
                                  ? Text(
                                    user.fullName?.isNotEmpty == true
                                        ? user.fullName![0].toUpperCase()
                                        : user.username[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 32),
                                  )
                                  : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.fullName ?? user.username,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          user.email,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Status
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Status',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                user.roles.map((role) {
                                  return Chip(
                                    label: Text(role.toUpperCase()),
                                    backgroundColor:
                                        role == 'seller'
                                            ? Colors.green[100]
                                            : Colors.blue[100],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Personal Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow('Username', user.username),
                          if (user.fullName != null)
                            _buildInfoRow('Full Name', user.fullName!),
                          if (user.phoneNumber != null)
                            _buildInfoRow('Phone', user.phoneNumber!),
                          if (user.address != null)
                            _buildInfoRow('Address', user.address!),
                          if (user.gender != null)
                            _buildInfoRow('Gender', user.gender!),
                        ],
                      ),
                    ),
                  ),

                  // Seller Information (if user is a seller)
                  if (user.isSeller) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Business Information',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    _showUpdateSellerDialog(context, user);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (user.businessName != null)
                              _buildInfoRow(
                                'Business Name',
                                user.businessName!,
                              ),
                            if (user.businessAddress != null)
                              _buildInfoRow(
                                'Business Address',
                                user.businessAddress!,
                              ),
                            if (user.businessContactEmail != null)
                              _buildInfoRow(
                                'Business Email',
                                user.businessContactEmail!,
                              ),
                            if (user.businessPhoneNumber != null)
                              _buildInfoRow(
                                'Business Phone',
                                user.businessPhoneNumber!,
                              ),
                            if (user.businessDescription != null)
                              _buildInfoRow(
                                'Description',
                                user.businessDescription!,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (!user.isSeller)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            viewModel.isRegistringSeller
                                ? null
                                : () {
                                  _showSellerRegistrationDialog(context);
                                },
                        icon:
                            viewModel.isRegistringSeller
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.store),
                        label: Text(
                          viewModel.isRegistringSeller
                              ? 'Registering...'
                              : 'Become a Seller',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to edit profile page
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showSellerRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const SellerRegistrationDialog(),
    );
  }

  void _showUpdateSellerDialog(BuildContext context, user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => SellerRegistrationDialog(
            isUpdate: true,
            initialBusinessName: user.businessName,
            initialBusinessAddress: user.businessAddress,
            initialBusinessContactEmail: user.businessContactEmail,
            initialBusinessPhoneNumber: user.businessPhoneNumber,
            initialBusinessDescription: user.businessDescription,
          ),
    );
  }
}
