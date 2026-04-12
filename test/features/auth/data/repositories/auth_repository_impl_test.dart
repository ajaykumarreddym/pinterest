import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pinterest/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthLocalDatasource extends Mock implements AuthLocalDatasource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthLocalDatasource mockLocalDatasource;

  setUp(() {
    mockLocalDatasource = MockAuthLocalDatasource();
    repository = AuthRepositoryImpl(localDatasource: mockLocalDatasource);
  });

  group('AuthRepositoryImpl', () {
    group('logout', () {
      test('should clear local auth data and return Right(null)', () async {
        when(() => mockLocalDatasource.clearAuth())
            .thenAnswer((_) async {});

        final result = await repository.logout();

        expect(result, const Right(null));
        verify(() => mockLocalDatasource.clearAuth()).called(1);
      });

      test('should return failure when clearAuth throws', () async {
        when(() => mockLocalDatasource.clearAuth())
            .thenThrow(Exception('Storage error'));

        final result = await repository.logout();

        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<UnknownFailure>()),
          (_) => fail('Should be Left'),
        );
      });
    });

    group('isAuthenticated', () {
      test('should return true when token exists', () async {
        when(() => mockLocalDatasource.getAuthToken())
            .thenAnswer((_) async => 'valid_token');

        final result = await repository.isAuthenticated();

        expect(result, const Right(true));
      });

      test('should return false when token is null', () async {
        when(() => mockLocalDatasource.getAuthToken())
            .thenAnswer((_) async => null);

        final result = await repository.isAuthenticated();

        expect(result, const Right(false));
      });

      test('should return false when token is empty', () async {
        when(() => mockLocalDatasource.getAuthToken())
            .thenAnswer((_) async => '');

        final result = await repository.isAuthenticated();

        expect(result, const Right(false));
      });

      test('should return false on exception', () async {
        when(() => mockLocalDatasource.getAuthToken())
            .thenThrow(Exception('Failed'));

        final result = await repository.isAuthenticated();

        expect(result, const Right(false));
      });
    });

    group('getCurrentUser', () {
      test('should return Right(null) since Clerk handles user state',
          () {
        final result = repository.getCurrentUser();

        expect(result, const Right(null));
      });
    });

    group('loginWithEmail', () {
      test('should return Left since login is handled by AuthNotifier',
          () async {
        final result = await repository.loginWithEmail(
          email: 'test@test.com',
          password: 'password',
        );

        expect(result.isLeft(), true);
      });
    });

    group('loginWithGoogle', () {
      test('should return Left since Google login is handled by AuthNotifier',
          () async {
        final result = await repository.loginWithGoogle();

        expect(result.isLeft(), true);
      });
    });
  });
}
