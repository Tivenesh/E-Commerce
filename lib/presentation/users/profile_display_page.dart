// lib/presentation/users/profile_display_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/utils/logger.dart'; // Import logger for print replacement
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart'; // Correct import for SellItemVM
import 'package:e_commerce/data/models/item.dart'; // Assuming your Product/Item model
import 'package:e_commerce/presentation/users/edit_profile_page.dart'; // Correct import for EditProfilePage

/// A vibrant and interactive page to display the user's profile and their listed products.
/// This page leverages `Provider` for state management, ensuring a reactive UI.
class ProfileDisplayPage extends StatefulWidget {
  // A unique key for this widget, aiding in widget identification and state preservation.
  const ProfileDisplayPage({super.key});

  @override
  State<ProfileDisplayPage> createState() => _ProfileDisplayPageState();
}

/// The private State class for `ProfileDisplayPage`, managing its dynamic content.
/// It handles initial data fetching and updates the UI based on changes in the view models.
class _ProfileDisplayPageState extends State<ProfileDisplayPage> {
  /// Initializes the state of the widget.
  ///
  /// This method is called exactly once for each State object that is created.
  /// It's used here to perform initial data fetching right after the widget is built
  /// and added to the widget tree.
  @override
  void initState() {
    super.initState();
    // Schedule a callback for the end of this frame to ensure the context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch the user's profile information using the ProfileViewModel.
      // `listen: false` is used as we only need to dispatch an action, not rebuild on changes here.
      Provider.of<ProfileViewModel>(context, listen: false).fetchUserProfile();
      // Simultaneously fetch the user's listed items using the SellItemVM.
      Provider.of<SellItemVM>(context, listen: false).fetchUserItems();
    });
  }

  /// Builds the UI for the profile display page.
  ///
  /// This method constructs the visual representation of the page, including
  /// the app bar, user profile header, and a grid of listed products.
  @override
  Widget build(BuildContext context) {
    // The Scaffold provides the basic visual structure for the page.
    return Scaffold(
      // A very light grey background for a clean and modern look.
      backgroundColor: const Color(0xFFF9F9F9),
      // The AppBar at the top of the screen.
      appBar: AppBar(
        // The title of the app bar, styled for prominence.
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Color(0xFF333333), // Dark grey for strong contrast
            fontWeight: FontWeight.bold, // Bold font for emphasis
            fontSize: 20, // Clearly visible title size
          ),
        ),
        centerTitle: true, // Centers the title for a balanced look.
        elevation: 0, // No shadow for a flat, modern design.
        backgroundColor: const Color(
          0xFFFFFFFF,
        ), // White background for the app bar.
        // Custom icon theme for app bar icons.
        iconTheme: const IconThemeData(
          color: Color(0xFF555555),
        ), // Medium grey icons.
        // A subtle border at the bottom of the app bar to separate it from the content.
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.withAlpha(
              (255 * 0.2).round(),
            ), // Using withAlpha for correct opacity
            width: 1, // Thin border for a minimalist feel.
          ),
        ),
      ),
      // `Consumer2` listens to changes from both `ProfileViewModel` and `SellItemVM`
      // to rebuild the UI when their respective states change.
      body: Consumer2<ProfileViewModel, SellItemVM>(
        builder: (context, profileViewModel, sellItemViewModel, child) {
          // Display a loading indicator if the profile is still being fetched
          // and no profile data is yet available.
          if (profileViewModel.isLoading &&
              profileViewModel.currentUserProfile == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6200EE),
                ), // Primary brand color for loader
              ),
            );
          }
          // Display an error message and a retry button if profile fetching failed
          // and no profile data is available.
          if (profileViewModel.errorMessage != null &&
              profileViewModel.currentUserProfile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // An error icon to visually indicate the issue.
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red, // Red color for error
                      size: 48, // Prominent size
                    ),
                    const SizedBox(height: 16), // Spacing below the icon.
                    // The error message, centered and styled in red.
                    Text(
                      profileViewModel.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 24), // Spacing before the button.
                    // A button to retry fetching the user profile.
                    ElevatedButton(
                      onPressed: () => profileViewModel.fetchUserProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF0336FF,
                        ), // A strong blue for action
                        foregroundColor:
                            Colors.white, // White text for contrast
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Slightly rounded corners
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Extract profile details safely using null-aware operators.
          final String? profileImageUrl =
              profileViewModel.currentUserProfile?.profileImageUrl;
          final String username =
              profileViewModel.currentUserProfile?.username ?? 'Guest User';
          final String userEmail =
              profileViewModel.currentUserProfile?.email ??
              'N/A'; // Assuming email is available

          // Access userItems and their loading state from sellItemViewModel.
          final List<Item> userProducts = sellItemViewModel.userItems;
          final bool productsLoading = sellItemViewModel.isLoading;

          // `RefreshIndicator` allows users to pull down to refresh the content.
          return RefreshIndicator(
            onRefresh: () async {
              // Trigger a refresh for both user profile and their listed items.
              await profileViewModel.fetchUserProfile();
              await sellItemViewModel.fetchUserItems();
            },
            // `CustomScrollView` provides a flexible way to create custom scroll effects
            // and combine different types of scrollable widgets.
            child: CustomScrollView(
              // `AlwaysScrollableScrollPhysics` ensures the scroll view can always be scrolled,
              // even if the content is smaller than the viewport.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // `SliverAppBar` for a dynamic and engaging app bar behavior.
                SliverAppBar(
                  expandedHeight:
                      250.0, // Increased height for a more prominent header area.
                  floating:
                      true, // The app bar will float out of view on scroll down.
                  pinned:
                      false, // It will not remain visible when scrolling up.
                  automaticallyImplyLeading:
                      false, // No back button as this is likely a primary navigation page.
                  backgroundColor: const Color(
                    0xFF6200EE,
                  ), // Primary brand color for the header background.
                  elevation: 0, // No shadow for a flat design.
                  // `FlexibleSpaceBar` allows for dynamic content in the app bar.
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background gradient for a modern and appealing visual.
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6200EE),
                                Color(0xFFBB86FC),
                              ], // A purple gradient
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        // Padding for the content within the flexible space.
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center, // Center aligns content horizontally.
                            children: [
                              // Circular avatar for the user's profile picture.
                              CircleAvatar(
                                radius:
                                    60, // Large enough to be clearly visible.
                                backgroundColor: Colors.white.withOpacity(
                                  0.9,
                                ), // Slightly transparent white background.
                                // Conditionally display network image or a default icon.
                                backgroundImage:
                                    profileImageUrl != null &&
                                            profileImageUrl.isNotEmpty
                                        ? NetworkImage(profileImageUrl)
                                        : null,
                                child:
                                    (profileImageUrl == null ||
                                            profileImageUrl.isEmpty)
                                        ? Icon(
                                          Icons
                                              .person_rounded, // Default person icon.
                                          size: 60,
                                          color:
                                              Colors
                                                  .grey[400], // Muted grey for the icon.
                                        )
                                        : null,
                              ),
                              const SizedBox(
                                height: 12,
                              ), // Spacing below the avatar.
                              // User's username, bold and white for readability against the gradient.
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
                                      color: Color.fromARGB(
                                        100,
                                        0,
                                        0,
                                        0,
                                      ), // Subtle shadow for depth.
                                    ),
                                  ],
                                ),
                              ),
                              // User's email, slightly smaller and translucent white.
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.8),
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(
                                        50,
                                        0,
                                        0,
                                        0,
                                      ), // Lighter shadow.
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ), // Spacing before the button.
                              // Edit Profile Button.
                              SizedBox(
                                width:
                                    180, // Slightly wider for better touch target.
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Navigate to the `EditProfilePage` when the button is pressed.
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
                                    color: Color(
                                      0xFF6200EE,
                                    ), // Icon color matching brand primary.
                                  ),
                                  label: const Text(
                                    'Edit Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(
                                        0xFF6200EE,
                                      ), // Text color matching brand primary.
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors
                                            .white, // White background for prominence.
                                    foregroundColor: const Color(0xFF6200EE),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ), // More rounded corners.
                                    ),
                                    elevation: 5, // A noticeable shadow.
                                    shadowColor: Colors.black.withOpacity(
                                      0.2,
                                    ), // Subtle shadow color.
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
                // Padding for the "My Listings" section title.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0, // More vertical space.
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'My Listings', // Section title for products.
                      style: TextStyle(
                        fontSize: 20, // Slightly larger title.
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ),
                ),
                // Sliver section for displaying user products.
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver:
                      // Conditional rendering: show loading, empty state, or product grid.
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
                                    // Icon for empty state.
                                    Icon(
                                      Icons.store_outlined,
                                      size: 80,
                                      color: Colors.grey[400], // Muted grey.
                                    ),
                                    const SizedBox(height: 16),
                                    // Message for empty state.
                                    Text(
                                      'No products listed yet.',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Button to navigate to add new product.
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        // TODO: Implement navigation to Add New Product page.
                                        appLogger.i(
                                          'Add new product',
                                        ); // Use logger for debugging.
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
                                  crossAxisCount: 2, // 2 columns for products.
                                  crossAxisSpacing: 10.0, // Horizontal spacing.
                                  mainAxisSpacing: 10.0, // Vertical spacing.
                                  childAspectRatio:
                                      0.75, // Adjust as needed for your product card size.
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final item = userProducts[index];
                              return ProductGridItem(
                                item: item,
                              ); // Custom widget for product display.
                            }, childCount: userProducts.length),
                          ),
                ),
                // Additional padding at the bottom of the scroll view.
                const SliverToBoxAdapter(
                  child: SizedBox(height: 50), // Provides ample bottom spacing.
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// A custom widget to display a single product within the grid.
///
/// This is a simplified representation and should be replaced with your actual
/// product card design which might include more details, actions, etc.
class ProductGridItem extends StatelessWidget {
  /// The `Item` object containing product details.
  final Item item;

  /// Constructor for `ProductGridItem`.
  const ProductGridItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // A `Card` widget provides a visually distinct container for each product.
    return Card(
      elevation: 4, // Increased elevation for a lifted, more prominent look.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ), // More rounded corners for a modern feel.
      ),
      clipBehavior:
          Clip.antiAlias, // Ensures the image respects the border radius.
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align content to the start.
        children: [
          // Expanded widget to ensure the image takes available space.
          Expanded(
            child: Container(
              color:
                  Colors
                      .grey[200], // Placeholder background for the image area.
              child:
                  // Conditionally display network image or a placeholder icon if no image URL is available.
                  item.imageUrls.isNotEmpty
                      ? Image.network(
                        item.imageUrls.first, // Display the first image.
                        fit: BoxFit.cover, // Cover the entire space.
                        width: double.infinity, // Take full width.
                        // Error builder to show a broken image icon if the image fails to load.
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 40,
                                color:
                                    Colors
                                        .grey[400], // Lighter grey for placeholder.
                              ),
                            ),
                      )
                      : Center(
                        child: Icon(
                          Icons
                              .image_not_supported, // Icon for no image available.
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
            ),
          ),
          // Padding for the product details (name and price).
          Padding(
            padding: const EdgeInsets.all(
              10.0,
            ), // Slightly more padding for better spacing.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name.
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15, // Slightly larger font.
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1, // Restrict to a single line.
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text overflows.
                ),
                const SizedBox(height: 6), // More space between name and price.
                // Product price.
                Text(
                  '\$${item.price.toStringAsFixed(2)}', // Format price to two decimal places.
                  style: const TextStyle(
                    fontSize: 14, // Slightly larger font.
                    color: Color(
                      0xFF6200EE,
                    ), // Brand color for price for emphasis.
                    fontWeight: FontWeight.w700, // Bolder price.
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
