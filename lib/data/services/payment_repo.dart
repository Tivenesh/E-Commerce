import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/payment.dart';

/// Service for managing Payment data in Firestore.
class PaymentRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'payments';

  /// Adds a new payment document to Firestore.
  Future<void> addPayment(Payment payment) async {
    try {
      await _firestore.collection(_collectionName).doc(payment.id).set(payment.toJson());
      print('Payment added successfully: ${payment.id}');
    } on FirebaseException catch (e) {
      print('Firebase Exception adding payment: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  /// Fetches a single payment by its unique ID.
  Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionName).doc(paymentId).get();
      if (docSnapshot.exists) {
        return Payment.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Exception getting payment by ID: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error getting payment by ID: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream of all payment documents.
  Stream<List<Payment>> getPayments() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();
    });
  }

  /// Provides a real-time stream of payments associated with a specific order.
  Stream<List<Payment>> getPaymentsForOrder(String orderId) {
    return _firestore
        .collection(_collectionName)
        .where('orderId', isEqualTo: orderId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Payment.fromFirestore(doc)).toList();
    });
  }

  /// Updates specific fields of an existing payment document.
  Future<void> updatePayment(Payment payment) async {
    try {
      await _firestore.collection(_collectionName).doc(payment.id).update(payment.toJson());
      print('Payment updated successfully: ${payment.id}');
    } on FirebaseException catch (e) {
      print('Firebase Exception updating payment: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  /// Deletes a payment document by its ID.
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection(_collectionName).doc(paymentId).delete();
      print('Payment deleted successfully: $paymentId');
    } on FirebaseException catch (e) {
      print('Firebase Exception deleting payment: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }
}
