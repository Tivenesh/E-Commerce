import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';

/// Represents a payment transaction.
class Payment {
  final String id;
  final String orderId; // Reference to the Order document
  final String payerId; // ID of the user making the payment (buyer)
  final double amount;
  final Timestamp paymentDate;
  final String paymentMethod; // e.g., 'Credit Card', 'PayPal', 'Cash on Delivery'
  final String transactionId; // Unique ID from payment gateway
  final bool isSuccessful;

  Payment({
    required this.id,
    required this.orderId,
    required this.payerId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.isSuccessful,
  });

  /// Converts a Payment object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'payerId': payerId,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'isSuccessful': isSuccessful,
    };
  }

  /// Creates a Payment object from a Firestore DocumentSnapshot.
  factory Payment.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Payment(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      payerId: data['payerId'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: data['paymentDate'] ?? Timestamp.now(),
      paymentMethod: data['paymentMethod'] ?? '',
      transactionId: data['transactionId'] ?? '',
      isSuccessful: data['isSuccessful'] ?? false,
    );
  }
}