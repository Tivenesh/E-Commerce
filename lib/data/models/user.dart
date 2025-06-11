import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias Firebase Auth's User to avoid conflict
import 'package:e_commerce/utils/logger.dart';

/// Represents a User in the e-commerce application.
/// Its `id` property should match the Firebase Authentication UID.
class User {
  final String id; // This will be the Firebase Auth UID
  final String email;
  final String username;
  final String? profileImageUrl;
  final String? address;
  final String? phoneNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.profileImageUrl,
    this.address,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts a User object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a User object from a Firestore DocumentSnapshot.
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// Creates a minimal User object from a Firebase Auth User object.
  /// This is useful when a user first signs up/logs in, before their
  /// full profile is saved to Firestore.
  factory User.fromFirebaseAuthUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? 'no-email@example.com',
      username: firebaseUser.displayName ?? 'New User',
      profileImageUrl: firebaseUser.photoURL,
      createdAt: Timestamp.now(), // Set initial creation time
      updatedAt: Timestamp.now(), // Set initial update time
    );
  }

  // Add copyWith for immutable updates
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? profileImageUrl,
    String? address,
    String? phoneNumber,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --- Equality and Hashing (optional but good practice) ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username);

  @override
  int get hashCode => Object.hash(id, email, username);
}