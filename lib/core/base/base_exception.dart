/// Base exception for all app-specific exceptions.
abstract class BaseException implements Exception {
  const BaseException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends BaseException {
  const ServerException({required super.message, super.statusCode});
}

class NetworkException extends BaseException {
  const NetworkException({
    super.message = 'No internet connection',
  });
}

class CacheException extends BaseException {
  const CacheException({
    super.message = 'Cache error',
  });
}

class UnauthorizedException extends BaseException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.statusCode = 401,
  });
}

class RateLimitException extends BaseException {
  const RateLimitException({
    super.message = 'Rate limit exceeded. Please try again later.',
    super.statusCode = 429,
  });
}
