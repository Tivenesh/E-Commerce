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
    // Get the view model instance to access its state and methods
    final viewModel = Provider.of<ItemListViewModel>(context);

    // This page no longer needs its own Scaffold, as the HomeScreen provides it.
    // It returns a Container that will be placed in the body of the HomeScreen's Scaffold.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // --- UPDATED: Search and Filter Bar Area ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 120, 205),
                  Colors.purpleAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16.0, 0, 8.0, 0),
            child: SafeArea(
              bottom: false,
              child: Row( // Row holds the search field and the new sort button
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for amazing items...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // --- NEW: The Sort Button and Dropdown Menu ---
                  PopupMenuButton<SortType>(
                    tooltip: "Sort Items",
                    initialValue: viewModel.currentSortType,
                    // When a user selects an option, call the ViewModel's method
                    onSelected: (SortType result) {
                      viewModel.updateSortOrder(result);
                    },
                    icon: const Icon(Icons.sort, color: Colors.white, size: 28),
                    // Defines the items that appear in the dropdown menu
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
                      const PopupMenuItem<SortType>(
                        value: SortType.newest,
                        child: Text('Sort by: Newest'),
                      ),
                      const PopupMenuItem<SortType>(
                        value: SortType.oldest,
                        child: Text('Sort by: Oldest'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<SortType>(
                        value: SortType.priceLowToHigh,
                        child: Text('Price: Low to High'),
                      ),
                      const PopupMenuItem<SortType>(
                        value: SortType.priceHighToLow,
                        child: Text('Price: High to Low'),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem<SortType>(
                        value: SortType.nameAZ,
                        child: Text('Name: A-Z'),
                      ),
                      const PopupMenuItem<SortType>(
                        value: SortType.nameZA,
                        child: Text('Name: Z-A'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
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
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
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
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
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
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blueGrey,
                          ),
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
                            margin: EdgeInsets.zero,
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ),
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
                                            color:
                                            Colors
                                                .blueGrey[100],
                                            child: const Icon(
                                              Icons
                                                  .image_not_supported,
                                              color:
                                              Colors.blueGrey,
                                              size: 40,
                                            ),
                                          ),
                                        )
                                            : Container(
                                          color: Colors.blueGrey[100],
                                          child: Icon(
                                            item.type ==
                                                ItemType.product
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
                                          Container(
                                            padding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blueGrey[100],
                                              borderRadius:
                                              BorderRadius.circular(8),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'RM${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
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
                                        ElevatedButton.icon(
                                          onPressed:
                                          item.type == ItemType.product &&
                                              (item.quantity ?? 0) <=
                                                  0
                                              ? null
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
                                                duration:
                                                const Duration(
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
                                            item.type ==
                                                ItemType
                                                    .product &&
                                                (item.quantity ??
                                                    0) <=
                                                    0
                                                ? Colors.grey[400]
                                                : Colors.deepOrangeAccent,
                                            foregroundColor: Colors.white,
                                            minimumSize: const Size(100, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10),
                                            ),
                                            elevation: 5,
                                            padding:
                                            const EdgeInsets.symmetric(
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
        ],
      ),
    );
  }
}