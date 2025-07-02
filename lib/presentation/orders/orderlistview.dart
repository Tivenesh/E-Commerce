import 'package:e_commerce/data/models/order_item.dart';
import 'package:e_commerce/presentation/orders/orderlistvm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The user's order history page (View).
class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enhanced AppBar with a gradient and prominent title
      appBar: AppBar(
        title: const Text(
          'My Orders',
          style: TextStyle(
            fontSize: 24, // Changed from 28 to 24
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
      ),
      // Body with the requested blueGrey gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[50]!, Colors.blueGrey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<OrderListViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      'Fetching your orders...',
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
            if (viewModel.orders.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.blueGrey,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You have no orders yet.',
                      style: TextStyle(fontSize: 20, color: Colors.blueGrey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Start shopping to see your orders here!',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: viewModel.orders.length,
              itemBuilder: (context, index) {
                final order = viewModel.orders[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 6, // Increased elevation for a lifted effect
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      15,
                    ), // More rounded corners
                  ),
                  clipBehavior:
                      Clip.antiAlias, // Ensures content respects border radius
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.blueGrey[50]!,
                        ], // Subtle gradient for card background
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 20.0, // More horizontal padding
                        vertical: 12.0, // More vertical padding
                      ),
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(
                          order.status,
                        ).withOpacity(0.1),
                        child: Icon(
                          _getStatusIcon(order.status),
                          color: _getStatusColor(order.status),
                          size: 28,
                        ),
                      ),
                      title: Text(
                        'Order #${order.id.substring(0, 8).toUpperCase()}', // Show more of the ID
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Slightly larger title
                          color: Colors.blueGrey,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Total: RM${order.totalAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  Colors.green[700], // Highlight total amount
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Status: ${_getStatusText(order.status)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            20.0,
                            0,
                            20.0,
                            20.0,
                          ), // Consistent padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                height: 20,
                                thickness: 1.5,
                                color: Colors.blueGrey,
                              ),
                              _buildDetailRow(
                                'Order Date:',
                                order.orderDate
                                    .toDate()
                                    .toLocal()
                                    .toString()
                                    .split(' ')[0],
                                Icons.calendar_today,
                              ),
                              if (order.estimatedDeliveryDate != null)
                                _buildDetailRow(
                                  'Est. Delivery:',
                                  order.estimatedDeliveryDate!
                                      .toDate()
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  Icons.delivery_dining,
                                ),
                              if (order.deliveredDate != null)
                                _buildDetailRow(
                                  'Delivered On:',
                                  order.deliveredDate!
                                      .toDate()
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  Icons.check_box,
                                ),
                              const SizedBox(height: 16),
                              Text(
                                'Items in this order:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...order.items
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 8.0,
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 8,
                                            color: Colors.blueGrey[300],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${item.itemName} (x${item.quantity}) - RM${item.itemPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              const SizedBox(height: 16),
                              Text(
                                'Delivery Details:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.blueGrey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Address:',
                                order.deliveryAddress,
                                Icons.location_on,
                              ),
                              if (order.deliveryInstructions != null &&
                                  order.deliveryInstructions!.isNotEmpty)
                                _buildDetailRow(
                                  'Instructions:',
                                  order.deliveryInstructions!,
                                  Icons.notes,
                                ),
                            ],
                          ),
                        ),
                      ],
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

  // Helper method to build a consistent detail row
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
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

  String _getStatusText(OrderStatus status) {
    return status.toString().split('.').last.toUpperCase();
  }
}
