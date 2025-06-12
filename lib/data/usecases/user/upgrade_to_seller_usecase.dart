import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';

/// Use case for upgrading a user to a seller role.
///
/// This class encapsulates the business logic for the seller registration process,
/// acting as a bridge between the ViewModel and the User Repository.
class UpgradeToSellerUseCase {
  final UserRepo _userRepository;

  UpgradeToSellerUseCase(this._userRepository);

  /// Executes the use case.
  /// Takes the current user and their new business details.
  Future<void> call(
    User currentUser, {
    required String businessName,
    required String businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) async {
    // You could add more complex business logic here, e.g.,
    // - validation checks
    // - checking if the user is eligible for an upgrade
    // - logging analytics events

    await _userRepository.upgradeToSeller(
      currentUser.id,
      businessName: businessName,
      businessAddress: businessAddress,
      businessContactEmail: businessContactEmail,
      businessPhoneNumber: businessPhoneNumber,
      businessDescription: businessDescription,
    );
  }
}
