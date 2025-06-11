import 'package:e_commerce/data/models/user.dart'; // Your custom User model
import 'package:e_commerce/data/services/firebase_auth_service.dart'; // Concrete auth service

/// Use case for user registration.
class SignUpUseCase {
  final FirebaseAuthService _authService;

  SignUpUseCase(this._authService);

  /// Executes the sign-up process.
  Future<User?> call(String email, String password, String username) async {
    // Business logic for sign-up can go here, e.g., validation rules
    if (username.isEmpty) {
      throw Exception('Username cannot be empty.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }
    // Call the authentication service
    return await _authService.signUpWithEmailAndPassword(email, password, username);
  }
}
