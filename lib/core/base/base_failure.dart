import 'package:equatable/equatable.dart';

/// Base failure class for Either left values in repository methods.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Unable to load cached data',
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired. Please log in again.',
  });
}

class RateLimitFailure extends Failure {
  const RateLimitFailure({
    super.message = 'Too many requests. Please wait.',
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong',
  });
}
