import 'package:e_commerce/data/services/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user.dart';
import '../../data/services/user_repo.dart';
import '../../data/usecases/auth/register_seller_usecase.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepo _userRepository;
  final RegisterSellerUseCase _registerSellerUseCase;

  ProfileViewModel(this._userRepository, this._registerSellerUseCase);

  // State variables
  User? _currentUserProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isRegistringSeller = false;

  // Getters
  User? get currentUserProfile => _currentUserProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRegistringSeller => _isRegistringSeller;
  bool get isSeller => _currentUserProfile?.isSeller ?? false;

  // Load current user profile
  Future<void> loadUserProfile() async {
    if (auth.FirebaseAuth.instance.currentUser == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = auth.FirebaseAuth.instance.currentUser!.uid;
      _currentUserProfile = await _userRepository.getUserById(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _currentUserProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? username,
    String? address,
    String? phoneNumber,
    String? gender,
    Timestamp? dateOfBirth,
    String? profileImageUrl,
  }) async {
    if (_currentUserProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _currentUserProfile!.copyWith(
        fullName: fullName ?? _currentUserProfile!.fullName,
        username: username ?? _currentUserProfile!.username,
        address: address ?? _currentUserProfile!.address,
        phoneNumber: phoneNumber ?? _currentUserProfile!.phoneNumber,
        gender: gender ?? _currentUserProfile!.gender,
        dateOfBirth: dateOfBirth ?? _currentUserProfile!.dateOfBirth,
        profileImageUrl:
            profileImageUrl ?? _currentUserProfile!.profileImageUrl,
        updatedAt: Timestamp.now(),
      );

      await _userRepository.updateUser(updatedUser);
      _currentUserProfile = updatedUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register as seller
  Future<bool> registerAsSeller({
    required String businessName,
    required String businessAddress,
    required String businessContactEmail,
    required String businessPhoneNumber,
    String? businessDescription,
  }) async {
    if (_currentUserProfile == null) return false;

    _isRegistringSeller = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _registerSellerUseCase.execute(
        userId: _currentUserProfile!.id,
        businessName: businessName,
        businessAddress: businessAddress,
        businessContactEmail: businessContactEmail,
        businessPhoneNumber: businessPhoneNumber,
        businessDescription: businessDescription,
      );

      if (success) {
        // Reload user profile to get updated data
        await loadUserProfile();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isRegistringSeller = false;
      notifyListeners();
    }
  }

  // Update seller information
  Future<bool> updateSellerInfo({
    String? businessName,
    String? businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) async {
    if (_currentUserProfile == null || !_currentUserProfile!.isSeller)
      return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _registerSellerUseCase.updateSellerInfo(
        userId: _currentUserProfile!.id,
        businessName: businessName,
        businessAddress: businessAddress,
        businessContactEmail: businessContactEmail,
        businessPhoneNumber: businessPhoneNumber,
        businessDescription: businessDescription,
      );

      if (success) {
        // Reload user profile to get updated data
        await loadUserProfile();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await auth.FirebaseAuth.instance.signOut();
      _currentUserProfile = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
