import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';
import 'package:pinterest/features/home/domain/usecases/get_curated_photos_usecase.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late GetCuratedPhotosUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetCuratedPhotosUseCase(mockRepository);
  });

  const tParams = GetCuratedPhotosParams(page: 1, perPage: 20);

  final tPhotos = [
    const Photo(
      id: 1,
      width: 800,
      height: 600,
      url: 'https://pexels.com/photo/1',
      photographer: 'John Doe',
      photographerUrl: 'https://pexels.com/@john',
      photographerId: 100,
      avgColor: '#AABBCC',
      src: PhotoSrc(
        original: 'https://images.pexels.com/1/original.jpg',
        large2x: 'https://images.pexels.com/1/large2x.jpg',
        large: 'https://images.pexels.com/1/large.jpg',
        medium: 'https://images.pexels.com/1/medium.jpg',
        small: 'https://images.pexels.com/1/small.jpg',
        portrait: 'https://images.pexels.com/1/portrait.jpg',
        landscape: 'https://images.pexels.com/1/landscape.jpg',
        tiny: 'https://images.pexels.com/1/tiny.jpg',
      ),
      liked: false,
      alt: 'A beautiful photo',
    ),
  ];

  group('GetCuratedPhotosUseCase', () {
    test('should return list of photos from repository on success', () async {
      when(() => mockRepository.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => Right(tPhotos));

      final result = await useCase(tParams);

      expect(result, Right(tPhotos));
      verify(() => mockRepository.getCuratedPhotos(page: 1, perPage: 20))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      when(() => mockRepository.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer(
        (_) async => const Left(NetworkFailure()),
      );

      final result = await useCase(tParams);

      expect(result, const Left(NetworkFailure()));
      verify(() => mockRepository.getCuratedPhotos(page: 1, perPage: 20))
          .called(1);
    });

    test('should return server failure on server error', () async {
      const failure = ServerFailure(
        message: 'Internal Server Error',
        statusCode: 500,
      );

      when(() => mockRepository.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => const Left(failure));

      final result = await useCase(tParams);

      expect(result, const Left(failure));
    });

    test('should pass correct parameters to repository', () async {
      const params = GetCuratedPhotosParams(page: 3, perPage: 10);

      when(() => mockRepository.getCuratedPhotos(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => const Right([]));

      await useCase(params);

      verify(() => mockRepository.getCuratedPhotos(page: 3, perPage: 10))
          .called(1);
    });
  });
}
