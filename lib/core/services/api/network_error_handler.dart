import 'dart:io';

import 'package:dio/dio.dart';

import 'package:pinterest/core/base/base_exception.dart';

/// Maps Dio errors to application exceptions.
class NetworkErrorHandler {
  const NetworkErrorHandler._();

  static BaseException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled');
      default:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return ServerException(
          message: error.message ?? 'Unknown error occurred',
        );
    }
  }

  static BaseException _handleStatusCode(Response? response) {
    final statusCode = response?.statusCode;
    final message =
        response?.statusMessage ?? 'An error occurred';

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 429:
        return const RateLimitException();
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'Server error',
            statusCode: statusCode,
          );
        }
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}
