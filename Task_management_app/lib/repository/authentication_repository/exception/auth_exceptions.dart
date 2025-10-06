// Base authentication exception
class AuthException implements Exception {
  final String message;
  final String code;
  final StackTrace? stackTrace;

  const AuthException(this.message, {this.code = 'unknown', this.stackTrace});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

// Network related exceptions
class NetworkException extends AuthException {
  const NetworkException(String message, {String code = 'network-error'})
      : super(message, code: code);
}

class ServerException extends AuthException {
  const ServerException(String message, {String code = 'server-error'})
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