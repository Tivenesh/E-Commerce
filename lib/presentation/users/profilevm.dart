import 'dart:async';
// ** FIX: Import Cloud Firestore to use the Timestamp class **
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/data/usecases/auth/signout.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:e_commerce/utils/logger.dart';

/// ViewModel for the user's profile screen.
/// Manages the current user's state, profile updates, and signing out.
class ProfileViewModel extends ChangeNotifier {
  final UserRepo _userRepository;
  final SignOutUseCase _signOutUseCase;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  StreamSubscription? _userSubscription;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  ProfileViewModel({
    required UserRepo userRepository,
    required SignOutUseCase signOutUseCase,
  }) : _userRepository = userRepository,
       _signOutUseCase = signOutUseCase {
    _listenToAuthState();
  }

  void _listenToAuthState() {
    _firebaseAuth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _listenToUserProfile(firebaseUser.uid);
      } else {
        _currentUser = null;
        _userSubscription?.cancel();
        notifyListeners();
      }
    });
  }

  void _listenToUserProfile(String uid) {
    _isLoading = true;
    notifyListeners();
    _userSubscription = _userRepository
        .getUserStream(uid)
        .listen(
          (user) {
            _currentUser = user;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
            appLogger.d(
              'ProfileViewModel: User profile updated for ${user?.email}',
            );
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Failed to load profile: ${error.toString()}';
            appLogger.e('ProfileViewModel: Error listening to profile: $error');
            notifyListeners();
          },
        );
  }

  /// Updates the current user's profile information.
  Future<void> updateProfile({
    required String username,
    required String fullName,
    required String address,
    required String phoneNumber,
    required String profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _currentUser!.copyWith(
        username: username,
        fullName: fullName,
        address: address,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
        // ** FIX: Use Timestamp.now() instead of DateTime.now() **
        updatedAt: Timestamp.now(),
      );
      await _userRepository.updateUser(updatedUser);
      appLogger.i('Profile updated successfully for user ${_currentUser!.id}');
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      appLogger.e('Error updating profile: $e');
      // Re-throw so the view can catch it
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _signOutUseCase();
      _userSubscription?.cancel();
      _currentUser = null;
      appLogger.i('ProfileViewModel: User signed out.');
    } catch (e) {
      appLogger.e('Error signing out: $e');
    }
    // No need to notify listeners, the auth stream will handle UI changes
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
