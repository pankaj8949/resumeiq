/// Base exception class
abstract class AppException implements Exception {
  const AppException({this.message, this.code});

  final String? message;
  final String? code;

  @override
  String toString() => message ?? 'An unexpected error occurred';
}

/// Server exceptions
class ServerException extends AppException {
  const ServerException({super.message, super.code});
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException({super.message, super.code});
}

/// Network exceptions
class NetworkException extends AppException {
  const NetworkException({super.message, super.code});
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({super.message, super.code});
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({super.message, super.code});
}

/// API exceptions
class ApiException extends AppException {
  const ApiException({super.message, super.code});
}

/// File exceptions
class FileException extends AppException {
  const FileException({super.message, super.code});
}

