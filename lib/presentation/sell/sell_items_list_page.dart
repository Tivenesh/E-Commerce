import 'package:e_commerce/presentation/sell/monthly_sales_chart.dart';
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
import 'package:e_commerce/routing/routes.dart';

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
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isRegisteredSeller(app_user.User? user) {
    if (user == null) return false;
    return (user.address?.isNotEmpty ?? false) &&
        (user.phoneNumber?.isNotEmpty ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final profileViewModel = context.watch<ProfileViewModel>();

    if (profileViewModel.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!isRegisteredSeller(profileViewModel.currentUserProfile)) {
      return const SellerRegistrationForm();
    }

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
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      title: const Text(
                        'Seller Dashboard',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      centerTitle: true,
                      pinned: true,
                      floating: true,
                      forceElevated: innerBoxIsScrolled,
                      flexibleSpace: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 255, 120, 205),
                              Colors.purpleAccent
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withOpacity(0.7),
                        indicatorColor: Colors.white,
                        indicatorWeight: 3.0,
                        tabs: const [
                          Tab(icon: Icon(Icons.list_alt), text: 'Listings'),
                          Tab(icon: Icon(Icons.inbox), text: 'Orders'),
                          Tab(icon: Icon(Icons.bar_chart), text: 'Sales'),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListingsTab(vm),
                    _buildOrdersTab(vm),
                    profileViewModel.currentUserProfile?.id != null
                        ? MonthlySalesChart(
                        sellerId: profileViewModel.currentUserProfile!.id)
                        : const Center(
                        child:
                        Text('Please log in to view sales data.')),
                  ],
                ),
              ),
            ),
            floatingActionButton: _tabController.index == 0
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
              backgroundColor: Colors.deepOrangeAccent,
              child: const Icon(Icons.add),
            )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildListingsTab(SellItemVM vm) {
    return RefreshIndicator(
      onRefresh: vm.fetchUserItems,
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? Center(child: Text('Error: ${vm.errorMessage}'))
          : vm.userItems.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.storefront,
                  size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "You haven't listed any items yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Tap the "+" button to add a new listing.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: vm.userItems.length,
        itemBuilder: (context, index) {
          final item = vm.userItems[index];
          return _UserItemCard(item: item, vm: vm);
        },
      ),
    );
  }

  Widget _buildOrdersTab(SellItemVM vm) {
    return RefreshIndicator(
      onRefresh: vm.fetchMyOrders,
      child: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.errorMessage != null
          ? Center(child: Text('Error: ${vm.errorMessage}'))
          : vm.myOrders.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined,
                  size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "No incoming orders yet.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text("New orders will appear here.",
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: vm.myOrders.length,
        itemBuilder: (context, index) {
          final order = vm.myOrders[index];
          return _IncomingOrderCard(order: order, vm: vm);
        },
      ),
    );
  }
}

// --- FIXED Card Widget with Diagnostic ---

class _UserItemCard extends StatelessWidget {
  final Item item;
  final SellItemVM vm;

  const _UserItemCard({required this.item, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // UPDATED: This onTap function now includes a diagnostic SnackBar
        onTap: () {
          // This message will appear at the bottom of the screen if the tap is registered.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card tapped! Navigating...'),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.blue,
            ),
          );

          // The navigation logic that should follow.
          Navigator.of(context).pushNamed(
            AppRoutes.itemDetailRoute,
            arguments: item.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: (item.imageUrls.isNotEmpty)
                    ? Image.network(
                  item.imageUrls.first,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                )
                    : Container(
                  width: 90,
                  height: 90,
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'RM ${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const SizedBox(height: 4),
                    Text('Category: ${item.category}',
                        style: TextStyle(color: Colors.grey[600])),
                    if (item.type == ItemType.product)
                      Text('Stock: ${item.quantity}',
                          style: TextStyle(color: Colors.grey[600])),
                    if (item.type == ItemType.service)
                      Text('Duration: ${item.duration}',
                          style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    tooltip: 'Edit Item',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SellItemFormPage(itemIdToEdit: item.id)),
                      );
                      if (result == true) vm.fetchUserItems();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    tooltip: 'Delete Item',
                    onPressed: () => _confirmDeleteItem(context, item, vm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, Item item, SellItemVM vm) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext, true);
              try {
                await vm.deleteItem(item.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('${item.name} deleted successfully!')));
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Failed to delete ${item.name}: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Unchanged card for orders
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.settings_outlined;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderStatus.returned:
        return Icons.assignment_return;
      default:
        return Icons.info_outline;
    }
  }

  Future<String> _fetchBuyerUsername(String buyerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(buyerId)
          .get();
      return doc.exists
          ? app_user.User.fromFirestore(doc).username
          : 'Unknown Buyer';
    } catch (e) {
      return 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(order.status);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(_getStatusIcon(order.status), color: statusColor),
        ),
        title: Text('Order #${order.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('Total: RM ${order.totalAmount.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.green[700])),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                FutureBuilder<String>(
                  future: _fetchBuyerUsername(order.buyerId),
                  builder: (context, snapshot) {
                    return _buildDetailRow(
                        'Buyer:', snapshot.data ?? 'Loading...', Icons.person);
                  },
                ),
                _buildDetailRow(
                    'Order Date:',
                    order.orderDate
                        .toDate()
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    Icons.calendar_today),
                _buildDetailRow(
                    'Address:', order.deliveryAddress, Icons.location_on),
                if (order.deliveryInstructions?.isNotEmpty ?? false)
                  _buildDetailRow(
                      'Instructions:', order.deliveryInstructions!, Icons.notes),
                const SizedBox(height: 8),
                const Text('Items:',
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Text('• ${item.itemName} (x${item.quantity})'),
                )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Update Status:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    DropdownButton<OrderStatus>(
                      value: order.status,
                      underline: Container(height: 2, color: statusColor),
                      onChanged: (newStatus) async {
                        if (newStatus != null) {
                          await vm.updateOrderStatus(order.id, newStatus);
                        }
                      },
                      items: OrderStatus.values.map((status) {
                        return DropdownMenuItem(
                            value: status,
                            child: Text(
                                status.name.replaceAll('_', ' ').capitalize(),
                                style:
                                TextStyle(color: _getStatusColor(status))));
                      }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(label,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(width: 5),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}