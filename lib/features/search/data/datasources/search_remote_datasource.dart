import 'package:pinterest/core/constants/api_constants.dart';
import 'package:pinterest/core/services/api/api_client.dart';
import 'package:pinterest/core/services/api/api_endpoints.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';
import 'package:pinterest/features/search/data/models/video_model.dart';

/// Remote datasource for search operations via Pexels API.
abstract class SearchRemoteDatasource {
  Future<PexelsResponse> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  });

  Future<PexelsVideoResponse> searchVideos({
    required String query,
    required int page,
    int perPage = 15,
  });
}

class SearchRemoteDatasourceImpl implements SearchRemoteDatasource {
  const SearchRemoteDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<PexelsResponse> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.searchPhotos,
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
      },
    );

    return PexelsResponse.fromJson(response.data!);
  }

  @override
  Future<PexelsVideoResponse> searchVideos({
    required String query,
    required int page,
    int perPage = 15,
  }) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '${ApiConstants.pexelsVideos}${ApiEndpoints.searchVideos}',
      queryParameters: {
        'query': query,
        'page': page,
        'per_page': perPage,
      },
    );

    return PexelsVideoResponse.fromJson(response.data!);
  }
}
