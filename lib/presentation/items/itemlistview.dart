import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/presentation/items/itemlistvm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        title: const Text('Shop Items'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.blueGrey[600],
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
            ),
          ),
        ),
      ),
      body: Consumer<ItemListViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  viewModel.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          if (viewModel.items.isEmpty) {
            return const Center(
              child: Text('No items found matching your search.', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.items.length,
            itemBuilder: (context, index) {
              final item = viewModel.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: item.imageUrls.isNotEmpty
                            ? Image.network(
                                item.imageUrls.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.blueGrey[50],
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Icon(item.type == ItemType.product ? Icons.shopping_bag : Icons.miscellaneous_services, color: Colors.blueGrey),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.description,
                              style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.type.toString().split('.').last}: ${item.category}',
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text('\$${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                          if (item.type == ItemType.product)
                            Text('Stock: ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          ElevatedButton(
                            onPressed: item.type == ItemType.product && (item.quantity ?? 0) <= 0
                                ? null // Disable if out of stock
                                : () {
                                    // Add to cart with quantity 1 (can be expanded with a quantity picker)
                                    viewModel.addItemToCart(item.id, 1);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Added ${item.name} to cart!'),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[700],
                              foregroundColor: Colors.white,
                              minimumSize: const Size(80, 30),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
