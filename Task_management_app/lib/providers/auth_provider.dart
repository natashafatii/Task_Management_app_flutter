import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ========== AUTHENTICATION REPOSITORY ==========
class AuthenticationRepository {
  final FirebaseAuth _firebaseAuth;

  AuthenticationRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Streams
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  Stream<User?> get userChanges => _firebaseAuth.userChanges();
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _log('🚀 Creating account for: $email');

      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Update user profile with display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(fullName);
        await userCredential.user!.sendEmailVerification();
        await userCredential.user!.reload();

        // Get the updated user
        final updatedUser = _firebaseAuth.currentUser;
        _log('✅ Account created successfully for: $email');
        return updatedUser!;
      }

      throw Exception('User creation failed');
    } on FirebaseAuthException catch (e) {
      _log('❌ Sign up failed: ${e.code} - ${e.message}');
      throw _handleFirebaseSignUpError(e);
    } catch (e) {
      _log('💥 Unexpected sign up error: $e');
      throw Exception('Failed to create account. Please try again.');
    }
  }

  /// Login with email and password
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log('🔐 Attempting login for: $email');

      final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      _log('✅ Login successful for: $email');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      _log('❌ Login failed: ${e.code} - ${e.message}');
      throw _handleFirebaseLoginError(e);
    } catch (e) {
      _log('💥 Unexpected login error: $e');
      throw Exception('Failed to sign in. Please try again.');
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _log('📧 Sending password reset email to: $email');

      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );

      _log('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _log('❌ Password reset failed: ${e.code} - ${e.message}');
      throw _handleFirebasePasswordResetError(e);
    } catch (e) {
      _log('💥 Unexpected password reset error: $e');
      throw Exception('Failed to send reset email. Please try again.');
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      _log('🚪 Signing out user');
      await _firebaseAuth.signOut();
      _log('✅ Sign out successful');
    } catch (e) {
      _log('💥 Sign out error: $e');
      throw Exception('Failed to sign out. Please try again.');
    }
  }

  // Firebase error handling
  Exception _handleFirebaseSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email is already registered. Please use a different email.');
      case 'invalid-email':
        return Exception('The email address is not valid. Please check and try again.');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled. Please contact support.');
      case 'weak-password':
        return Exception('The password is too weak. Please choose a stronger password.');
      case 'network-request-failed':
        return Exception('Network error. Please check your internet connection.');
      default:
        return Exception('Failed to create account: ${e.message}');
    }
  }

  Exception _handleFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('The email address is not valid. Please check and try again.');
      case 'user-disabled':
        return Exception('This account has been disabled. Please contact support.');
      case 'user-not-found':
        return Exception('No account found with this email. Please check or create a new account.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'too-many-requests':
        return Exception('Too many failed attempts. Please try again later.');
      case 'network-request-failed':
        return Exception('Network error. Please check your internet connection.');
      default:
        return Exception('Failed to sign in: ${e.message}');
    }
  }

  Exception _handleFirebasePasswordResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception('The email address is not valid. Please check and try again.');
      case 'user-not-found':
        return Exception('No account found with this email. Please check your email address.');
      case 'network-request-failed':
        return Exception('Network error. Please check your internet connection.');
      default:
        return Exception('Failed to send reset email: ${e.message}');
    }
  }

  // Private logging method
  void _log(String message) {
    if (kDebugMode) {
      print('[AuthenticationRepository] $message');
    }
  }
}

// ========== AUTH PROVIDER ==========
class AppAuthProvider with ChangeNotifier {
  final AuthenticationRepository _authRepo;

  bool _isLoading = false;
  String? _loginError;
  String? _signUpError;
  String? _resetError;
  bool _resetSuccess = false;

  AppAuthProvider({AuthenticationRepository? authRepo})
      : _authRepo = authRepo ?? AuthenticationRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get loginError => _loginError;
  String? get signUpError => _signUpError;
  String? get resetError => _resetError;
  bool get resetSuccess => _resetSuccess;
  User? get currentUser => _authRepo.currentUser;
  bool get isLoggedIn => _authRepo.isLoggedIn;
  Stream<User?> get authStateChanges => _authRepo.authStateChanges;

  // Set loading state manually
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      _log('🔐 Login attempt for: $email');
      _isLoading = true;
      _loginError = null;
      notifyListeners();

      await _authRepo.loginWithEmailAndPassword(
        email: email,
        password: password,
      );

      _loginError = null;
      _log('✅ Login successful!');
      return true;
    } catch (e) {
      _loginError = _extractErrorMessage(e);
      _log('❌ Login failed: $_loginError');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign Up with email and password
  Future<bool> signUp(String fullName, String email, String password) async {
    try {
      _isLoading = true;
      _signUpError = null;
      notifyListeners();

      await _authRepo.signUpWithEmailAndPassword(
        email: email,
        password: password,
        fullName: fullName,
      );

      _signUpError = null;
      _log('✅ Sign up successful for: $email');
      return true;
    } catch (e) {
      _signUpError = _extractErrorMessage(e);
      _log('❌ Sign up failed: $_signUpError');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot password method - Email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      _isLoading = true;
      _resetError = null;
      _resetSuccess = false;
      notifyListeners();

      await _authRepo.sendPasswordResetEmail(email);

      _resetSuccess = true;
      _resetError = null;
      _log('✅ Password reset email sent to: $email');
      return true;
    } catch (e) {
      _resetError = _extractErrorMessage(e);
      _resetSuccess = false;
      _log('❌ Password reset failed: $_resetError');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<bool> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authRepo.signOut();

      _clearAllErrors();
      _log('✅ Signed out successfully');
      return true;
    } catch (e) {
      _log('💥 Sign out error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error methods
  void clearLoginError() {
    _loginError = null;
    notifyListeners();
  }

  void clearSignUpError() {
    _signUpError = null;
    notifyListeners();
  }

  void clearResetState() {
    _resetError = null;
    _resetSuccess = false;
    notifyListeners();
  }

  void _clearAllErrors() {
    _loginError = null;
    _signUpError = null;
    _resetError = null;
    _resetSuccess = false;
  }

  // Extract error message from exception
  String _extractErrorMessage(dynamic e) {
    if (e is Exception) {
      String errorString = e.toString();
      // Remove "Exception: " prefix if present
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring(11);
      }
      return errorString;
    }
    return e.toString();
  }

  // Private logging method
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[$runtimeType] $message');
    }
  }
}