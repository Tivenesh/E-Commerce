import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:e_commerce/utils/logger.dart';
import 'package:e_commerce/data/models/user.dart'; 
import 'package:e_commerce/data/services/user_repo.dart'; 

/// A service class to handle all Firebase Authentication operations.
/// It also interacts with the UserRepository to manage the Firestore user profile.
class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final UserRepo _userRepository; // Dependency on your Firestore user repository

  FirebaseAuthService(this._userRepository);

  /// Exposes the real-time authentication state changes.
  /// Streams null if no user is signed in, or a firebase_auth.User if signed in.
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Exposes the current authenticated Firebase User.
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Signs up a new user with email and password.
  /// Also creates a corresponding User profile in Firestore.
  Future<User?> signUpWithEmailAndPassword(String email, String password, String username) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name immediately (optional)
        await firebaseUser.updateDisplayName(username);

        // Create a new User document in Firestore using the Firebase Auth UID
        final newUser = User.fromFirebaseAuthUser(firebaseUser).copyWith(
          username: username, // Ensure username is set from input
          email: email, // Ensure email is set from input
        );
        await _userRepository.addUser(newUser); // Add to Firestore via repository
        return newUser;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuth Exception during sign up: ${e.code} - ${e.message}');
      rethrow; // Re-throw to be handled by ViewModel/UI
    } catch (e) {
      print('Error during sign up: $e');
      rethrow;
    }
  }

  /// Signs in an existing user with email and password.
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Fetch the full User profile from Firestore
        final userProfile = await _userRepository.getUserById(firebaseUser.uid);
        if (userProfile != null) {
          return userProfile;
        } else {
          // If no Firestore profile exists (e.g., signed up externally or profile creation failed)
          // Create a new profile based on Firebase Auth user data.
          final newUserProfile = User.fromFirebaseAuthUser(firebaseUser);
          await _userRepository.addUser(newUserProfile);
          return newUserProfile;
        }
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuth Exception during sign in: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  /// Sends a password reset email to the given email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuth Exception sending password reset: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error sending password reset: $e');
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print('User signed out.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuth Exception during sign out: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Error during sign out: $e');
      rethrow;
    }
  }
}
