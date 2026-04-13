sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

final class ServerException extends AppException {
  const ServerException([super.message = 'Something went wrong on the server.']);
  const ServerException.withMessage(super.message);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
  const AuthException.invalidCredentials()
      : super('Invalid email or password.');
  const AuthException.emailAlreadyInUse()
      : super('This email is already registered.');
  const AuthException.weakPassword()
      : super('Password must be at least 8 characters.');
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found.']);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Cache error occurred.']);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.'])
      : super();
}
