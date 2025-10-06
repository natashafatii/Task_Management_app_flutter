import 'package:flutter/foundation.dart';

class SignupProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSuccess = false;

  String _fullName = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Getters
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;
  String get fullName => _fullName;
  String get email => _email;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  // Validation getters
  bool get isFullNameValid => _fullName.length >= 2;
  bool get isEmailValid {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(_email);
  }
  bool get isPasswordValid => _password.length >= 6;
  bool get isConfirmPasswordValid => _confirmPassword == _password && _confirmPassword.isNotEmpty;

  bool get isFormValid => isFullNameValid && isEmailValid && isPasswordValid && isConfirmPasswordValid;

  // Setters
  void setFullName(String value) {
    _fullName = value.trim();
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value.trim().toLowerCase();
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _confirmPassword = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Signup method
  Future<bool> signup() async {
    if (!isFormValid) {
      _errorMessage = 'Please fill all fields correctly';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = '';
      notifyListeners();

      _log('🚀 Starting signup process for: $_email');

      await Future.delayed(const Duration(seconds: 2));

      final success = await _mockSignupAPI(_fullName, _email, _password);

      if (success) {
        _isSuccess = true;
        _log('✅ Signup successful for: $_email');
        clearForm();
        return true;
      } else {
        _errorMessage = 'This email is already registered. Please try another email.';
        _log('❌ Signup failed - email already exists: $_email');
        return false;
      }
    } catch (error) {
      _errorMessage = 'Registration failed. Please check your connection and try again.';
      _log('💥 Signup error: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _mockSignupAPI(String fullName, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final existingEmails = ['existing@example.com', 'taken@gmail.com', 'test@example.com'];
    return !existingEmails.contains(email);
  }

  void clearForm() {
    _fullName = '';
    _email = '';
    _password = '';
    _confirmPassword = '';
    _errorMessage = '';
    _isSuccess = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  void clearSuccess() {
    _isSuccess = false;
    notifyListeners();
  }

  // Error message helpers
  String? getFullNameError() {
    if (_fullName.isEmpty) return null;
    return isFullNameValid ? null : 'Please enter a valid full name';
  }

  String? getEmailError() {
    if (_email.isEmpty) return null;
    return isEmailValid ? null : 'Please enter a valid email address';
  }

  String? getPasswordError() {
    if (_password.isEmpty) return null;
    return isPasswordValid ? null : 'Password must be at least 6 characters';
  }

  String? getConfirmPasswordError() {
    if (_confirmPassword.isEmpty) return null;
    return isConfirmPasswordValid ? null : 'Passwords do not match';
  }

  void _log(String message) {
    if (kDebugMode) {
      print('[SignupProvider] $message');
    }
  }
}