import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class SignupController extends GetxController {
  // Reactive variables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isSuccess = false.obs;

  // Form fields
  var fullName = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  // Validation flags
  var isFullNameValid = false.obs;
  var isEmailValid = false.obs;
  var isPasswordValid = false.obs;
  var isConfirmPasswordValid = false.obs;

  // Password visibility
  var obscurePassword = true.obs;
  var obscureConfirmPassword = true.obs;

  // Form validation
  var isFormValid = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen to form field changes for real-time validation
    debounce(fullName, validateFullName, time: const Duration(milliseconds: 500));
    debounce(email, validateEmail, time: const Duration(milliseconds: 500));
    debounce(password, validatePassword, time: const Duration(milliseconds: 500));
    debounce(confirmPassword, validateConfirmPassword, time: const Duration(milliseconds: 500));
  }

  // Field validation methods
  void validateFullName(String value) {
    if (value.isEmpty) {
      isFullNameValid.value = false;
    } else if (value.length < 2) {
      isFullNameValid.value = false;
    } else {
      isFullNameValid.value = true;
    }
    _validateForm();
  }

  void validateEmail(String value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    isEmailValid.value = emailRegex.hasMatch(value);
    _validateForm();
  }

  void validatePassword(String value) {
    isPasswordValid.value = value.length >= 6;
    _validateForm();
    // Re-validate confirm password when password changes
    if (confirmPassword.value.isNotEmpty) {
      validateConfirmPassword(confirmPassword.value);
    }
  }

  void validateConfirmPassword(String value) {
    isConfirmPasswordValid.value = value == password.value && value.isNotEmpty;
    _validateForm();
  }

  void _validateForm() {
    isFormValid.value = isFullNameValid.value &&
        isEmailValid.value &&
        isPasswordValid.value &&
        isConfirmPasswordValid.value;
  }

  // Field updates
  void updateFullName(String value) {
    fullName.value = value.trim();
  }

  void updateEmail(String value) {
    email.value = value.trim().toLowerCase();
  }

  void updatePassword(String value) {
    password.value = value;
  }

  void updateConfirmPassword(String value) {
    confirmPassword.value = value;
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  // Signup method
  Future<bool> signup() async {
    if (!isFormValid.value) {
      errorMessage.value = 'Please fill all fields correctly';
      return false;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      _log('🚀 Starting signup process for: ${email.value}');

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock signup logic - replace with actual Firebase Auth
      final success = await _mockSignupAPI(
        fullName.value,
        email.value,
        password.value,
      );

      if (success) {
        isSuccess.value = true;
        _log('✅ Signup successful for: ${email.value}');

        // Clear form on success
        clearForm();
        return true;
      } else {
        errorMessage.value = 'This email is already registered. Please try another email.';
        _log('❌ Signup failed - email already exists: ${email.value}');
        return false;
      }
    } catch (error) {
      errorMessage.value = 'Registration failed. Please check your connection and try again.';
      _log('💥 Signup error: $error');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Mock API call - Replace with actual Firebase Auth
  Future<bool> _mockSignupAPI(String fullName, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock existing emails
    final existingEmails = ['existing@example.com', 'taken@gmail.com', 'test@example.com'];

    // Check if email already exists
    final emailExists = existingEmails.contains(email);

    return !emailExists;
  }

  // Clear form
  void clearForm() {
    fullName.value = '';
    email.value = '';
    password.value = '';
    confirmPassword.value = '';

    isFullNameValid.value = false;
    isEmailValid.value = false;
    isPasswordValid.value = false;
    isConfirmPasswordValid.value = false;

    errorMessage.value = '';
    isSuccess.value = false;
  }

  // Reset error
  void clearError() {
    errorMessage.value = '';
  }

  // Reset success
  void clearSuccess() {
    isSuccess.value = false;
  }

  // Get error messages for specific fields
  String? getFullNameError() {
    if (fullName.isEmpty) return null;
    return isFullNameValid.value ? null : 'Please enter a valid full name';
  }

  String? getEmailError() {
    if (email.isEmpty) return null;
    return isEmailValid.value ? null : 'Please enter a valid email address';
  }

  String? getPasswordError() {
    if (password.isEmpty) return null;
    return isPasswordValid.value ? null : 'Password must be at least 6 characters';
  }

  String? getConfirmPasswordError() {
    if (confirmPassword.isEmpty) return null;
    return isConfirmPasswordValid.value ? null : 'Passwords do not match';
  }

  // Private logging method
  void _log(String message) {
    if (kDebugMode) {
      print('[SignupController] $message');
    }
  }
}