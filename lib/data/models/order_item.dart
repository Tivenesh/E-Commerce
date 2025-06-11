import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart.dart';

// Helper enum for Order status
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}


class OrderItem {
  final String id;
  final String buyerId; // ID of the user who placed the order
  final String sellerId; // ID of the user who is selling the items in this order
  final List<CartItem> items; // List of items included in this order
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final Timestamp orderDate;
  final Timestamp? estimatedDeliveryDate;
  final Timestamp? deliveredDate;

  OrderItem({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.deliveryInstructions,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.deliveredDate,
  });

  /// Converts an Order object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'items': items.map((item) => item.toJson()).toList(), // Convert CartItem list to JSON list
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last, // Store as string
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'orderDate': orderDate,
      'estimatedDeliveryDate': estimatedDeliveryDate,
      'deliveredDate': deliveredDate,
    };
  }

  /// Creates an Order object from a Firestore DocumentSnapshot.
  factory OrderItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderItem(
      id: doc.id,
      buyerId: data['buyerId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((itemJson) => CartItem.fromJson(itemJson as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryInstructions: data['deliveryInstructions'],
      orderDate: data['orderDate'] ?? Timestamp.now(),
      estimatedDeliveryDate: data['estimatedDeliveryDate'],
      deliveredDate: data['deliveredDate'],
    );
  }
}