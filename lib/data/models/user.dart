import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Represents a user in the application.
///
/// This model is designed to support multiple roles, allowing a single user account
/// to function as both a buyer and a seller, similar to platforms like Carousell.
class User {
  final String id; // This will be the Firebase Auth UID
  final String email;
  final String username;
  final List<String> roles; // e.g., ['buyer', 'seller']

  // Standard user profile fields (can be null)
  final String? fullName;
  final String? profileImageUrl;
  final String? address;
  final String? phoneNumber;
  final String? gender;
  final Timestamp? dateOfBirth;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  // Fields specific to sellers (nullable)
  final String? businessName;
  final String? businessAddress;
  final String? businessContactEmail;
  final String? businessPhoneNumber;
  final String? businessDescription;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.profileImageUrl,
    this.address,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.businessName,
    this.businessAddress,
    this.businessContactEmail,
    this.businessPhoneNumber,
    this.businessDescription,
  });

  /// A computed property to easily check if the user has a 'seller' role.
  bool get isSeller => roles.contains('seller');

  /// Converts a User object to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'roles': roles, // Storing the list of roles
      'profileImageUrl': profileImageUrl,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fullName': fullName,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      // Seller-specific fields
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
      // Ensure 'roles' is read as a list, defaulting to ['buyer'] if absent
      roles: List<String>.from(data['roles'] ?? ['buyer']),
      profileImageUrl: data['profileImageUrl'],
      address: data['address'],
      phoneNumber: data['phoneNumber'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      fullName: data['fullName'],
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'],
      // Assign seller-specific fields
      businessName: data['businessName'],
      businessAddress: data['businessAddress'],
      businessContactEmail: data['businessContactEmail'],
      businessPhoneNumber: data['businessPhoneNumber'],
      businessDescription: data['businessDescription'],
    );
  }

  /// Creates a minimal User object from a Firebase Auth User object.
  /// This is used when a user first signs up. They always start as a 'buyer'.
  factory User.fromFirebaseAuthUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? 'no-email@example.com',
      username: firebaseUser.displayName ?? 'New User',
      roles: ['buyer'], // All new users start as buyers
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
      fullName: firebaseUser.displayName,
      profileImageUrl: firebaseUser.photoURL,
    );
  }

  /// Creates a copy of the User object with updated fields.
  User copyWith({
    String? id,
    String? email,
    String? username,
    List<String>? roles,
    String? fullName,
    String? profileImageUrl,
    String? address,
    String? phoneNumber,
    String? gender,
    Timestamp? dateOfBirth,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? businessName,
    String? businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      roles: roles ?? this.roles,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      businessName: businessName ?? this.businessName,
      businessAddress: businessAddress ?? this.businessAddress,
      businessContactEmail: businessContactEmail ?? this.businessContactEmail,
      businessPhoneNumber: businessPhoneNumber ?? this.businessPhoneNumber,
      businessDescription: businessDescription ?? this.businessDescription,
    );
  }

  // // --- Equality and Hashing ---
  // @override
  // bool operator ==(Object other) =>
  //     identical(this, other) ||
  //     other is User &&
  //         runtimeType == other.runtimeType &&
  //         id == other.id &&
  //         email == other.email;

  // @override
  // int get hashCode => id.hashCode ^ email.hashCode;
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
