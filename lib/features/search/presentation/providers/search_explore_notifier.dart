import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinterest/features/search/domain/usecases/search_photos_usecase.dart';
import 'package:pinterest/features/search/presentation/providers/search_providers.dart';
import 'package:pinterest/features/search/presentation/widgets/featured_board_card.dart';
import 'package:pinterest/features/search/presentation/widgets/popular_category_section.dart';
import 'package:pinterest/features/search/presentation/widgets/taste_carousel.dart';

/// Notifier that fetches explore data for the search home screen.
///
/// Loads popular categories, taste carousel cards, and featured boards
/// all from the Pexels API search endpoint.
class SearchExploreNotifier extends AsyncNotifier<SearchExploreData> {
  @override
  Future<SearchExploreData> build() async {
    return _fetchExploreData();
  }

  Future<SearchExploreData> _fetchExploreData() async {
    final useCase = ref.read(searchPhotosUseCaseProvider);

    // Fetch data for popular categories in parallel
    final categoryQueries = [
      'Rain car snap',
      'Wallpaper aesthetic',
      'Tattoo ideas',
      'Easy drawings',
      'Valentines gift for boyfriend',
      'Profile picture',
    ];

    final tasteQueries = [
      'Quick breakfast recipes',
      'Home decor ideas',
      'Workout motivation',
      'Travel destinations',
      'Fashion outfits',
      'Nail art designs',
      'Hairstyle ideas',
    ];

    final boardQueries = [
      'European summer aesthetic',
      'Time for a spring reset',
      'Garden inspiration',
    ];

    // Fetch all simultaneously
    final categoryFutures = categoryQueries.map(
      (q) => useCase(SearchPhotosParams(query: q, page: 1, perPage: 4)),
    );

    final tasteFutures = tasteQueries.map(
      (q) => useCase(SearchPhotosParams(query: q, page: 1, perPage: 1)),
    );

    final boardFutures = boardQueries.map(
      (q) => useCase(SearchPhotosParams(query: q, page: 1, perPage: 3)),
    );

    final categoryResults = await Future.wait(categoryFutures);
    final tasteResults = await Future.wait(tasteFutures);
    final boardResults = await Future.wait(boardFutures);

    // Build popular categories
    final popularCategories = <PopularCategory>[];
    for (var i = 0; i < categoryResults.length; i++) {
      categoryResults[i].fold(
        (_) {},
        (result) {
          if (result.photos.isNotEmpty) {
            popularCategories.add(
              PopularCategory(
                title: categoryQueries[i],
                imageUrls:
                    result.photos.map((p) => p.src.medium).toList(),
              ),
            );
          }
        },
      );
    }

    // Build taste carousel cards
    final tasteCards = <TasteCard>[];
    for (var i = 0; i < tasteResults.length; i++) {
      tasteResults[i].fold(
        (_) {},
        (result) {
          if (result.photos.isNotEmpty) {
            final photo = result.photos.first;
            tasteCards.add(
              TasteCard(
                title: tasteQueries[i],
                imageUrl: photo.src.large,
                creatorName: photo.photographer,
              ),
            );
          }
        },
      );
    }

    // Build featured boards
    final creators = ['Travel', 'Inspiration', 'Garden'];
    final featuredBoards = <FeaturedBoard>[];
    for (var i = 0; i < boardResults.length; i++) {
      boardResults[i].fold(
        (_) {},
        (result) {
          if (result.photos.isNotEmpty) {
            featuredBoards.add(
              FeaturedBoard(
                title: boardQueries[i],
                creator: creators[i],
                pinCount: 80 + (i * 23),
                timeAgo: '2w',
                imageUrls:
                    result.photos.map((p) => p.src.medium).toList(),
                isVerified: i < 2,
              ),
            );
          }
        },
      );
    }

    return SearchExploreData(
      popularCategories: popularCategories,
      tasteCards: tasteCards,
      featuredBoards: featuredBoards,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchExploreData());
  }
}

/// Container for all search explore screen data.
class SearchExploreData {
  const SearchExploreData({
    required this.popularCategories,
    required this.tasteCards,
    required this.featuredBoards,
  });

  final List<PopularCategory> popularCategories;
  final List<TasteCard> tasteCards;
  final List<FeaturedBoard> featuredBoards;
}
