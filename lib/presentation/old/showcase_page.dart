// lib/presentation/misc/showcase_page.dart

import 'package:flutter/material.dart';

/// A comprehensive UI showcase page demonstrating various Flutter widgets
/// and design patterns. This page is purely for visual presentation and
/// does not contain any complex business logic or data fetching.
/// It aims to be long and visually appealing with extensive comments.
class ShowcasePage extends StatefulWidget {
  /// Creates a [ShowcasePage].
  ///
  /// The [key] is used for widget identification.
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

/// The state class for [ShowcasePage].
///
/// Manages simple UI-only states like a switch toggle or current carousel index.
class _ShowcasePageState extends State<ShowcasePage> {
  // Controller for the PageView in the image carousel.
  final PageController _imageCarouselController = PageController();
  // Keeps track of the current page index in the image carousel.
  int _currentImageIndex = 0;
  // A simple boolean state for a toggle switch demonstration.
  bool _isFeatureEnabled = false;

  // Static list of image URLs for the carousel. These are placeholder images.
  // In a real application, these would come from a data source.
  final List<String> _carouselImages = [
    'https://placehold.co/600x400/E0F2F7/263238?text=Product+View+1',
    'https://placehold.co/600x400/E0F2F7/263238?text=Product+View+2',
    'https://placehold.co/600x400/E0F2F7/263238?text=Product+View+3',
    'https://placehold.co/600x400/E0F2F7/263238?text=Product+View+4',
  ];

  // Static list of feature items for a grid display.
  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.star, 'title': 'Premium Quality'},
    {'icon': Icons.security, 'title': 'Secure Payments'},
    {'icon': Icons.delivery_dining, 'title': 'Fast Delivery'},
    {'icon': Icons.support_agent, 'title': '24/7 Support'},
    {'icon': Icons.redeem, 'title': 'Exclusive Offers'},
    {'icon': Icons.eco, 'title': 'Eco-Friendly'},
  ];

  // Static list of testimonial data.
  final List<Map<String, String>> _testimonials = [
    {
      'name': 'Alice Smith',
      'quote': 'Absolutely love the products! The quality is unmatched and delivery was super fast. Highly recommend this store!',
      'avatar': 'https://placehold.co/100x100/A7FFEB/004D40?text=AS',
    },
    {
      'name': 'Bob Johnson',
      'quote': 'Fantastic customer service and a great selection of items. Will definitely be a returning customer.',
      'avatar': 'https://placehold.co/100x100/FFCCBC/BF360C?text=BJ',
    },
    {
      'name': 'Charlie Brown',
      'quote': 'The best online shopping experience I\'ve had in a long time. Smooth process from start to finish.',
      'avatar': 'https://placehold.co/100x100/BBDEFB/0D47A1?text=CB',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Add a listener to the PageController to update the current image index
    // when the user scrolls the carousel.
    _imageCarouselController.addListener(() {
      setState(() {
        _currentImageIndex = _imageCarouselController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    // Dispose the PageController to prevent memory leaks.
    _imageCarouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar for the page, providing a title and leading/trailing icons.
      appBar: AppBar(
        title: const Text(
          'Product Showcase',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal, // A pleasant teal color for the AppBar.
        elevation: 8, // Adds a shadow below the AppBar.
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Placeholder for opening a drawer or menu.
            debugPrint('Menu button pressed');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Placeholder for navigating to the cart.
              debugPrint('Cart button pressed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // Placeholder for navigating to favorites.
              debugPrint('Favorites button pressed');
            },
          ),
        ],
      ),
      // The main body of the page, wrapped in a SingleChildScrollView
      // to allow for vertical scrolling of content.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Hero Section / Welcome Banner ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade300, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Discover Your Next Favorite!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          blurRadius: 5.0,
                          color: Colors.black38,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Explore our curated collection of high-quality products and services tailored just for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('Shop Now button pressed');
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 20),
                    label: const Text(
                      'Shop Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent, // Vibrant accent color.
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: Colors.orangeAccent.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30), // Spacing after the hero section.

            // --- Featured Products Section ---
            _buildSectionTitle(context, 'Featured Products'),
            const SizedBox(height: 15),
            SizedBox(
              height: 250, // Fixed height for the horizontal list.
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: 5, // Example: 5 featured products.
                itemBuilder: (context, index) {
                  return _buildFeaturedProductCard(index);
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- Image Carousel Section ---
            _buildSectionTitle(context, 'Image Gallery'),
            const SizedBox(height: 15),
            SizedBox(
              height: 220, // Height for the image carousel.
              child: PageView.builder(
                controller: _imageCarouselController,
                itemCount: _carouselImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _carouselImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Colors.teal,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Page indicator dots for the carousel.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_carouselImages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentImageIndex == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentImageIndex == index ? Colors.teal : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),

            // --- Key Features Section ---
            _buildSectionTitle(context, 'Why Choose Us?'),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                shrinkWrap: true, // Important: allows GridView inside SingleChildScrollView.
                physics: const NeverScrollableScrollPhysics(), // Disables GridView's own scrolling.
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two columns.
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.8, // Adjust aspect ratio for card size.
                ),
                itemCount: _features.length,
                itemBuilder: (context, index) {
                  return _buildFeatureCard(_features[index]['icon']!, _features[index]['title']!);
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- Testimonials Section ---
            _buildSectionTitle(context, 'What Our Customers Say'),
            const SizedBox(height: 15),
            SizedBox(
              height: 200, // Height for the horizontal testimonial list.
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _testimonials.length,
                itemBuilder: (context, index) {
                  return _buildTestimonialCard(
                    _testimonials[index]['name']!,
                    _testimonials[index]['quote']!,
                    _testimonials[index]['avatar']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // --- Call to Action Banner ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orangeAccent.shade100, Colors.deepOrangeAccent.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Ready to Get Started?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Join our community and unlock exclusive benefits today!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () {
                      debugPrint('Join Us button pressed');
                    },
                    icon: const Icon(Icons.person_add, size: 20),
                    label: const Text(
                      'Join Us Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Interactive Elements Section ---
            _buildSectionTitle(context, 'Interactive Elements'),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // A simple switch to demonstrate interactive UI.
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Enable Notifications',
                            style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                          ),
                          Switch.adaptive(
                            value: _isFeatureEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                _isFeatureEnabled = value;
                              });
                              debugPrint('Notifications switched to: $value');
                            },
                            activeColor: Colors.teal,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // A simple text input field.
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Your Email',
                          hintText: 'Enter your email address',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.teal.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.teal, width: 2),
                          ),
                          prefixIcon: const Icon(Icons.email, color: Colors.teal),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (text) {
                          debugPrint('Email input: $text');
                        },
                      ),
                    ),
                  ),
                  // A simple slider.
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Volume Level: ${(_currentSliderValue * 100).round()}%',
                            style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
                          ),
                          Slider(
                            value: _currentSliderValue,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            activeColor: Colors.teal,
                            inactiveColor: Colors.teal.shade100,
                            onChanged: (double value) {
                              setState(() {
                                _currentSliderValue = value;
                              });
                              debugPrint('Slider value: $value');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Footer Section ---
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade900, // Darker color for footer.
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    '© 2025 Awesome Store. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFooterIcon(Icons.facebook, 'Facebook'),
                      const SizedBox(width: 20),
                      _buildFooterIcon(Icons.discord, 'Discord'),
                      const SizedBox(width: 20),
                      _buildFooterIcon(Icons.mail, 'Email'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Privacy Policy | Terms of Service',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A simple state for the slider.
  double _currentSliderValue = 0.5;

  /// Helper method to build a consistent section title.
  ///
  /// Takes the [BuildContext] and the [title] string.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey.shade800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Helper method to build a card for a featured product.
  ///
  /// [index] is used to vary the placeholder image and text.
  Widget _buildFeaturedProductCard(int index) {
    return Container(
      width: 180, // Fixed width for horizontal scrolling.
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image.
            Expanded(
              child: Image.network(
                'https://placehold.co/180x120/CFD8DC/455A64?text=Item+${index + 1}',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Awesome Gadget ${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${(99.99 + index * 10).toStringAsFixed(2)}', // Varying price.
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('Add to cart Gadget ${index + 1}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a card for a key feature.
  ///
  /// Takes an [icon] and a [title] for the feature.
  Widget _buildFeatureCard(IconData icon, String title) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal.shade600),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a testimonial card.
  ///
  /// Displays a [name], [quote], and [avatarUrl] for a customer testimonial.
  Widget _buildTestimonialCard(String name, String quote, String avatarUrl) {
    return Container(
      width: 300, // Fixed width for horizontal scrolling.
      margin: const EdgeInsets.only(right: 15),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(avatarUrl),
                    onBackgroundImageError: (exception, stackTrace) {
                      debugPrint('Error loading avatar: $exception');
                    },
                  ),
                  const SizedBox(width: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Text(
                  '"$quote"',
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to build an icon for the footer.
  ///
  /// Takes an [iconData] and a [tooltip] for the icon.
  Widget _buildFooterIcon(IconData iconData, String tooltip) {
    return IconButton(
      icon: Icon(iconData, color: Colors.white, size: 30),
      tooltip: tooltip,
      onPressed: () {
        debugPrint('$tooltip icon pressed');
      },
    );
  }
}