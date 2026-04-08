import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/auth/domain/entities/user.dart';

/// Repository contract for authentication.
abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> loginWithGoogle();

  Future<Either<Failure, void>> logout();

  Either<Failure, User?> getCurrentUser();

  Future<Either<Failure, bool>> isAuthenticated();
}
