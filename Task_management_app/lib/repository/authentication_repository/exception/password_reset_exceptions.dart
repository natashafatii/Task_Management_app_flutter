import 'auth_exceptions.dart';

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

class VerificationCodeExpiredException extends PasswordResetException {
  const VerificationCodeExpiredException()
      : super('Verification code has expired', code: 'verification-code-expired');
}