import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The user profile page (View) for displaying user information and actions.
/// This is a read-only view. Editing is handled by `EditProfilePage`.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
            onPressed: () {
              // No need for async/await here, the auth stream will handle navigation
              Provider.of<ProfileViewModel>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.currentUser == null) {
            return Center(child: Text(viewModel.errorMessage!));
          }

          final user = viewModel.currentUser;
          if (user == null) {
            return const Center(
              child: Text('Could not load profile. Please try again.'),
            );
          }

          return _buildProfileContent(context, user);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return RefreshIndicator(
      onRefresh: () async {
        // You could add a manual refresh method to the ViewModel if needed
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(context, user),
          const SizedBox(height: 24),
          const Divider(),
          // Conditionally render the 'Become a Seller' button
          if (!user.isSeller) ...[
            _buildSellerRegistrationCard(context, user),
            const Divider(),
          ],
          // Conditionally render the 'Seller Dashboard' button
          if (user.isSeller) ...[
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Seller Dashboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.sellerDashboardRoute);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('My Orders'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.orderListRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to the new Edit Profile page
              // We pass the user to pre-fill the form
              Navigator.of(
                context,
              ).pushNamed(AppRoutes.editProfileRoute, arguments: user);
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage:
              user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
          child:
              (user.profileImageUrl == null || user.profileImageUrl!.isEmpty)
                  ? const Icon(Icons.person, size: 50)
                  : null,
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName ?? user.username,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildSellerRegistrationCard(BuildContext context, User user) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Start Selling Today!",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              "Turn your items into cash. Join our community of sellers.",
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    AppRoutes.sellerRegistrationRoute,
                    arguments: user, // Pass the current user object
                  );
                },
                child: const Text('Become a Seller'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
