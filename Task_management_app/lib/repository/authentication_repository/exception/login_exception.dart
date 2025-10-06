import 'auth_exceptions.dart';

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