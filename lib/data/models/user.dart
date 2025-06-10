import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
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