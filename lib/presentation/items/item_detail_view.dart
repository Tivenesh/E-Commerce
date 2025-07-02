import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/items/item_detail_vm.dart';
import 'package:e_commerce/data/models/item.dart';

/// The Item Detail Page (View) displays comprehensive information about a single item.
/// It retrieves item details based on the provided [itemId] and allows users
/// to view product images, descriptions, price, stock/duration, and add to cart.
class ItemDetailPage extends StatefulWidget {
  /// The unique identifier of the item to be displayed.
  final String itemId;

  /// Creates an [ItemDetailPage].
  ///
  /// Requires an [itemId] to fetch and display the specific item's details.
  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

/// The state class for [ItemDetailPage].
///
/// Manages the lifecycle and UI updates for the item detail view,
/// interacting with [ItemDetailViewModel] to fetch and present data.
class _ItemDetailPageState extends State<ItemDetailPage> {
  // A PageController to manage the state of the PageView for image carousel.
  // It allows programmatically jumping or animating to specific pages.
  final PageController _pageController = PageController();
  // Keeps track of the currently active image index in the carousel.
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Fetch item details when the page loads, after the first frame is rendered.
    // This ensures the widget context is fully available before triggering data fetch.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ItemDetailViewModel>(
        context,
        listen: false, // Set to false as we only need to call a method, not rebuild on changes here.
      ).fetchItem(widget.itemId);
    });

    // Add a listener to the PageController to update the current page indicator.
    _pageController.addListener(() {
      setState(() {
        // Update _currentPage based on the PageView's current position.
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // Dispose the PageController to release resources when the widget is removed from the tree.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enhanced AppBar with a gradient and more prominent title
      appBar: AppBar(
        title: const Text(
          'Item Details',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        // Using a FlexibleSpace for the AppBar to apply a gradient background.
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 120, 205), Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10, // Adds a shadow below the AppBar.
        iconTheme: const IconThemeData(color: Colors.white), // Ensures back button is white.
      ),
      // Body with a fresh background and animated content
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // This creates the subtle blue-grey gradient background for the entire page.
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        // Consumer widget listens for changes in ItemDetailViewModel and rebuilds its subtree.
        child: Consumer<ItemDetailViewModel>(
          builder: (context, viewModel, child) {
            // Display a loading indicator if data is being fetched and no item is yet loaded.
            if (viewModel.isLoading && viewModel.item == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent), // Visual loading indicator.
                    SizedBox(height: 16),
                    Text(
                      'Fetching item details...',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              );
            }
            // Display an error message if an error occurred during data fetching.
            if (viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline, // Error icon for visual feedback.
                        color: Colors.redAccent,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Oops! ${viewModel.errorMessage!}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please try again later.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }
            // Display a "not found" message if no item is returned and there's no error.
            final item = viewModel.item;
            if (item == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied, // Icon for "item not found".
                      color: Colors.blueGrey,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Item not found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The item you are looking for might not exist.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // If an item is successfully loaded, display its details.
            return SingleChildScrollView(
              // Provides scrolling capability if content overflows.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Image Carousel Section ---
                  // Displays a scrollable carousel of item images.
                  _buildImageCarousel(item.imageUrls),
                  // A row of dots indicating the current image in the carousel.
                  _buildImagePageIndicator(item.imageUrls.length),
                  // Separator for visual distinction.
                  const Divider(color: Colors.transparent, height: 16),

                  // --- Item Details Section ---
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item Name
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Item Price
                        Text(
                          'RM${item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 32,
                            color: Colors.green, // Price highlighted in green.
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Item Type and Category Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.type.toString().split('.').last}: ${item.category}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stock or Duration Information (conditional based on ItemType)
                        if (item.type == ItemType.product)
                        // Displays stock quantity for products.
                          Text(
                            'Stock: ${item.quantity}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // Changes color based on stock availability.
                              color: (item.quantity ?? 0) <= 0
                                  ? Colors.red // Red if out of stock.
                                  : Colors.green[700], // Green if in stock.
                            ),
                          ),
                        if (item.type == ItemType.service)
                        // Displays duration for services.
                          Text(
                            'Duration: ${item.duration}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Decorative Divider
                        const Divider(color: Colors.grey),
                        const SizedBox(height: 16),

                        // --- Description Section ---
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5, // Line height for better readability.
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Additional Details Section (Example: Item ID and Price repetition for emphasis) ---
                        _buildSectionTitle('More Details'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.vpn_key_outlined,
                          label: 'Item ID:',
                          value: item.id,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          icon: Icons.monetization_on_outlined,
                          label: 'Price per unit:',
                          value: 'RM${item.price.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      // Bottom navigation bar for the "Add to Cart" button.
      bottomNavigationBar: _buildAddToCartButton(),
    );
  }

  /// Builds the image carousel section using a [PageView.builder].
  ///
  /// Displays a series of images for the item, handling cases where
  /// no images are available, or where image loading fails.
  Widget _buildImageCarousel(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      // Placeholder if no images are provided.
      return Container(
        height: 280,
        color: Colors.blueGrey[100],
        child: const Center(
          child: Icon(
            Icons.image_not_supported, // Icon for no image.
            size: 100,
            color: Colors.blueGrey,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 16 / 9, // Ensures the carousel maintains a 16:9 aspect ratio.
      child: PageView.builder(
        controller: _pageController, // Connects the PageController.
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            // Adds a subtle animation for scaling when an image is selected.
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // Slightly scale up the current image.
            transform: Matrix4.identity()..scale(_currentPage == index ? 1.05 : 1.0),
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Rounded corners for images.
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover, // Ensures the image covers the area.
                // Error builder for handling image loading failures.
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blueGrey[100],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image, // Icon for broken image.
                        size: 100,
                        color: Colors.blueGrey,
                      ),
                    ),
                  );
                },
                // Loading builder for showing progress while image loads.
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                      // Calculates loading progress if total bytes are known.
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a row of dots indicating the current page in the image carousel.
  /// This provides visual feedback to the user about which image is currently displayed.
  Widget _buildImagePageIndicator(int itemCount) {
    if (itemCount <= 1) return const SizedBox.shrink(); // Hide if only one or no images.

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 8.0, // Wider dot for the current page.
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Colors.purpleAccent // Highlight color for current page.
                : Colors.grey.withOpacity(0.5), // Subtle color for other pages.
            borderRadius: BorderRadius.circular(4.0),
          ),
        );
      }),
    );
  }

  /// Helper widget to create a consistent section title.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.blueGrey,
      ),
    );
  }

  /// Helper widget to create a consistent information row with an icon, label, and value.
  /// This function uses existing properties from the `Item` model where possible.
  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 20),
        const SizedBox(width: 8),
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Builds the "Add to Cart" button, displayed at the bottom of the page.
  ///
  /// This button's state (enabled/disabled, text, and loading indicator)
  /// is dynamically managed based on the item's type, stock, and ViewModel's
  /// loading state.
  Widget _buildAddToCartButton() {
    return Consumer<ItemDetailViewModel>(
      builder: (context, viewModel, child) {
        bool canAddToCart = false;
        // Determine if the item can be added to cart based on its type and stock.
        if (viewModel.item != null) {
          canAddToCart = viewModel.item!.type == ItemType.service ||
              (viewModel.item!.type == ItemType.product &&
                  (viewModel.item!.quantity ?? 0) > 0);
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            // Adds a shadow for a lifted effect.
            // Corrected: Removed the extra 'box' keyword.
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, -5), // Shadow above the container.
              ),
            ],
            // Rounded top corners for a modern look.
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ElevatedButton.icon(
            // Button is enabled only if it can be added to cart and not currently loading.
            onPressed: canAddToCart && !viewModel.isLoading
                ? () async {
                    // Call the ViewModel's addItemToCart method.
                    final success = await viewModel.addItemToCart(1);
                    if (mounted) {
                      // Show a SnackBar notification based on success or failure.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Added ${viewModel.item!.name} to cart!'
                                : viewModel.errorMessage ?? 'Could not add item.',
                          ),
                          duration: const Duration(seconds: 2), // Duration of the SnackBar.
                          backgroundColor: success ? Colors.green[400] : Colors.redAccent,
                          behavior: SnackBarBehavior.floating, // Makes the SnackBar float above content.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10), // Rounded corners for SnackBar.
                          ),
                        ),
                      );
                    }
                  }
                : null, // If onPressed is null, the button is disabled.
            icon:
                // Show a CircularProgressIndicator if currently adding to cart.
                viewModel.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.add_shopping_cart, size: 24), // Default add to cart icon.
            label: Text(
              viewModel.isLoading ? 'Adding to Cart...' : 'Add to Cart',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              // Button color changes based on its enabled state.
              backgroundColor: canAddToCart && !viewModel.isLoading
                  ? Colors.deepOrangeAccent // Active color.
                  : Colors.grey[400], // Disabled color.
              foregroundColor: Colors.white, // Text and icon color.
              minimumSize: const Size.fromHeight(55), // Fixed height for the button.
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Rounded button corners.
              ),
              elevation: 8, // Adds a shadow to the button.
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        );
      },
    );
  }
}