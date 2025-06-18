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
      appBar: AppBar(title: const Text('My Orders')),
      body: Consumer<OrderListViewModel>(
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
          if (viewModel.orders.isEmpty) {
            return const Center(
              child: Text(
                'You have no orders yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.orders.length,
            itemBuilder: (context, index) {
              final order = viewModel.orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  leading: Icon(
                    _getStatusIcon(order.status),
                    color: _getStatusColor(order.status),
                  ),
                  title: Text(
                    'Order #${order.id.substring(0, 6).toUpperCase()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: RM${order.totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Status: ${_getStatusText(order.status)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Date: ${order.orderDate.toDate().toLocal().toString().split(' ')[0]}',
                          ),
                          if (order.estimatedDeliveryDate != null)
                            Text(
                              'Est. Delivery: ${order.estimatedDeliveryDate!.toDate().toLocal().toString().split(' ')[0]}',
                            ),
                          if (order.deliveredDate != null)
                            Text(
                              'Delivered: ${order.deliveredDate!.toDate().toLocal().toString().split(' ')[0]}',
                            ),
                          const SizedBox(height: 8),
                          const Text(
                            'Items:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          ...order.items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    '- ${item.itemName} (x${item.quantity}) @ RM${item.itemPrice.toStringAsFixed(2)}',
                                  ),
                                ),
                              )
                              .toList(),
                          const SizedBox(height: 8),
                          Text('Delivery Address: ${order.deliveryAddress}'),
                          if (order.deliveryInstructions != null &&
                              order.deliveryInstructions!.isNotEmpty)
                            Text('Instructions: ${order.deliveryInstructions}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
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
