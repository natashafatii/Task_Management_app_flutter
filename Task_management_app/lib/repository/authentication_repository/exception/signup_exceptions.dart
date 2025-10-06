import 'auth_exceptions.dart';

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