import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Concrete auth service

/// Use case for user logout.
class SignOutUseCase {
  final FirebaseAuthService _authService;

  SignOutUseCase(this._authService);

  /// Executes the sign-out process.
  Future<void> call() async {
    await _authService.signOut();
  }
}
