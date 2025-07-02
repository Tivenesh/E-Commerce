import 'package:flutter/material.dart';

/// A beautifully designed Seller Page showcasing various UI elements.
/// This page is purely for demonstration purposes and does not contain any
/// business logic or backend integration. It focuses on presenting a clean,
/// intuitive, and visually appealing interface for a seller dashboard.
class SellerPage extends StatefulWidget {
  const SellerPage({super.key});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

/// The state for the SellerPage, managing its UI elements and animations.
class _SellerPageState extends State<SellerPage>
    with SingleTickerProviderStateMixin {
  // Animation controller for subtle UI animations, like fading in elements.
  late AnimationController _animationController;
  // Animation for opacity, to create a fade-in effect for the content.
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a duration of 1 second.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    // Define the fade-in animation from 0.0 (fully transparent) to 1.0 (fully opaque).
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn, // A smooth ease-in curve for natural appearance.
      ),
    );
    // Start the animation when the widget is initialized.
    _animationController.forward();
  }

  @override
  void dispose() {
    // Dispose the animation controller to prevent memory leaks.
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic visual structure for the material design app.
    return Scaffold(
      // AppBar for the page, featuring a custom title and subtle styling.
      appBar: AppBar(
        title: const Text(
          'My Seller Hub 🚀',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text for contrast.
            letterSpacing: 0.8, // Slightly increased letter spacing for style.
          ),
        ),
        centerTitle: true, // Centers the title in the app bar.
        // A gradient background for the app bar, adding a modern touch.
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFFAB47BC),
              ], // Purple gradient.
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 8, // Adds a shadow below the app bar.
        // Custom shape for the app bar's bottom edge.
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              20,
            ), // Rounded bottom corners for the app bar.
          ),
        ),
      ),
      // The main content area of the page.
      body: FadeTransition(
        opacity:
            _fadeInAnimation, // Apply the fade-in animation to the entire body.
        child: SingleChildScrollView(
          // Allows the content to be scrollable if it exceeds screen height.
          padding: const EdgeInsets.all(
            16.0,
          ), // Padding around the entire content.
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align content to the left.
            children: [
              // Section for Quick Actions.
              _buildSectionTitle('Quick Actions ⚡'),
              const SizedBox(height: 12), // Spacing below the title.
              _buildQuickActionsGrid(), // Grid of action buttons.
              const SizedBox(height: 30), // Vertical spacing between sections.
              // Section for Sales Overview.
              _buildSectionTitle('Sales Overview 📊'),
              const SizedBox(height: 12),
              _buildSalesOverviewCard(), // Card displaying sales statistics.
              const SizedBox(height: 30),

              // Section for My Products.
              _buildSectionTitle('My Products 📦'),
              const SizedBox(height: 12),
              _buildMyProductsGrid(), // Grid of listed products.
              const SizedBox(height: 20), // Padding at the bottom of the page.
            ],
          ),
        ),
      ),
      // Floating action button for adding new products.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Placeholder for navigation to Add New Product page.
          // In a real app, this would navigate to a form to create a new product.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Navigating to Add New Product...'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.deepPurpleAccent,
            ),
          );
        },
        icon: const Icon(
          Icons.add_business,
          color: Colors.white,
        ), // Icon for adding business items.
        label: const Text(
          'Add New Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A1B9A), // Matching app bar gradient.
        elevation: 6, // Adds a shadow to the button.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            30,
          ), // Fully rounded corners for the button.
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation
              .centerFloat, // Centers the FAB horizontally.
    );
  }

  /// Helper method to create a standardized section title.
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700, // Semi-bold for section titles.
        color: Color(0xFF333333), // Dark grey for readability.
      ),
    );
  }

  /// Builds a grid of quick action buttons.
  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true, // Makes the grid take only as much space as needed.
      physics:
          const NeverScrollableScrollPhysics(), // Disables scrolling for this inner grid.
      crossAxisCount: 2, // Two columns for the action buttons.
      childAspectRatio: 2.5, // Aspect ratio to make buttons wider.
      mainAxisSpacing: 10, // Vertical spacing between buttons.
      crossAxisSpacing: 10, // Horizontal spacing between buttons.
      children: [
        _buildActionButton(
          icon: Icons.add_circle_outline,
          label: 'Add Product',
          color: Colors.blueAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Product clicked!'),
                duration: Duration(milliseconds: 800),
                backgroundColor: Colors.blueAccent,
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.list_alt,
          label: 'View Orders',
          color: Colors.orangeAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('View Orders clicked!'),
                duration: Duration(milliseconds: 800),
                backgroundColor: Colors.orangeAccent,
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.analytics_outlined,
          label: 'Analytics',
          color: Colors.greenAccent,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Analytics clicked!'),
                duration: Duration(milliseconds: 800),
                backgroundColor: Colors.greenAccent,
              ),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.settings_outlined,
          label: 'Settings',
          color: Colors.grey,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings clicked!'),
                duration: Duration(milliseconds: 800),
                backgroundColor: Colors.grey,
              ),
            );
          },
        ),
      ],
    );
  }

  /// Helper method to create a styled action button.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        15,
      ), // Rounded corners for the tap effect.
      child: Card(
        elevation: 4, // Subtle shadow for the card.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Rounded card corners.
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(
              0.1,
            ), // Light background color based on accent.
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 1,
            ), // Subtle border.
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color), // Icon with accent color.
              const SizedBox(height: 4), // Spacing between icon and text.
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.darken(
                    0.2,
                  ), // Slightly darker text color for contrast.
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card displaying dummy sales overview statistics.
  Widget _buildSalesOverviewCard() {
    return Card(
      elevation: 6, // More prominent shadow for this card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners.
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          20.0,
        ), // Generous padding inside the card.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the sales overview.
            const Text(
              'Your Performance At A Glance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const Divider(
              height: 20,
              thickness: 1,
            ), // A divider for separation.
            // Row for total sales.
            _buildStatRow(
              icon: Icons.monetization_on_outlined,
              label: 'Total Sales',
              value: 'RM 12,345.67', // Dummy sales value.
              color: Colors.green[700]!,
            ),
            const SizedBox(height: 10), // Spacing between stats.
            // Row for pending orders.
            _buildStatRow(
              icon: Icons.pending_actions,
              label: 'Pending Orders',
              value: '15', // Dummy pending orders count.
              color: Colors.orange[700]!,
            ),
            const SizedBox(height: 10),
            // Row for total products listed.
            _buildStatRow(
              icon: Icons.inventory_2_outlined,
              label: 'Products Listed',
              value: '78', // Dummy product count.
              color: Colors.blue[700]!,
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to create a row for displaying a single statistic.
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28), // Icon for the statistic.
        const SizedBox(width: 12), // Spacing between icon and text.
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color, // Value color matching the icon.
          ),
        ),
      ],
    );
  }

  /// Builds a grid of dummy product items.
  Widget _buildMyProductsGrid() {
    // Dummy list of product data. In a real app, this would come from a ViewModel.
    final List<Map<String, dynamic>> dummyProducts = [
      {
        'name': 'Vintage Leather Bag',
        'price': 120.00,
        'imageUrl': 'https://placehold.co/300x300/E0E0E0/424242?text=Bag',
      },
      {
        'name': 'Handmade Ceramic Mug',
        'price': 25.50,
        'imageUrl': 'https://placehold.co/300x300/E0E0E0/424242?text=Mug',
      },
      {
        'name': 'Organic Cotton T-Shirt',
        'price': 45.00,
        'imageUrl': 'https://placehold.co/300x300/E0E0E0/424242?text=T-Shirt',
      },
      {
        'name': 'Minimalist Desk Lamp',
        'price': 88.99,
        'imageUrl': 'https://placehold.co/300x300/E0E0E0/424242?text=Lamp',
      },
      {
        'name': 'Artisanal Soap Set',
        'price': 30.00,
        'imageUrl': 'https://placehold.co/300x300/E0E0E0/424242?text=Soap',
      },
      {
        'name': 'Bluetooth Headphones',
        'price': 199.99,
        'imageUrl':
            'https://placehold.co/300x300/E0E0E0/424242?text=Headphones',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Disable scrolling for this grid.
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two items per row.
        crossAxisSpacing: 12.0, // Horizontal spacing.
        mainAxisSpacing: 12.0, // Vertical spacing.
        childAspectRatio: 0.7, // Adjust aspect ratio for product cards.
      ),
      itemCount: dummyProducts.length,
      itemBuilder: (context, index) {
        final product = dummyProducts[index];
        return _buildProductGridItem(
          name: product['name'],
          price: product['price'],
          imageUrl: product['imageUrl'],
        );
      },
    );
  }

  /// Helper method to build a single product grid item.
  Widget _buildProductGridItem({
    required String name,
    required double price,
    required String imageUrl,
  }) {
    return Card(
      elevation: 5, // Adds a shadow to the product card.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          15,
        ), // Rounded corners for the card.
      ),
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image.
          Expanded(
            child: Container(
              color: Colors.grey[200], // Placeholder background for image.
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Cover the entire space.
                width: double.infinity, // Take full width.
                // Error builder for network image, showing a broken image icon.
                errorBuilder:
                    (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
              ),
            ),
          ),
          // Product details section.
          Padding(
            padding: const EdgeInsets.all(10.0), // Padding around text.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name.
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1, // Restrict to one line.
                  overflow:
                      TextOverflow.ellipsis, // Add ellipsis if text overflows.
                ),
                const SizedBox(height: 6), // Spacing.
                // Product price.
                Text(
                  'RM${price.toStringAsFixed(2)}', // Format price.
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A1B9A), // Price color matching brand.
                  ),
                ),
                const SizedBox(height: 8), // Spacing before the action buttons.
                // Row of action buttons for each product.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Edit button.
                    SizedBox(
                      height: 30, // Fixed height for the button.
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Edit $name clicked!'),
                              duration: const Duration(milliseconds: 800),
                              backgroundColor: Colors.blueGrey,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blueGrey, // Text color.
                          side: BorderSide(
                            color: Colors.blueGrey.withOpacity(0.7),
                          ), // Border color.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8,
                            ), // Rounded corners.
                          ),
                          padding: EdgeInsets.zero, // No internal padding.
                        ),
                        child: const Text(
                          'Edit',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    // Delete button.
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Delete $name clicked!'),
                              duration: const Duration(milliseconds: 800),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent, // Red background for delete.
                          foregroundColor: Colors.white, // White text.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 16,
                        ), // Delete icon.
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extension to darken a color.
extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
