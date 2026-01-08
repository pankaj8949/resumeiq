import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handling
class ErrorHandler {
  ErrorHandler._();
  static final Logger _logger = Logger();

  /// Convert exceptions to failures
  static Failure mapExceptionToFailure(dynamic exception) {
    _logger.e('Exception occurred', error: exception, stackTrace: StackTrace.current);

    if (exception is AppException) {
      return _mapAppExceptionToFailure(exception);
    }

    if (exception is FirebaseAuthException) {
      return AuthFailure(
        message: exception.message ?? 'Authentication failed',
        code: exception.code,
      );
    }

    if (exception is PlatformException) {
      // Handle Google Sign-In specific errors
      if (exception.code == 'sign_in_failed') {
        final message = exception.message ?? '';
        if (message.contains('ApiException: 10') || message.contains('DEVELOPER_ERROR')) {
          return AuthFailure(
            message: 'Developer configuration error. Please add SHA-1 fingerprint to Firebase Console. See GOOGLE_SIGNIN_FIX.md for details.',
            code: 'DEVELOPER_ERROR',
          );
        }
        return AuthFailure(
          message: message.isNotEmpty ? message : 'Google Sign-In failed',
          code: exception.code,
        );
      }
      return ApiFailure(
        message: exception.message ?? 'Platform error occurred',
        code: exception.code,
      );
    }

    if (exception is Exception) {
      return UnknownFailure(
        message: exception.toString(),
      );
    }

    return UnknownFailure(
      message: 'An unexpected error occurred',
    );
  }

  static Failure _mapAppExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        return ServerFailure(
          message: exception.message,
          code: exception.code,
        );
      case NetworkException:
        return NetworkFailure(
          message: exception.message,
          code: exception.code,
        );
      case CacheException:
        return CacheFailure(
          message: exception.message,
          code: exception.code,
        );
      case AuthException:
        return AuthFailure(
          message: exception.message,
          code: exception.code,
        );
      case ValidationException:
        return ValidationFailure(
          message: exception.message,
          code: exception.code,
        );
      case ApiException:
        return ApiFailure(
          message: exception.message,
          code: exception.code,
        );
      case FileException:
        return FileFailure(
          message: exception.message,
          code: exception.code,
        );
      default:
        return UnknownFailure(
          message: exception.message,
          code: exception.code,
        );
    }
  }

  /// Get user-friendly error message
  static String getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      case ServerFailure:
        return failure.message ?? 'Server error. Please try again later.';
      case AuthFailure:
        return failure.message ?? 'Authentication failed. Please try again.';
      case ValidationFailure:
        return failure.message ?? 'Invalid input. Please check your data.';
      case ApiFailure:
        return failure.message ?? 'API error. Please try again.';
      case FileFailure:
        return failure.message ?? 'File error. Please try again.';
      case PermissionFailure:
        return failure.message ?? 'Permission denied. Please grant required permissions.';
      default:
        return failure.message ?? 'An unexpected error occurred. Please try again.';
    }
  }
}

