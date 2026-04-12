import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pinterest/core/base/base_exception.dart';
import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/data/datasources/home_local_datasource.dart';
import 'package:pinterest/features/home/data/datasources/home_remote_datasource.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';
import 'package:pinterest/features/home/data/repositories/home_repository_impl.dart';

class MockHomeRemoteDatasource extends Mock implements HomeRemoteDatasource {}

class MockHomeLocalDatasource extends Mock implements HomeLocalDatasource {}

void main() {
  late HomeRepositoryImpl repository;
  late MockHomeRemoteDatasource mockRemote;
  late MockHomeLocalDatasource mockLocal;

  setUp(() {
    mockRemote = MockHomeRemoteDatasource();
    mockLocal = MockHomeLocalDatasource();
    repository = HomeRepositoryImpl(
      remoteDatasource: mockRemote,
      localDatasource: mockLocal,
    );
  });

  const tPhotoModel = PhotoModel(
    id: 1,
    width: 800,
    height: 600,
    url: 'https://pexels.com/photo/1',
    photographer: 'John',
    photographerUrl: 'https://pexels.com/@john',
    photographerId: 100,
    avgColor: '#AABB',
    src: PhotoSrcModel(
      original: 'o.jpg',
      large2x: 'l2x.jpg',
      large: 'l.jpg',
      medium: 'm.jpg',
      small: 's.jpg',
      portrait: 'p.jpg',
      landscape: 'ls.jpg',
      tiny: 't.jpg',
    ),
    liked: false,
    alt: 'Test photo',
  );

  const tResponse = PexelsResponse(
    page: 1,
    perPage: 20,
    totalResults: 100,
    photos: [tPhotoModel],
  );

  group('getCuratedPhotos', () {
    test('should return photos when remote datasource succeeds', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => tResponse);
      when(() => mockLocal.cacheCuratedPhotos(any()))
          .thenAnswer((_) async {});

      final result =
          await repository.getCuratedPhotos(page: 1, perPage: 20);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (photos) {
          expect(photos.length, 1);
          expect(photos.first.id, 1);
          expect(photos.first.photographer, 'John');
        },
      );
    });

    test('should cache first page results', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => tResponse);
      when(() => mockLocal.cacheCuratedPhotos(any()))
          .thenAnswer((_) async {});

      await repository.getCuratedPhotos(page: 1, perPage: 20);

      verify(() => mockLocal.cacheCuratedPhotos([tPhotoModel])).called(1);
    });

    test('should not cache pages other than first', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => tResponse);

      await repository.getCuratedPhotos(page: 2, perPage: 20);

      verifyNever(() => mockLocal.cacheCuratedPhotos(any()));
    });

    test('should return cached data on network failure', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenThrow(const NetworkException());
      when(() => mockLocal.getCachedPhotos())
          .thenAnswer((_) async => [tPhotoModel]);

      final result = await repository.getCuratedPhotos(page: 1);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right with cached data'),
        (photos) => expect(photos.length, 1),
      );
    });

    test(
        'should return NetworkFailure when offline and no cache',
        () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenThrow(const NetworkException());
      when(() => mockLocal.getCachedPhotos())
          .thenThrow(const CacheException());

      final result = await repository.getCuratedPhotos(page: 1);

      expect(result, const Left(NetworkFailure()));
    });

    test('should return ServerFailure on server error', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenThrow(
        const ServerException(message: 'Server Error', statusCode: 500),
      );

      final result = await repository.getCuratedPhotos(page: 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.statusCode, 500);
        },
        (_) => fail('Should be Left'),
      );
    });

    test('should return RateLimitFailure on 429', () async {
      when(() => mockRemote.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenThrow(const RateLimitException());

      final result = await repository.getCuratedPhotos(page: 1);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<RateLimitFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('searchPhotos', () {
    test('should return photos on successful search', () async {
      when(() => mockRemote.searchPhotos(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => tResponse);

      final result = await repository.searchPhotos(
        query: 'nature',
        page: 1,
      );

      expect(result.isRight(), true);
    });

    test('should return NetworkFailure when offline', () async {
      when(() => mockRemote.searchPhotos(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenThrow(const NetworkException());

      final result = await repository.searchPhotos(
        query: 'cats',
        page: 1,
      );

      expect(result, const Left(NetworkFailure()));
    });
  });

  group('getPhotoById', () {
    test('should return photo on success', () async {
      when(() => mockRemote.getPhotoById(id: any(named: 'id')))
          .thenAnswer((_) async => tPhotoModel);

      final result = await repository.getPhotoById(id: 1);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be Right'),
        (photo) => expect(photo.id, 1),
      );
    });

    test('should return NetworkFailure when offline', () async {
      when(() => mockRemote.getPhotoById(id: any(named: 'id')))
          .thenThrow(const NetworkException());

      final result = await repository.getPhotoById(id: 1);

      expect(result, const Left(NetworkFailure()));
    });
  });
}
