import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// ========== EXCEPTION CLASSES ==========

// Base authentication exception
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, {this.code = 'unknown'});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

// Network related exceptions
class NetworkException extends AuthException {
  const NetworkException(String message, {String code = 'network-error'})
      : super(message, code: code);
}

// Generic authentication exceptions
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super('Invalid email or password', code: 'invalid-credentials');
}

class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super('User not found', code: 'user-not-found');
}

class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super('Email is already in use', code: 'email-already-in-use');
}

class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super('Password is too weak', code: 'weak-password');
}

class InvalidEmailException extends AuthException {
  const InvalidEmailException()
      : super('Email address is invalid', code: 'invalid-email');
}

class UserDisabledException extends AuthException {
  const UserDisabledException()
      : super('This account has been disabled', code: 'user-disabled');
}

class TooManyRequestsException extends AuthException {
  const TooManyRequestsException()
      : super('Too many attempts. Please try again later.',
      code: 'too-many-requests');
}

class OperationNotAllowedException extends AuthException {
  const OperationNotAllowedException()
      : super('This operation is not allowed', code: 'operation-not-allowed');
}

// Signup specific exceptions
class SignUpException extends AuthException {
  const SignUpException(String message, {String code = 'signup-error'})
      : super(message, code: code);
}

class SignUpEmailPasswordFailure extends SignUpException {
  const SignUpEmailPasswordFailure({String? message})
      : super(
    message ?? 'Failed to create account with email and password',
    code: 'signup-email-password-failure',
  );
}

class SignUpValidationException extends SignUpException {
  final Map<String, String> errors;

  const SignUpValidationException(this.errors)
      : super('Please fix the validation errors', code: 'validation-error');

  String getFieldError(String fieldName) => errors[fieldName] ?? '';

  bool hasError(String fieldName) => errors.containsKey(fieldName);
}

class TermsNotAcceptedException extends SignUpException {
  const TermsNotAcceptedException()
      : super('Please accept the terms and conditions',
      code: 'terms-not-accepted');
}

class PasswordMismatchException extends SignUpException {
  const PasswordMismatchException()
      : super('Passwords do not match', code: 'password-mismatch');
}

class InvalidFullNameException extends SignUpException {
  const InvalidFullNameException()
      : super('Please enter a valid full name', code: 'invalid-full-name');
}

// Login specific exceptions
class LoginException extends AuthException {
  const LoginException(String message, {String code = 'login-error'})
      : super(message, code: code);
}

class LoginEmailPasswordFailure extends LoginException {
  const LoginEmailPasswordFailure({String? message})
      : super(
    message ?? 'Failed to login with email and password',
    code: 'login-email-password-failure',
  );
}

class AccountNotVerifiedException extends LoginException {
  const AccountNotVerifiedException()
      : super('Please verify your email address before logging in',
      code: 'account-not-verified');
}

class IncorrectPasswordException extends LoginException {
  const IncorrectPasswordException()
      : super('Incorrect password', code: 'incorrect-password');
}

// Password reset specific exceptions
class PasswordResetException extends AuthException {
  const PasswordResetException(String message, {String code = 'password-reset-error'})
      : super(message, code: code);
}

class PasswordResetEmailFailure extends PasswordResetException {
  const PasswordResetEmailFailure({String? message})
      : super(
    message ?? 'Failed to send password reset email',
    code: 'password-reset-email-failure',
  );
}

class PasswordResetSMSFailure extends PasswordResetException {
  const PasswordResetSMSFailure({String? message})
      : super(
    message ?? 'Failed to send password reset SMS',
    code: 'password-reset-sms-failure',
  );
}

class InvalidPhoneNumberException extends PasswordResetException {
  const InvalidPhoneNumberException()
      : super('Please enter a valid phone number', code: 'invalid-phone-number');
}

class InvalidVerificationCodeException extends PasswordResetException {
  const InvalidVerificationCodeException()
      : super('Invalid verification code', code: 'invalid-verification-code');
}

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
  /// Throws [SignUpEmailPasswordFailure] on failure
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _log('🚀 Creating account for: $email');

      // Validate inputs
      _validateSignUpInputs(email, password, fullName);

      final UserCredential userCredential =
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Update user profile with display name
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.sendEmailVerification();
      await userCredential.user?.reload();

      _log('✅ Account created successfully for: $email');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      _log('❌ Sign up failed: ${e.code} - ${e.message}');
      throw _handleFirebaseSignUpError(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      _log('💥 Unexpected sign up error: $e');
      throw SignUpEmailPasswordFailure(
        message: 'Failed to create account. Please try again.',
      );
    }
  }

  /// Login with email and password
  /// Throws [LoginEmailPasswordFailure] on failure
  Future<User> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _log('🔐 Attempting login for: $email');

      _validateLoginInputs(email, password);

      final UserCredential userCredential =
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      // Check if email is verified
      if (!userCredential.user!.emailVerified) {
        _log('⚠️ Account not verified: $email');
        throw const AccountNotVerifiedException();
      }

      _log('✅ Login successful for: $email');
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      _log('❌ Login failed: ${e.code} - ${e.message}');
      throw _handleFirebaseLoginError(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      _log('💥 Unexpected login error: $e');
      throw LoginEmailPasswordFailure(
        message: 'Failed to sign in. Please try again.',
      );
    }
  }

  /// Send password reset email
  /// Throws [PasswordResetEmailFailure] on failure
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _log('📧 Sending password reset email to: $email');

      _validateEmail(email);

      await _firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );

      _log('✅ Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      _log('❌ Password reset failed: ${e.code} - ${e.message}');
      throw _handleFirebasePasswordResetError(e);
    } on AuthException {
      rethrow;
    } catch (e) {
      _log('💥 Unexpected password reset error: $e');
      throw PasswordResetEmailFailure(
        message: 'Failed to send reset email. Please try again.',
      );
    }
  }

  /// Send phone verification for password reset
  /// Throws [PasswordResetSMSFailure] on failure
  Future<void> sendPasswordResetSMS(String phoneNumber) async {
    try {
      _log('📱 Sending password reset SMS to: $phoneNumber');

      _validatePhoneNumber(phoneNumber);

      // Mock implementation - replace with actual Firebase phone auth
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success for demo
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final validNumbers = ['1234567890', '5555555555'];

      if (!validNumbers.contains(cleanNumber)) {
        throw const InvalidPhoneNumberException();
      }

      _log('✅ Password reset SMS sent to: $phoneNumber');
    } on AuthException {
      rethrow;
    } catch (e) {
      _log('💥 Password reset SMS error: $e');
      throw PasswordResetSMSFailure(
        message: 'Failed to send verification code. Please try again.',
      );
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
      throw AuthException('Failed to sign out. Please try again.');
    }
  }

  // Validation methods
  void _validateSignUpInputs(String email, String password, String fullName) {
    final errors = <String, String>{};

    if (fullName.trim().isEmpty || fullName.trim().length < 2) {
      errors['fullName'] = 'Please enter a valid full name';
    }

    if (!_isValidEmail(email)) {
      errors['email'] = 'Please enter a valid email address';
    }

    if (password.length < 6) {
      errors['password'] = 'Password must be at least 6 characters';
    } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(password)) {
      errors['password'] = 'Password should contain letters and numbers';
    }

    if (errors.isNotEmpty) {
      throw SignUpValidationException(errors);
    }
  }

  void _validateLoginInputs(String email, String password) {
    if (!_isValidEmail(email)) {
      throw const InvalidEmailException();
    }

    if (password.isEmpty) {
      throw const InvalidCredentialsException();
    }
  }

  void _validateEmail(String email) {
    if (!_isValidEmail(email)) {
      throw const InvalidEmailException();
    }
  }

  void _validatePhoneNumber(String phoneNumber) {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.length < 10) {
      throw const InvalidPhoneNumberException();
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  // Firebase error handling
  AuthException _handleFirebaseSignUpError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'invalid-email':
        return const InvalidEmailException();
      case 'operation-not-allowed':
        return const OperationNotAllowedException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'network-request-failed':
        return const NetworkException('Network error during sign up');
      default:
        return SignUpEmailPasswordFailure(message: e.message);
    }
  }

  AuthException _handleFirebaseLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-disabled':
        return const UserDisabledException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
        return const IncorrectPasswordException();
      case 'too-many-requests':
        return const TooManyRequestsException();
      case 'network-request-failed':
        return const NetworkException('Network error during login');
      default:
        return LoginEmailPasswordFailure(message: e.message);
    }
  }

  AuthException _handleFirebasePasswordResetError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const InvalidEmailException();
      case 'user-not-found':
        return const UserNotFoundException();
      case 'network-request-failed':
        return const NetworkException('Network error during password reset');
      default:
        return PasswordResetEmailFailure(message: e.message);
    }
  }

  // Additional methods
  Future<void> updateUserProfile({String? displayName, String? photoURL}) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _firebaseAuth.currentUser?.updatePhotoURL(photoURL);
      }
      await _firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException('Failed to update profile: ${e.message}');
    }
  }

  Future<String?> getUserIdToken() async {
    try {
      return await _firebaseAuth.currentUser?.getIdToken();
    } catch (e) {
      _log('💥 Failed to get user token: $e');
      return null;
    }
  }

  // Private logging method
  void _log(String message) {
    if (kDebugMode) {
      print('[AuthenticationRepository] $message');
    }
  }
}