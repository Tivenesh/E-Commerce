// File: lib/presentation/sell/sell_items_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart'; // Import SellItemVM
import 'package:e_commerce/presentation/sell/sell_item_form_page.dart'; // Import the new form page
import 'package:e_commerce/data/models/item.dart'; // Ensure Item model is imported

class SellItemsListPage extends StatelessWidget {
  const SellItemsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SellItemVM(), // Provide the VM for this page
      child: Consumer<SellItemVM>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Your Listings')),
            body: RefreshIndicator(
              onRefresh: vm.fetchUserItems, // Allow pull-to-refresh
              child:
                  vm.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : vm.errorMessage != null
                      ? Center(child: Text('Error: ${vm.errorMessage}'))
                      : vm.userItems.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("You haven't listed any items yet."),
                            SizedBox(height: 10),
                            Text("Tap the '+' button to add a new listing!"),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: vm.userItems.length,
                        itemBuilder: (context, index) {
                          final item = vm.userItems[index];
                          return _SellerItemCard(item: item, vm: vm);
                        },
                      ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // Navigate to the form page
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SellItemFormPage(),
                  ),
                );
                // If the form was submitted successfully, refresh the list
                if (result == true) {
                  vm.fetchUserItems();
                }
              },
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}

class _SellerItemCard extends StatelessWidget {
  final Item item;
  final SellItemVM vm;

  const _SellerItemCard({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Image/Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
                image:
                    item.imageUrls.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(item.imageUrls.first),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  item.imageUrls.isEmpty
                      ? Center(
                        child: Icon(
                          item.type == ItemType.product
                              ? Icons.shopping_bag_outlined
                              : Icons.settings,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 12.0),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Category: ${item.category}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (item.type == ItemType.product)
                    Text(
                      'Stock: ${item.quantity}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (item.type == ItemType.service)
                    Text(
                      'Duration: ${item.duration}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            // Price and Delete Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  onPressed: () async {
                    // Show a confirmation dialog before deleting
                    final bool confirm = await showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Delete Listing'),
                            content: Text(
                              'Are you sure you want to delete "${item.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );

                    if (confirm) {
                      try {
                        await vm.deleteItem(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.name} deleted successfully!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to delete ${item.name}: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
                // You can add an "Edit" button here if you implement editing
                // IconButton(
                //   icon: const Icon(Icons.edit, color: Colors.blue),
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => SellItemFormPage(itemIdToEdit: item.id)),
                //     );
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
