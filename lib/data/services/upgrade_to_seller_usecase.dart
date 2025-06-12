import 'package:e_commerce/data/models/user.dart';
import 'package:e_commerce/data/services/user_repo.dart';
import 'package:e_commerce/utils/logger.dart';

class UpgradeToSellerUseCase {
  final UserRepo _userRepository;

  UpgradeToSellerUseCase(this._userRepository);

  Future<void> call(
    User user,
    String businessName,
    String businessAddress,
  ) async {
    try {
      if (user.isSeller) {
        throw Exception('User is already a seller.');
      }

      final updatedRoles = List<String>.from(user.roles)..add('seller');

      // You can add businessName and businessAddress to the user model if you want to store them directly
      // For now, we are just updating the role.
      final updatedUser = user.copyWith(
        roles: updatedRoles,
        // Example: address: businessAddress, // if you want to use the main address field
      );

      await _userRepository.updateUser(updatedUser);
      appLogger.i('User ${user.id} upgraded to seller.');
    } catch (e) {
      appLogger.e('Error upgrading user to seller: $e');
      rethrow;
    }
  }
}
