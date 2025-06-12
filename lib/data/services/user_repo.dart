import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/user.dart';

/// Service for managing User data in Firestore.
class UserRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Adds a new user document or updates an existing one if the ID matches.
  Future<void> addUser(User user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.id)
          .set(user.toJson());
      appLogger.i('User added/updated successfully: ${user.username}');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception adding user: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error adding user: $e');
      rethrow;
    }
  }

  /// Fetches a single user by their unique ID.
  Future<User?> getUserById(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(_collectionName).doc(userId).get();
      if (docSnapshot.exists) {
        return User.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception getting user by ID: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error getting user by ID: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream for a single user document.
  Stream<User?> getUserStream(String userId) {
    return _firestore.collection(_collectionName).doc(userId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return User.fromFirestore(snapshot);
      }
      return null;
    });
  }

  /// Updates specific fields of an existing user document.
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.id)
          .update(user.toJson());
      appLogger.i('User updated successfully: ${user.username}');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception updating user: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error updating user: $e');
      rethrow;
    }
  }

  /// Upgrades a user to a seller.
  /// This adds the 'seller' role and updates their business information.
  Future<void> upgradeToSeller(
    String userId, {
    required String businessName,
    required String businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) async {
    try {
      final userDocRef = _firestore.collection(_collectionName).doc(userId);

      // Using a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }

        // Get current roles, or default to an empty list
        List<String> currentRoles = List<String>.from(
          snapshot.data()?['roles'] ?? [],
        );

        // Add 'seller' role if it's not already there
        if (!currentRoles.contains('seller')) {
          currentRoles.add('seller');
        }

        transaction.update(userDocRef, {
          'roles': currentRoles,
          'businessName': businessName,
          'businessAddress': businessAddress,
          'businessContactEmail': businessContactEmail,
          'businessPhoneNumber': businessPhoneNumber,
          'businessDescription': businessDescription,
          'updatedAt': Timestamp.now(),
        });
      });
      appLogger.i('User $userId upgraded to seller successfully.');
    } catch (e) {
      appLogger.e('Error upgrading user to seller: $e', error: e);
      throw Exception('Failed to upgrade to seller.');
    }
  }

  /// Deletes a user document by its ID.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
      appLogger.i('User deleted successfully: $userId');
    } on FirebaseException catch (e) {
      appLogger.i('Firebase Exception deleting user: ${e.message}');
      rethrow;
    } catch (e) {
      appLogger.e('Error deleting user: $e');
      rethrow;
    }
  }
}
