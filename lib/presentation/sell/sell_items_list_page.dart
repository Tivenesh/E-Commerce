import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart';
import 'package:e_commerce/presentation/sell/sell_item_form_page.dart';
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/models/order_item.dart';

class SellItemsListPage extends StatelessWidget {
  const SellItemsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final vm = SellItemVM();
        vm.fetchUserItems();
        vm.fetchMyOrders();
        return vm;
      },
      child: Consumer<SellItemVM>(
        builder: (context, vm, child) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Seller Dashboard'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Your Listings'),
                    Tab(text: 'Incoming Orders'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: vm.fetchUserItems,
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
                                  Text(
                                    "Tap the '+' button to add a new listing!",
                                  ),
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
                  RefreshIndicator(
                    onRefresh: vm.fetchMyOrders,
                    child:
                        vm.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : vm.errorMessage != null
                            ? Center(child: Text('Error: ${vm.errorMessage}'))
                            : vm.myOrders.isEmpty
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("No incoming orders yet."),
                                  SizedBox(height: 10),
                                  Text("New orders will appear here."),
                                ],
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: vm.myOrders.length,
                              itemBuilder: (context, index) {
                                final order = vm.myOrders[index];
                                return _SellerOrderCard(order: order, vm: vm);
                              },
                            ),
                  ),
                ],
              ),
              floatingActionButton: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);
                  return AnimatedBuilder(
                    animation: tabController!,
                    builder: (context, _) {
                      return tabController.index == 0
                          ? FloatingActionButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const SellItemFormPage(),
                                ),
                              );
                              if (result == true) {
                                vm.fetchUserItems();
                              }
                            },
                            child: const Icon(Icons.add),
                          )
                          : const SizedBox.shrink();
                    },
                  );
                },
              ),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    SellItemFormPage(itemIdToEdit: item.id),
                          ),
                        );
                        if (result == true) {
                          vm.fetchUserItems();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Delete Listing'),
                                content: Text(
                                  'Are you sure you want to delete "${item.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                        if (confirm == true) {
                          try {
                            await vm.deleteItem(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${item.name} deleted successfully!',
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Failed to delete ${item.name}: $e',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- MODIFIED: _SellerOrderCard as StatefulWidget -------------------
class _SellerOrderCard extends StatefulWidget {
  final OrderItem order;
  final SellItemVM vm;

  const _SellerOrderCard({required this.order, required this.vm});

  @override
  State<_SellerOrderCard> createState() => _SellerOrderCardState();
}

class _SellerOrderCardState extends State<_SellerOrderCard> {
  String? buyerUsername;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBuyerUsername();
  }

  Future<void> fetchBuyerUsername() async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.order.buyerId)
              .get();
      setState(() {
        buyerUsername = doc.data()?['username'] ?? 'Unknown';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        buyerUsername = 'Error loading username';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(0, 6).toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Buyer: ${isLoading ? "Loading..." : buyerUsername}'),
            const SizedBox(height: 4),
            Text('Delivery Address: ${order.deliveryAddress}'),
            if (order.deliveryInstructions != null &&
                order.deliveryInstructions!.isNotEmpty)
              Text('Instructions: ${order.deliveryInstructions}'),
            const SizedBox(height: 4),
            Text('Total Amount: RM${order.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text('${item.itemName} (x${item.quantity})'),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButton<OrderStatus>(
                  value: order.status,
                  onChanged: (OrderStatus? newStatus) async {
                    if (newStatus != null) {
                      await widget.vm.updateOrderStatus(order.id, newStatus);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Order ${order.id} status updated to ${newStatus.name}!',
                          ),
                        ),
                      );
                    }
                  },
                  items:
                      OrderStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.name.replaceAll('_', ' ').capitalize(),
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------- Text Capitalizer Extension -------------------
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
