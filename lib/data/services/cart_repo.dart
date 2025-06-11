import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/cart.dart'; 

/// Service for managing user-specific Cart data in Firestore.
/// Cart items are stored as a subcollection under each user:
/// 'users/{userId}/cart/{cartItemId}'
class CartRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';
  static const String _cartSubCollection = 'cart';

  /// Adds an item to a user's cart or updates its quantity if it already exists.
  /// The `cartItem.itemId` is used as the document ID within the cart subcollection.
  Future<void> addOrUpdateCartItem(String userId, CartItem cartItem) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_cartSubCollection)
          .doc(cartItem.itemId) // Using itemId as the document ID for the cart item
          .set(cartItem.toJson());
      print('Cart item added/updated for user $userId: ${cartItem.itemName}');
    } on FirebaseException catch (e) {
      print('Firebase Exception adding/updating cart item: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding/updating cart item: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream of all items in a specific user's cart.
  Stream<List<CartItem>> getCartItems(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .collection(_cartSubCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CartItem.fromJson(doc.data())).toList();
    });
  }

  /// Removes a specific item from a user's cart.
  Future<void> removeCartItem(String userId, String itemId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_cartSubCollection)
          .doc(itemId)
          .delete();
      print('Cart item removed for user $userId: $itemId');
    } on FirebaseException catch (e) {
      print('Firebase Exception removing cart item: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error removing cart item: $e');
      rethrow;
    }
  }

  /// Clears all items from a user's cart using a batched write for efficiency.
  Future<void> clearCart(String userId) async {
    try {
      final batch = _firestore.batch();
      final cartItems = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .collection(_cartSubCollection)
          .get();
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('Cart cleared for user $userId');
    } on FirebaseException catch (e) {
      print('Firebase Exception clearing cart: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error clearing cart: $e');
      rethrow;
    }
  }
}
