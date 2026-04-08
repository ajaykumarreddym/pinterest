import 'package:pinterest/core/base/base_exception.dart';

/// Maps Dio errors to domain exceptions.
class ApiExceptions {
  const ApiExceptions._();

  static BaseException fromStatusCode(int? statusCode, String message) {
    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 429:
        return RateLimitException(message: message);
      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(
            message: 'Server error: $message',
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
