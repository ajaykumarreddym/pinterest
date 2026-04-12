import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pinterest/core/base/base_failure.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/home_repository.dart';
import 'package:pinterest/features/home/domain/usecases/search_photos_usecase.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late SearchPhotosUseCase useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = SearchPhotosUseCase(mockRepository);
  });

  final tPhotos = [
    const Photo(
      id: 2,
      width: 1024,
      height: 768,
      url: 'https://pexels.com/photo/2',
      photographer: 'Jane Smith',
      photographerUrl: 'https://pexels.com/@jane',
      photographerId: 200,
      avgColor: '#112233',
      src: PhotoSrc(
        original: 'https://images.pexels.com/2/original.jpg',
        large2x: 'https://images.pexels.com/2/large2x.jpg',
        large: 'https://images.pexels.com/2/large.jpg',
        medium: 'https://images.pexels.com/2/medium.jpg',
        small: 'https://images.pexels.com/2/small.jpg',
        portrait: 'https://images.pexels.com/2/portrait.jpg',
        landscape: 'https://images.pexels.com/2/landscape.jpg',
        tiny: 'https://images.pexels.com/2/tiny.jpg',
      ),
      liked: false,
      alt: 'Nature landscape',
    ),
  ];

  group('SearchPhotosUseCase', () {
    test('should return photos from repository on success', () async {
      final params = SearchPhotosParams(query: 'nature', page: 1);

      when(() => mockRepository.searchPhotos(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => Right(tPhotos));

      final result = await useCase(params);

      expect(result, Right(tPhotos));
      verify(() => mockRepository.searchPhotos(
            query: 'nature',
            page: 1,
            perPage: 20,
          )).called(1);
    });

    test('should return failure when search fails', () async {
      final params = SearchPhotosParams(query: 'cats', page: 1);

      when(() => mockRepository.searchPhotos(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer(
        (_) async => const Left(
          ServerFailure(message: 'Bad request', statusCode: 400),
        ),
      );

      final result = await useCase(params);

      expect(result.isLeft(), true);
    });

    test('should return empty list for no results', () async {
      final params = SearchPhotosParams(query: 'xyznonexistent', page: 1);

      when(() => mockRepository.searchPhotos(
            query: any(named: 'query'),
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
          )).thenAnswer((_) async => const Right([]));

      final result = await useCase(params);

      expect(result, const Right(<Photo>[]));
    });
  });
}
