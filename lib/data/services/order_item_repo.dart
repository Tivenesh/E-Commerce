import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/order_item.dart'; 

/// Service for managing Order data in Firestore.
class OrderItemRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'orders';

  /// Adds a new order document to Firestore.
  Future<void> addOrder(OrderItem order) async {
    try {
      await _firestore.collection(_collectionName).doc(order.id).set(order.toJson());
      print('Order added successfully: ${order.id}');
    } on FirebaseException catch (e) {
      print('Firebase Exception adding order: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }

  /// Fetches a single order by its unique ID.
  Future<OrderItem?> getOrderById(String orderId) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionName).doc(orderId).get();
      if (docSnapshot.exists) {
        return OrderItem.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Exception getting order by ID: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error getting order by ID: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream of all order documents.
  Stream<List<OrderItem>> getOrders() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
    });
  }

  /// Provides a real-time stream of orders placed by a specific buyer.
  Stream<List<OrderItem>> getOrdersByBuyer(String buyerId) {
    return _firestore
        .collection(_collectionName)
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
    });
  }

  /// Provides a real-time stream of orders for a specific seller.
  Stream<List<OrderItem>> getOrdersBySeller(String sellerId) {
    return _firestore
        .collection(_collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderItem.fromFirestore(doc)).toList();
    });
  }

  /// Updates specific fields of an existing order document.
  Future<void> updateOrder(OrderItem order) async {
    try {
      await _firestore.collection(_collectionName).doc(order.id).update(order.toJson());
      print('Order updated successfully: ${order.id}');
    } on FirebaseException catch (e) {
      print('Firebase Exception updating order: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  /// Deletes an order document by its ID.
  Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collectionName).doc(orderId).delete();
      print('Order deleted successfully: $orderId');
    } on FirebaseException catch (e) {
      print('Firebase Exception deleting order: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }
}
