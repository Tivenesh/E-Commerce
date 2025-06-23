import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // For current user ID
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

      // Listen to the user stream for real-time updates
      _userRepository
          .getUserStream(uid)
          .listen(
            (user) {
              if (user != null) {
                _currentUserProfile = user;
                appLogger.i(
                  'ProfileViewModel: Fetched user profile: ${user.username}, URL: ${user.profileImageUrl}',
                );
              } else {
                _currentUserProfile = null;
                appLogger.w(
                  'ProfileViewModel: User profile not found for UID: $uid',
                );
              }
              _isLoading = false;
              _errorMessage = null;
              notifyListeners(); // Notify listeners whenever _currentUserProfile changes
            },
            onError: (e) {
              _isLoading = false;
              _errorMessage = 'Error fetching profile: ${e.toString()}';
              notifyListeners();
              appLogger.e(
                'ProfileViewModel: Error in user profile stream: $e',
                error: e,
              );
            },
            onDone:
                () => appLogger.i(
                  'ProfileViewModel: User profile stream closed.',
                ),
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

  // OPTIONAL: Make _fetchUserProfile public for explicit refresh if necessary
  Future<void> fetchUserProfile() async {
    await _fetchUserProfile();
  }

  /// Updates the user's profile in Firestore.
  Future<void> updateProfile({
    String? username,
    String? address,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    print(
      'DEBUG ProfileViewModel: updateProfile received URL: $profileImageUrl',
    ); // DEBUG
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
        profileImageUrl:
            profileImageUrl, // This is where it's assigned to the model
        updatedAt: firestore.Timestamp.now(),
      );
      print(
        'DEBUG ProfileViewModel: Attempting to save updated profile to UserRepo with URL: ${updatedProfile.profileImageUrl}',
      ); // DEBUG
      await _userRepository.updateUser(
        updatedProfile,
      ); // Make sure updateUser is called here
      _isLoading = false;
      _errorMessage = null;
      // notifyListeners() will also be triggered by the stream listener in _fetchUserProfile
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
