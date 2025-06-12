import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/usecases/user/upgrade_to_seller_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/data/services/user_repo.dart';

class SellerRegistrationViewModel extends ChangeNotifier {
  final UpgradeToSellerUseCase _upgradeToSellerUseCase;
  final UserRepo _userRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isRegistrationSuccessful = false;
  bool get isRegistrationSuccessful => _isRegistrationSuccessful;

  User? _currentUser;

  SellerRegistrationViewModel(
    this._upgradeToSellerUseCase,
    this._userRepository,
  ) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _currentUser = await _userRepository.getUserById(userId);
    }
  }

  Future<void> registerAsSeller(
    String businessName,
    String businessAddress,
  ) async {
    await _loadCurrentUser(); // Ensure we have the latest user data
    if (_currentUser == null) {
      _errorMessage = 'User not found. Please relogin.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _isRegistrationSuccessful = false;
    notifyListeners();

    try {
      await _upgradeToSellerUseCase(
        _currentUser!,
        businessName,
        businessAddress,
      );
      _isRegistrationSuccessful = true;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
