import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user.dart';
import '../../services/user_repo.dart';

class RegisterSellerUseCase {
  final UserRepo _userRepository;

  RegisterSellerUseCase(this._userRepository);

  Future<bool> execute({
    required String userId,
    required String businessName,
    required String businessAddress,
    required String businessContactEmail,
    required String businessPhoneNumber,
    String? businessDescription,
  }) async {
    try {
      // Get current user data
      final currentUser = await _userRepository.getUserById(userId);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Check if user is already a seller
      if (currentUser.isSeller) {
        throw Exception('User is already registered as a seller');
      }

      // Create updated user with seller role and business details
      final updatedRoles = List<String>.from(currentUser.roles)..add('seller');

      final updatedUser = currentUser.copyWith(
        businessName: businessName,
        businessAddress: businessAddress,
        businessContactEmail: businessContactEmail,
        businessPhoneNumber: businessPhoneNumber,
        businessDescription: businessDescription,
        roles: updatedRoles,
        updatedAt: Timestamp.now(),
      );

      // Update user in repository
      await _userRepository.updateUser(updatedUser);
      return true;
    } catch (e) {
      throw Exception('Failed to register as seller: ${e.toString()}');
    }
  }

  Future<bool> updateSellerInfo({
    required String userId,
    String? businessName,
    String? businessAddress,
    String? businessContactEmail,
    String? businessPhoneNumber,
    String? businessDescription,
  }) async {
    try {
      final currentUser = await _userRepository.getUserById(userId);
      if (currentUser == null) {
        throw Exception('User not found');
      }

      if (!currentUser.isSeller) {
        throw Exception('User is not registered as a seller');
      }

      final updatedUser = currentUser.copyWith(
        businessName: businessName ?? currentUser.businessName,
        businessAddress: businessAddress ?? currentUser.businessAddress,
        businessContactEmail:
            businessContactEmail ?? currentUser.businessContactEmail,
        businessPhoneNumber:
            businessPhoneNumber ?? currentUser.businessPhoneNumber,
        businessDescription:
            businessDescription ?? currentUser.businessDescription,
        updatedAt: Timestamp.now(),
      );

      await _userRepository.updateUser(updatedUser);
      return true;
    } catch (e) {
      throw Exception('Failed to update seller info: ${e.toString()}');
    }
  }
}
