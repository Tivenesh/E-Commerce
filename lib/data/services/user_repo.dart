import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// Service for managing User data in Firestore.
class UserRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';

  /// Adds a new user document or updates an existing one if the ID matches.
  Future<void> addUser(User user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.id).set(user.toJson());
      print('User added/updated successfully: ${user.username}');
    } on FirebaseException catch (e) {
      print('Firebase Exception adding user: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error adding user: $e');
      rethrow;
    }
  }

  /// Fetches a single user by their unique ID.
  Future<User?> getUserById(String userId) async {
    try {
      final docSnapshot = await _firestore.collection(_collectionName).doc(userId).get();
      if (docSnapshot.exists) {
        return User.fromFirestore(docSnapshot);
      }
      return null;
    } on FirebaseException catch (e) {
      print('Firebase Exception getting user by ID: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error getting user by ID: $e');
      rethrow;
    }
  }

  /// Provides a real-time stream of all user documents.
  Stream<List<User>> getUsers() {
    return _firestore.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
    });
  }

  /// Updates specific fields of an existing user document.
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection(_collectionName).doc(user.id).update(user.toJson());
      print('User updated successfully: ${user.username}');
    } on FirebaseException catch (e) {
      print('Firebase Exception updating user: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  /// Deletes a user document by its ID.
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collectionName).doc(userId).delete();
      print('User deleted successfully: $userId');
    } on FirebaseException catch (e) {
      print('Firebase Exception deleting user: ${e.message}');
      rethrow;
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
