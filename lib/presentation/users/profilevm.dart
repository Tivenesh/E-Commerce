import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // For current user ID
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:e_commerce/utils/logger.dart';
import 'dart:async'; // For StreamSubscription

import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Import FirebaseAuthService

/// ViewModel for the user profile screen.
class ProfileViewModel extends ChangeNotifier {
  final UserRepo _userRepository;
  final FirebaseAuthService _authService; // Add FirebaseAuthService dependency

  User? _currentUserProfile;
  User? get currentUserProfile => _currentUserProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<fb_auth.User?>?
  _authStateSubscription; // To listen to auth state changes
  StreamSubscription<User?>?
  _userProfileSubscription; // To listen to the specific user's profile

  ProfileViewModel(this._userRepository, this._authService) {
    appLogger.d(
      'ProfileViewModel: Constructor called. Initializing auth listener.',
    );
    _initAuthListener();
  }

  void _initAuthListener() {
    _authStateSubscription = _authService.authStateChanges.listen((
      fb_auth.User? user,
    ) {
      if (user != null) {
        appLogger.d(
          'ProfileViewModel: Auth state changed - User logged IN: ${user.uid}',
        );
        _subscribeToUserProfile(
          user.uid,
        ); // Subscribe to profile for the new user
      } else {
        appLogger.d(
          'ProfileViewModel: Auth state changed - User logged OUT. Clearing profile data.',
        );
        _currentUserProfile = null; // Clear profile data
        _userProfileSubscription
            ?.cancel(); // Cancel old user profile subscription
        _userProfileSubscription = null; // Clear subscription reference
        _isLoading = false; // Reset loading state
        _errorMessage = null; // Clear any errors
        notifyListeners(); // Notify UI about cleared data
      }
    });

    // Perform an initial check in case a user is already logged in when the VM is created
    final initialUser = _authService.currentUser;
    if (initialUser != null) {
      appLogger.d(
        'ProfileViewModel: Initial check - User already logged in: ${initialUser.uid}',
      );
      _subscribeToUserProfile(initialUser.uid);
    } else {
      appLogger.d('ProfileViewModel: Initial check - No user logged in.');
    }
  }

  /// Subscribes to the current authenticated user's profile from Firestore.
  /// This method is called when the authentication state changes.
  void _subscribeToUserProfile(String uid) {
    _userProfileSubscription
        ?.cancel(); // Cancel previous subscription if it exists
    appLogger.d('ProfileViewModel: Subscribing to user profile for UID: $uid');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _userProfileSubscription = _userRepository
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
                'ProfileViewModel: User profile document not found for UID: $uid',
              );
              _errorMessage = 'User profile not found.';
            }
            _isLoading = false;
            notifyListeners(); // Notify listeners whenever _currentUserProfile changes
          },
          onError: (e, stack) {
            _isLoading = false;
            _errorMessage = 'Error fetching profile: ${e.toString()}';
            notifyListeners();
            appLogger.e(
              'ProfileViewModel: Error in user profile stream for UID $uid: $e',
              error: e,
              stackTrace: stack,
            );
          },
          onDone:
              () =>
                  appLogger.i('ProfileViewModel: User profile stream closed.'),
        );
  }

  // OPTIONAL: Keep this public method if you want to allow explicit refresh from UI (e.g., RefreshIndicator)
  Future<void> fetchUserProfile() async {
    appLogger.d('ProfileViewModel: fetchUserProfile() called publicly.');
    final currentUid = _authService.currentUser?.uid;
    if (currentUid != null) {
      _subscribeToUserProfile(currentUid);
    } else {
      _currentUserProfile = null;
      _isLoading = false;
      _errorMessage = "No authenticated user.";
      notifyListeners();
    }
  }

  /// Updates the user's profile in Firestore.
  Future<void> updateProfile({
    String? username,
    String? address,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    appLogger.i(
      'ProfileViewModel: updateProfile received username: $username, address: $address, phoneNumber: $phoneNumber, URL: $profileImageUrl',
    );
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
      appLogger.d(
        'ProfileViewModel: Attempting to save updated profile to UserRepo for UID: ${updatedProfile.id} with URL: ${updatedProfile.profileImageUrl}',
      );
      await _userRepository.updateUser(updatedProfile);
      _isLoading = false;
      _errorMessage = null;
      // notifyListeners() will also be triggered by the stream listener in _subscribeToUserProfile
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

  @override
  void dispose() {
    appLogger.d(
      'ProfileViewModel: dispose() called. Cancelling all subscriptions.',
    );
    _authStateSubscription?.cancel();
    _userProfileSubscription?.cancel();
    super.dispose();
  }
}
