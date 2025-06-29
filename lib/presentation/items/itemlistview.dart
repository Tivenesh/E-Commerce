import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:e_commerce/data/models/item.dart'; // For ItemType
import 'package:e_commerce/routing/routes.dart'; // Import for navigation

/// The Item List Page (View) displays all available items and allows searching.
class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // When the page initializes, listen to changes in the search query from the ViewModel
    // and update the text controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ItemListViewModel>(context, listen: false);
      _searchController.addListener(() {
        viewModel.updateSearchQuery(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enhanced AppBar with a gradient and more prominent title
      appBar: AppBar(
        title: const Text(
          '🛍️ LokaLaku',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 255, 120, 205), Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0), // Increased height
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for amazing items...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    30,
                  ), // More rounded corners
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(
                  0.2,
                ), // Semi-transparent fill
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      // Body with a fresh background and animated item list
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<ItemListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      'Fetching awesome products...',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              );
            }
            if (viewModel.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
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
            if (viewModel.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.blueGrey,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No items found matching your search.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Try a different search term!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: viewModel.items.length,
              itemBuilder: (context, index) {
                final item = viewModel.items[index];
                final sellerName = viewModel.getSellerName(item.sellerId);
                return AnimatedOpacity(
                  // Added fade-in animation
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.itemDetailRoute,
                          arguments: item.id,
                        );
                      },
                      child: Card(
                        margin:
                            EdgeInsets
                                .zero, // Remove outer margin as padding is applied
                        elevation:
                            8, // Increased elevation for a floating effect
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // More rounded card
                        ),
                        clipBehavior:
                            Clip.antiAlias, // Ensures content respects border radius
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey[50]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Item Image/Icon with a subtle shadow
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child:
                                        (item.imageUrls.isNotEmpty)
                                            ? Image.network(
                                              item.imageUrls.first,
                                              width: 90,
                                              height: 90,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    color: Colors.blueGrey[100],
                                                    child: const Icon(
                                                      Icons.image_not_supported,
                                                      color: Colors.blueGrey,
                                                      size: 40,
                                                    ),
                                                  ),
                                            )
                                            : Container(
                                              color: Colors.blueGrey[100],
                                              child: Icon(
                                                item.type == ItemType.product
                                                    ? Icons.shopping_bag
                                                    : Icons
                                                        .miscellaneous_services,
                                                color: Colors.blueGrey,
                                                size: 40,
                                              ),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Item Name
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.blueGrey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Seller Name
                                      Text(
                                        'Seller: $sellerName',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      // Item Description
                                      Text(
                                        item.description,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Item Type and Category
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[100],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.type.toString().split('.').last}: ${item.category}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blueGrey[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // Item Price
                                    Text(
                                      'RM${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w900, // Extra bold
                                        fontSize: 20,
                                        color:
                                            Colors
                                                .green, // Vibrant green for price
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Stock quantity (if product)
                                    if (item.type == ItemType.product)
                                      Text(
                                        'Stock: ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              (item.quantity ?? 0) <= 0
                                                  ? Colors.red
                                                  : Colors.green[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    // Add to Cart Button with enhanced styling
                                    ElevatedButton.icon(
                                      onPressed:
                                          item.type == ItemType.product &&
                                                  (item.quantity ?? 0) <= 0
                                              ? null // Disable if out of stock
                                              : () {
                                                viewModel.addItemToCart(
                                                  item.id,
                                                  1,
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Added ${item.name} to cart!',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green[400],
                                                    behavior:
                                                        SnackBarBehavior
                                                            .floating,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        size: 20,
                                      ),
                                      label: const Text('Add'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            item.type == ItemType.product &&
                                                    (item.quantity ?? 0) <= 0
                                                ? Colors
                                                    .grey[400] // Disabled color
                                                : Colors
                                                    .deepOrangeAccent, // Vibrant add to cart color
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(
                                          100,
                                          40,
                                        ), // Larger button
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        elevation: 5, // Button elevation
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
