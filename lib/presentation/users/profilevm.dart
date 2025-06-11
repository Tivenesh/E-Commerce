import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // For current user ID
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:e_commerce/utils/logger.dart';

/// ViewModel for the user profile screen.
class ProfileViewModel extends ChangeNotifier {
  final UserRepo _userRepository;

  User? _currentUserProfile;
  User? get currentUserProfile => _currentUserProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel(this._userRepository) {
    _fetchUserProfile();
  }

  /// Fetches the current authenticated user's profile from Firestore.
  Future<void> _fetchUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _errorMessage = 'No authenticated user found.';
        _isLoading = false;
        notifyListeners();
        appLogger.w(
          'ProfileViewModel: No authenticated user to fetch profile for.',
        );
        return;
      }

      // Listen to real-time updates for the user's profile
      _userRepository.getUsers().listen(
        (users) {
          final user = users.firstWhere(
            (u) => u.id == uid,
            orElse:
                () => User(
                  id: uid,
                  email:
                      firebase_auth.FirebaseAuth.instance.currentUser?.email ??
                      'N/A',
                  username:
                      firebase_auth
                          .FirebaseAuth
                          .instance
                          .currentUser
                          ?.displayName ??
                      'New User',
                  createdAt: firestore.Timestamp.now(),
                  updatedAt: firestore.Timestamp.now(),
                ),
          );
          _currentUserProfile = user;
          _isLoading = false;
          _errorMessage = null;
          notifyListeners();
          appLogger.d('ProfileViewModel: User profile updated for $uid.');
        },
        onError: (error) {
          _isLoading = false;
          _errorMessage = 'Failed to load profile: ${error.toString()}';
          notifyListeners();
          appLogger.e(
            'ProfileViewModel: Error fetching user profile stream: $error',
            error: error,
          );
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      notifyListeners();
      appLogger.e(
        'ProfileViewModel: Unexpected error in _fetchUserProfile: $e',
        error: e,
      );
    }
  }

  /// Updates the user's profile in Firestore.
  Future<void> updateProfile({
    String? username,
    String? address,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUserProfile == null) {
      _errorMessage = 'No user profile to update.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProfile = _currentUserProfile!.copyWith(
        username: username,
        address: address,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        updatedAt: firestore.Timestamp.now(),
      );
      await _userRepository.updateUser(updatedProfile);
      _isLoading = false;
      _errorMessage = null;
      notifyListeners(); // Will also be triggered by stream listener in _fetchUserProfile
      appLogger.i('ProfileViewModel: User profile updated successfully.');
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
      appLogger.e(
        'ProfileViewModel: Error updating user profile: $e',
        error: e,
      );
    }
  }
}
