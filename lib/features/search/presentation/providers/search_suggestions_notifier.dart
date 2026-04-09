import 'dart:math';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/search_suggestion_chips.dart';

/// Chip color palette for dynamic suggestions.
const _chipColors = [
  Color(0xFFE60023), // Pinterest red
  Color(0xFF2D6A4F), // Green
  Color(0xFF9B59B6), // Purple
  Color(0xFF3D405B), // Navy
  Color(0xFFE07A5F), // Coral
  Color(0xFF1B3A4B), // Dark teal
  Color(0xFF6D597A), // Mauve
  Color(0xFFBC4749), // Crimson
];

/// Related keywords mapped to common search terms.
/// These are used to generate contextual suggestion chips.
const _relatedKeywords = <String, List<String>>{
  'food': ['Recipes', 'Healthy', 'Pictures', 'Dessert', 'Ideas'],
  'drawing': ['Cute', 'Sketches', 'Ideas', 'Kids', 'Easy'],
  'tattoo': ['Small', 'Minimalist', 'Flowers', 'Meaningful', 'Ideas'],
  'wallpaper': ['Aesthetic', 'Dark', 'Cute', 'Nature', 'iPhone'],
  'outfit': ['Casual', 'Summer', 'Aesthetic', 'Ideas', 'Street'],
  'hair': ['Short', 'Color', 'Curly', 'Ideas', 'Aesthetic'],
  'nail': ['Acrylic', 'Short', 'Summer', 'Ideas', 'Aesthetic'],
  'room': ['Decor', 'Aesthetic', 'Small', 'Ideas', 'DIY'],
  'cake': ['Birthday', 'Aesthetic', 'Wedding', 'Ideas', 'Easy'],
  'art': ['Drawing', 'Painting', 'Aesthetic', 'Ideas', 'Easy'],
  'car': ['Interior', 'Aesthetic', 'Luxury', 'Modified', 'Ideas'],
  'anime': ['Aesthetic', 'Cute', 'Wallpaper', 'PFP', 'Art'],
  'travel': ['Destinations', 'Aesthetic', 'Beach', 'Europe', 'Ideas'],
  'fashion': ['Street', 'Aesthetic', 'Casual', 'Ideas', 'Summer'],
  'home': ['Decor', 'Interior', 'DIY', 'Modern', 'Ideas'],
  'wedding': ['Dress', 'Decoration', 'Ideas', 'Aesthetic', 'Outdoor'],
  'makeup': ['Natural', 'Tutorial', 'Ideas', 'Aesthetic', 'Glam'],
  'photo': ['Poses', 'Ideas', 'Aesthetic', 'Creative', 'Portrait'],
  'gift': ['Ideas', 'DIY', 'Birthday', 'Valentine', 'Cute'],
  'garden': ['Ideas', 'DIY', 'Small', 'Aesthetic', 'Flowers'],
};

/// Default fallback keywords for any query.
const _defaultKeywords = ['Ideas', 'Aesthetic', 'Inspiration', 'DIY', 'Cute'];

/// Notifier that generates dynamic suggestion chips based on query.
///
/// Fetches a thumbnail image for each suggestion from the Pexels API
/// to show alongside the chip label.
class SearchSuggestionsNotifier
    extends FamilyAsyncNotifier<List<SearchSuggestion>, String> {
  @override
  Future<List<SearchSuggestion>> build(String arg) async {
    if (arg.isEmpty) return [];
    return _fetchSuggestions(arg);
  }

  Future<List<SearchSuggestion>> _fetchSuggestions(String query) async {
    final keywords = _findRelatedKeywords(query);
    final useCase = ref.read(searchPhotosUseCaseProvider);
    final random = Random(query.hashCode);

    // Fetch a thumbnail for each keyword in parallel
    final futures = keywords.map((keyword) async {
      final combinedQuery = '$query $keyword';
      final result = await useCase(
        SearchPhotosParams(query: combinedQuery, page: 1, perPage: 1),
      );

      String imageUrl = '';
      result.fold(
        (_) {},
        (searchResult) {
          if (searchResult.photos.isNotEmpty) {
            imageUrl = searchResult.photos.first.src.tiny;
          }
        },
      );

      return SearchSuggestion(
        label: keyword,
        imageUrl: imageUrl,
        color: _chipColors[random.nextInt(_chipColors.length)],
      );
    });

    final suggestions = await Future.wait(futures);

    // Filter out suggestions that failed to get an image
    return suggestions.where((s) => s.imageUrl.isNotEmpty).toList();
  }

  List<String> _findRelatedKeywords(String query) {
    final lowerQuery = query.toLowerCase();

    // Find matching keyword set
    for (final entry in _relatedKeywords.entries) {
      if (lowerQuery.contains(entry.key)) {
        return entry.value.take(5).toList();
      }
    }

    return _defaultKeywords;
  }
}

/// Provider: dynamic suggestion chips based on current search query.
final searchSuggestionsProvider = AsyncNotifierProvider.family<
    SearchSuggestionsNotifier, List<SearchSuggestion>, String>(
  SearchSuggestionsNotifier.new,
);
