// lib/presentation/users/profile_display_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/utils/logger.dart'; // Import logger for print replacement
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart'; // Correct import for SellItemVM
import 'package:e_commerce/data/models/item.dart'; // Assuming your Product/Item model
import 'package:e_commerce/presentation/users/edit_profile_page.dart'; // Correct import for EditProfilePage

class ProfileDisplayPage extends StatefulWidget {
  const ProfileDisplayPage({super.key}); // Use super.key

  @override
  State<ProfileDisplayPage> createState() => _ProfileDisplayPageState();
}

class _ProfileDisplayPageState extends State<ProfileDisplayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure user profile is fetched for display
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
      // Use SellItemVM to fetch user's items
      Provider.of<SellItemVM>(context, listen: false).fetchUserItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Very light grey background
      appBar: AppBar(
        title: const Text(
          'My Profile',
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
      body: Consumer2<ProfileViewModel, SellItemVM>(
        // Use SellItemVM here
        builder: (context, profileViewModel, sellItemViewModel, child) {
          // Corrected parameter name
          if (profileViewModel.isLoading &&
              profileViewModel.currentUserProfile == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6200EE)),
              ),
            );
          }
          if (profileViewModel.errorMessage != null &&
              profileViewModel.currentUserProfile == null) {
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
                      profileViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => profileViewModel.fetchUserProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0336FF),
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

          final String? profileImageUrl =
              profileViewModel.currentUserProfile?.profileImageUrl;
          final String username =
              profileViewModel.currentUserProfile?.username ?? 'Guest User';
          final String userEmail =
              profileViewModel.currentUserProfile?.email ??
              'N/A'; // Assuming email is available

          // Access userItems from sellItemViewModel
          final List<Item> userProducts = sellItemViewModel.userItems;
          final bool productsLoading = sellItemViewModel.isLoading;

          return RefreshIndicator(
            // Allow pull-to-refresh
            onRefresh: () async {
              await profileViewModel.fetchUserProfile();
              await sellItemViewModel.fetchUserItems(); // Refresh user products
            },
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensures scrollability even with few items
              slivers: [
                SliverAppBar(
                  expandedHeight:
                      250.0, // Increased height for more carousel-like space
                  floating: true, // App bar floats when scrolling
                  pinned: false, // It disappears when scrolling down fully
                  automaticallyImplyLeading:
                      false, // No back button on a main profile page
                  backgroundColor: const Color(
                    0xFF6200EE,
                  ), // Primary brand color for the header
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient or image (placeholder for now)
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6200EE), Color(0xFFBB86FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Center align content
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.9),
                                backgroundImage:
                                    profileImageUrl != null &&
                                            profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null,
                                child:
                                    (profileImageUrl == null ||
                                            profileImageUrl.isEmpty)
                                        ? Icon(
                                          Icons.person_rounded,
                                          size: 60,
                                          color: Colors.grey[400],
                                        )
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(100, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(50, 0, 0, 0),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Edit Profile Button
                              SizedBox(
                                width:
                                    180, // Slightly wider for better touch target
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const EditProfilePage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF6200EE),
                                  ),
                                  label: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6200EE),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .white, // White background for prominence
                                    foregroundColor: const Color(0xFF6200EE),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.black.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'My Listings', // Section title for products
                      style: TextStyle(
                        fontSize: 20, // Slightly larger title
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver:
                      productsLoading
                          ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF6200EE),
                                  ),
                                ),
                              ),
                            ),
                          )
                          : userProducts.isEmpty
                          ? SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store_outlined,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No products listed yet.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // TODO: Navigate to Add New Product page
                                        appLogger.i(
                                          'Add new product',
                                        ); // Use logger
                                      },
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Color(0xFF6200EE),
                                      ),
                                      label: const Text(
                                        'List New Product',
                                        style: TextStyle(
                                          color: Color(0xFF6200EE),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Color(0xFF6200EE),
                                          width: 1,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columns for products
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio:
                                      0.75, // Adjust as needed for your product card size
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = userProducts[index];
                              return ProductGridItem(
                                item: item,
                              ); // Custom widget for product display
                            }, childCount: userProducts.length),
                          ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 50), // Padding at bottom
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Dummy ProductGridItem widget - replace with your actual product card
class ProductGridItem extends StatelessWidget {
  final Item item; // Your Item model

  const ProductGridItem({super.key, required this.item}); // Use super.key

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4, // Increased elevation for a lifted look
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ), // More rounded corners
      clipBehavior: Clip.antiAlias, // Ensures image respects border radius
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200], // Placeholder background
              child:
                  item.imageUrls.isNotEmpty
                      ? Image.network(
                        item.imageUrls.first, // Accessing the first image URL
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color:
                                    Colors
                                        .grey[400], // Lighter grey for placeholder
                              ),
                            ),
                      )
                      : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0), // Slightly more padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // Slightly larger font
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6), // More space
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14, // Slightly larger font
                    color: Color(0xFF6200EE), // Brand color for price
                    fontWeight: FontWeight.w700, // Bolder price
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
