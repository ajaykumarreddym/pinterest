import 'package:dartz/dartz.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pinterest/features/auth/domain/entities/user.dart';
import 'package:pinterest/features/auth/domain/repositories/auth_repository.dart';

/// Repository implementation for auth.
///
/// Note: Clerk SDK sign-in/sign-out are handled directly via
/// [ClerkAuth.of(context)] in [AuthNotifier] because Clerk requires
/// BuildContext. This repository handles local token operations.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.localDatasource,
  });

  final AuthLocalDatasource localDatasource;

  @override
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Handled directly by AuthNotifier via ClerkAuth.of(context)
    return const Left(
      UnknownFailure(message: 'Use AuthNotifier.login() with BuildContext'),
    );
  }

  @override
  Future<Either<Failure, User>> loginWithGoogle() async {
    // Handled directly by AuthNotifier via ClerkAuth.of(context)
    return const Left(
      UnknownFailure(
        message: 'Use AuthNotifier.loginWithGoogle() with BuildContext',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDatasource.clearAuth();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, User?> getCurrentUser() {
    // Clerk user is accessed via ClerkAuth.of(context).user
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = localDatasource.getAuthToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Right(false);
    }
  }
}
