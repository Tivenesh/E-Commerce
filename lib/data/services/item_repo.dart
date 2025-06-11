import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/item.dart'; 

/// Service for managing Item data in Firestore.
class ItemRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'items';

  /// Adds a new item document or updates an existing one.
  Future<void> addItem(Item item) async {
    try {
      await _firestore.collection(_collectionName).doc(item.id).set(item.toJson());
      appLogger.i('Item added/updated successfully: ${item.name}');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception adding item: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error adding item: $e');
      rethrow;
    }
  }

  /// Fetches a single item by its unique ID.
  Future<Item?> getItemById(String itemId) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionName).doc(itemId).get();
      if (docSnapshot.exists) {
        return Item.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception getting item by ID: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error getting item by ID: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream of all item documents.
  Stream<List<Item>> getItems() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
    });
  }

  /// Provides a real-time stream of items listed by a specific seller.
  Stream<List<Item>> getItemsBySeller(String sellerId) {
    return _firestore
        .collection(_collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
    });
  }

  /// Updates specific fields of an existing item document.
  Future<void> updateItem(Item item) async {
    try {
      await _firestore.collection(_collectionName).doc(item.id).update(item.toJson());
      appLogger.i('Item updated successfully: ${item.name}');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception updating item: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error updating item: $e');
      rethrow;
    }
  }

  /// Deletes an item document by its ID.
  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore.collection(_collectionName).doc(itemId).delete();
      appLogger.i('Item deleted successfully: $itemId');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception deleting item: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error deleting item: $e');
      rethrow;
    }
  }
}
