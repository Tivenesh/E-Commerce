import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Alias Firebase Auth's User to avoid conflict

/// Represents a User in the e-commerce application.
/// Its `id` property should match the Firebase Authentication UID.
class User {
  final String id; // This will be the Firebase Auth UID
  final String? fullName;
  final String username;
  final String email;
  final Timestamp? dateOfBirth;
  final String? profileImageUrl;
  final String? address;
  final String? phoneNumber;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String? gender;
  // New fields specific to sellers (can be null for buyers)
  final String? businessName;
  final String? businessAddress;
  final String? businessContactEmail;
  final String? businessPhoneNumber;
  final String? businessDescription;
  final List<String> roles; // 'buyer', 'seller'

  User({
    required this.id,
    required this.email,
    required this.username,
    // roleName is now required in the constructor, with a default 'buyer'
    // in factories where it might not be explicitly set.
    this.roles = const ['buyer'], // Default role
    this.profileImageUrl,
    this.address,
    this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.gender,
    this.dateOfBirth,
    // Seller specific fields
    this.businessName,
    this.businessAddress,
    this.businessContactEmail,
    this.businessPhoneNumber,
    this.businessDescription,
  });
  bool get isSeller => roles.contains('seller');

  /// Converts a User object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'roles': roles, // Store only roleName
      'profileImageUrl': profileImageUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      // Include seller-specific fields in JSON
      'businessName': businessName,
      'businessAddress': businessAddress,
      'businessContactEmail': businessContactEmail,
      'businessPhoneNumber': businessPhoneNumber,
      'businessDescription': businessDescription,
    };
  }

  /// Creates a User object from a Firestore DocumentSnapshot.
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      // Provide a default 'buyer' if roleName is missing in Firestore
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      fullName: data['fullName'],
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      roles: List<String>.from(data['roles'] ?? ['buyer']),

      // Assign seller-specific fields from Firestore
      businessName: data['businessName'],
      businessAddress: data['businessAddress'],
      businessContactEmail: data['businessContactEmail'],
      businessPhoneNumber: data['businessPhoneNumber'],
      businessDescription: data['businessDescription'],
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
      fullName: firebaseUser.displayName,
      profileImageUrl: firebaseUser.photoURL,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      gender: null,
      dateOfBirth: null,
      roles: ['buyer'], // Default role on creation
      // Seller specific fields are null by default for new Firebase Auth users
      businessName: null,
      businessAddress: null,
      businessContactEmail: null,
      businessPhoneNumber: null,
      businessDescription: null,
    );
  }

  // Add copyWith for immutable updates
  User copyWith({
    String? id,
    String? email,
    String? username,
    String? roleName, // Include roleName in copyWith
    String? profileImageUrl,
    String? address,
    String? phoneNumber,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? fullName,
    String? gender,
    Timestamp? dateOfBirth,
    String? businessName,
    String? businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
    List<String>? roles,
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
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      roles: roles ?? this.roles,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessContactEmail: businessContactEmail ?? this.businessContactEmail,
      businessPhoneNumber: businessPhoneNumber ?? this.businessPhoneNumber,
      businessDescription: businessDescription ?? this.businessDescription,
    );
  }

  // --- Equality and Hashing ---
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username &&
          fullName == other.fullName &&
          gender == other.gender &&
          dateOfBirth == other.dateOfBirth &&
          profileImageUrl == other.profileImageUrl &&
          address == other.address &&
          phoneNumber == other.phoneNumber &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          businessName == other.businessName &&
          businessAddress == other.businessAddress &&
          businessContactEmail == other.businessContactEmail &&
          businessPhoneNumber == other.businessPhoneNumber &&
          businessDescription == other.businessDescription);

  @override
  int get hashCode => Object.hash(
    id,
    email,
    username,
    fullName,
    gender,
    dateOfBirth,
    profileImageUrl,
    address,
    phoneNumber,
    createdAt,
    updatedAt,
    businessName,
    businessAddress,
    businessContactEmail,
    businessPhoneNumber,
    businessDescription,
  );
}
