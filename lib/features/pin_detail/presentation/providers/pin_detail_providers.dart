import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/home/presentation/providers/home_providers.dart';
import 'package:pinterest/features/pin_detail/data/datasources/pin_detail_remote_datasource.dart';
import 'package:pinterest/features/pin_detail/data/repositories/pin_detail_repository_impl.dart';
import 'package:pinterest/features/pin_detail/domain/repositories/pin_detail_repository.dart';
import 'package:pinterest/features/pin_detail/domain/usecases/get_photo_by_id_usecase.dart';

// Datasource
final pinDetailRemoteDatasourceProvider =
    Provider<PinDetailRemoteDatasource>((ref) {
  return PinDetailRemoteDatasourceImpl(apiClient: ref.read(apiClientProvider));
});

// Repository
final pinDetailRepositoryProvider = Provider<PinDetailRepository>((ref) {
  return PinDetailRepositoryImpl(
    remoteDatasource: ref.read(pinDetailRemoteDatasourceProvider),
  );
});

// UseCase
final getPhotoByIdUseCaseProvider = Provider<GetPhotoByIdUseCase>((ref) {
  return GetPhotoByIdUseCase(ref.read(pinDetailRepositoryProvider));
});

// Photo detail by ID (family provider for different pin IDs)
final pinDetailProvider =
    FutureProvider.family<Photo, int>((ref, id) async {
  final useCase = ref.read(getPhotoByIdUseCaseProvider);
  final result = await useCase(GetPhotoByIdParams(id: id));
  return result.fold(
    (failure) => throw failure,
    (photo) => photo,
  );
});

/// Fetches related/similar photos based on search keywords derived
/// from the pin's alt text or photographer name.
///
/// Uses the Pexels search API with keywords extracted from the pin's
/// description to find visually/contextually similar content —
/// just like Pinterest's "More like this" section.
final relatedPhotosProvider =
    FutureProvider.family<List<Photo>, ({int pinId, String query})>(
  (ref, params) async {
    final useCase = ref.read(searchPhotosUseCaseProvider);

    // Extract meaningful search keywords from the alt text.
    final searchQuery = _extractSearchQuery(params.query);

    if (searchQuery.isEmpty) {
      // Fallback: if no alt text, return curated photos.
      return [];
    }

    final result = await useCase(
      SearchPhotosParams(
        query: searchQuery,
        page: 1,
        perPage: 20,
      ),
    );

    return result.fold(
      (failure) => <Photo>[],
      (photos) {
        // Exclude the current pin from related results.
        return photos.where((p) => p.id != params.pinId).toList();
      },
    );
  },
);

/// Extracts a meaningful search query from the photo's alt text.
///
/// Pexels alt text is typically descriptive (e.g. "Photo of a white
/// cat sitting on a wooden table"). We extract the key content words
/// to use as a search query for finding related images.
String _extractSearchQuery(String altText) {
  if (altText.isEmpty) return '';

  // Remove common filler words that don't help with image search.
  final stopWords = {
    'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'for', 'is', 'are',
    'was', 'were', 'with', 'and', 'or', 'but', 'from', 'by', 'as', 'it',
    'its', 'this', 'that', 'these', 'those', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'shall', 'can', 'photo', 'image', 'picture',
    'stock', 'free', 'images', 'photos', 'photography',
  };

  final words = altText
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2 && !stopWords.contains(w))
      .take(4) // Take top 4 meaningful words for focused results
      .toList();

  return words.join(' ');
}
