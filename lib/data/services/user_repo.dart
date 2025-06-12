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

  // Update existing user
  Future<void> updateUser(User user) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(user.id)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(_collectionName)
              .where('roles', arrayContains: role)
              .get();

      return querySnapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: ${e.toString()}');
    }
  }

  // Get all sellers
  Future<List<User>> getAllSellers() async {
    return await getUsersByRole('seller');
  }

  // Get all buyers
  Future<List<User>> getAllBuyers() async {
    return await getUsersByRole('buyer');
  }

  // Stream user data for real-time updates
  Stream<User?> getUserStream(String userId) {
    return _firestore
        .collection(_collectionName)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? User.fromFirestore(doc) : null);
  }

  // Check if user exists
  Future<bool> userExists(String userId) async {
    try {
      final doc =
          await _firestore.collection(_collectionName).doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Update user role (add seller role)
  Future<void> addSellerRole(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      if (!user.isSeller) {
        final updatedRoles = List<String>.from(user.roles)..add('seller');
        await _firestore.collection(_collectionName).doc(userId).update({
          'roles': updatedRoles,
          'updatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add seller role: ${e.toString()}');
    }
  }

  // Remove seller role
  Future<void> removeSellerRole(String userId) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      if (user.isSeller) {
        final updatedRoles = List<String>.from(user.roles)..remove('seller');
        await _firestore.collection(_collectionName).doc(userId).update({
          'roles': updatedRoles,
          'updatedAt': Timestamp.now(),
          // Clear seller-specific fields
          'businessName': null,
          'businessAddress': null,
          'businessContactEmail': null,
          'businessPhoneNumber': null,
          'businessDescription': null,
        });
      }
    } catch (e) {
      throw Exception('Failed to remove seller role: ${e.toString()}');
    }
  }
}
