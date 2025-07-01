import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_commerce/presentation/sell/sellitemview.dart';
import 'package:e_commerce/presentation/sell/sell_item_form_page.dart';
import 'package:e_commerce/data/models/item.dart';
import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/data/models/user.dart' as app_user;
import 'package:e_commerce/presentation/users/profilevm.dart';
import 'package:e_commerce/presentation/sell/seller_registration_form.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellItemsListPage extends StatefulWidget {
  const SellItemsListPage({super.key});

  @override
  State<SellItemsListPage> createState() => _SellItemsListPageState();
}

class _SellItemsListPageState extends State<SellItemsListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  /// Checks if the user has completed the required seller profile fields.
  bool isRegisteredSeller(app_user.User? user) {
    if (user == null) return false;
    // We consider a user a "seller" if they have provided an address and phone number.
    return (user.address?.isNotEmpty ?? false) &&
        (user.phoneNumber?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();

    if (profileViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // THE GATEKEEPER LOGIC:
    // If the user is not a registered seller, show the registration form.
    if (!isRegisteredSeller(profileViewModel.currentUserProfile)) {
      return const SellerRegistrationForm();
    }

    // If the check passes, show the seller dashboard.
    return ChangeNotifierProvider(
      create: (context) {
        final vm = SellItemVM();
        vm.fetchUserItems();
        vm.fetchMyOrders();
        return vm;
      },
      child: Consumer<SellItemVM>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Seller Dashboard'),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Your Listings'),
                  Tab(text: 'Incoming Order'),
                  Tab(text: 'Monthly Sale'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Your Listings Tab Content
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
                                Text(
                                  "You haven't listed any items yet.",
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(height: 10),
                                Text('Tap "+" to add a new listing.'),
                              ],
                            ),
                          )
                          : ListView.builder(
                            itemCount: vm.userItems.length,
                            itemBuilder: (context, index) {
                              final item = vm.userItems[index];
                              return _UserItemCard(item: item, vm: vm);
                            },
                          ),
                ),

                // Incoming Order Tab Content
                RefreshIndicator(
                  onRefresh: vm.fetchMyOrders,
                  child:
                      vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : vm.errorMessage != null
                          ? Center(child: Text('Error: ${vm.errorMessage}'))
                          : vm.myOrders.isEmpty
                          ? const Center(
                            child: Text(
                              "No incoming orders yet.",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                          : ListView.builder(
                            itemCount: vm.myOrders.length,
                            itemBuilder: (context, index) {
                              final order = vm.myOrders[index];
                              return _IncomingOrderCard(order: order, vm: vm);
                            },
                          ),
                ),

                // Monthly Sale Tab Content
                const Center(child: Text('Monthly Sale Content')),
              ],
            ),
            floatingActionButton:
                _tabController.index == 0
                    ? FloatingActionButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SellItemFormPage(),
                          ),
                        );
                        if (result == true) {
                          vm.fetchUserItems();
                        }
                      },
                      child: const Icon(Icons.add),
                    )
                    : null,
          );
        },
      ),
    );
  }
}

// --- Card Widgets for Listings and Orders ---

// Card for displaying User's Listed Items
class _UserItemCard extends StatelessWidget {
  final Item item;
  final SellItemVM vm;

  const _UserItemCard({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child:
                  item.imageUrls.isNotEmpty
                      ? Image.network(
                        item.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 80),
                      )
                      : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(
                          item.type == ItemType.product
                              ? Icons.shopping_bag
                              : Icons.build,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
            ),
            const SizedBox(width: 12),
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
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'RM ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text('Category: ${item.category}'),
                  if (item.type == ItemType.product)
                    Text('Quantity: ${item.quantity}'),
                  if (item.type == ItemType.service)
                    Text('Duration: ${item.duration}'),
                ],
              ),
            ),
            Column(
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
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (dialogContext) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: Text(
                              'Are you sure you want to delete "${item.name}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.pop(dialogContext, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                    );
                    if (confirm ?? false) {
                      try {
                        await vm.deleteItem(item.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${item.name} deleted successfully!',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to delete ${item.name}: ${e.toString()}',
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Card for displaying Incoming Orders
class _IncomingOrderCard extends StatelessWidget {
  final OrderItem order;
  final SellItemVM vm;

  const _IncomingOrderCard({required this.order, required this.vm});

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Future<String> _fetchBuyerUsername(String buyerId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(buyerId)
              .get();
      if (doc.exists) {
        final user = app_user.User.fromFirestore(doc);
        return user.username;
      }
      return 'Unknown Buyer';
    } catch (e) {
      print('Error fetching buyer username: $e');
      return 'Error fetching buyer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id.substring(0, 6).toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            FutureBuilder<String>(
              future: _fetchBuyerUsername(order.buyerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Buyer: Loading...');
                } else if (snapshot.hasError) {
                  return const Text('Buyer: Error');
                } else {
                  return Text('Buyer: ${snapshot.data}');
                }
              },
            ),
            Text('Total Amount: RM ${order.totalAmount.toStringAsFixed(2)}'),
            Text(
              'Order Date: ${order.orderDate.toDate().toLocal().toIso8601String().split('T').first}',
            ),
            const SizedBox(height: 8),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map(
              (cartItem) => Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                child: Text('- ${cartItem.itemName} (x${cartItem.quantity})'),
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
                  underline: Container(height: 2, color: statusColor),
                  onChanged: (OrderStatus? newStatus) async {
                    if (newStatus != null) {
                      await vm.updateOrderStatus(order.id, newStatus);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Order ${order.id.substring(0, 8)}... status updated to ${newStatus.name.replaceAll('_', ' ').capitalize()}!',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  items:
                      OrderStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.name.replaceAll('_', ' ').capitalize(),
                            style: TextStyle(color: _getStatusColor(status)),
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
