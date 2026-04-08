import 'package:pinterest/core/services/api/api_client.dart';
import 'package:pinterest/core/services/api/api_endpoints.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';

/// Remote datasource for search operations via Pexels API.
abstract class SearchRemoteDatasource {
  Future<PexelsResponse> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
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
}
