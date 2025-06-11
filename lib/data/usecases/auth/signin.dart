import 'package:e_commerce/data/models/user.dart'; // Your custom User model
import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Concrete auth service

/// Use case for user login.
class SignInUseCase {
  final FirebaseAuthService _authService;

  SignInUseCase(this._authService);

  /// Executes the sign-in process.
  Future<User?> call(String email, String password) async {
    // Business logic for sign-in, e.g., email format validation
    return await _authService.signInWithEmailAndPassword(email, password);
  }
}
