import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/usecases/user/upgrade_to_seller_usecase.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/utils/logger.dart';

class SellerRegistrationViewModel with ChangeNotifier {
  final UpgradeToSellerUseCase _upgradeToSellerUseCase;
  final User _currentUser;

  SellerRegistrationViewModel({
    required UpgradeToSellerUseCase upgradeToSellerUseCase,
    required User currentUser,
  }) : _upgradeToSellerUseCase = upgradeToSellerUseCase,
       _currentUser = currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isRegistrationSuccessful = false;
  bool get isRegistrationSuccessful => _isRegistrationSuccessful;

  /// Attempts to register the user as a seller with the provided details.
  Future<void> registerAsSeller({
    required String businessName,
    required String businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isRegistrationSuccessful = false;
    notifyListeners();

    try {
      await _upgradeToSellerUseCase(
        _currentUser,
        businessName: businessName,
        businessAddress: businessAddress,
        businessContactEmail: businessContactEmail,
        businessPhoneNumber: businessPhoneNumber,
        businessDescription: businessDescription,
      );
      _isRegistrationSuccessful = true;
      appLogger.i('Seller registration successful for user ${_currentUser.id}');
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      appLogger.e('Seller registration error: $e', error: e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
