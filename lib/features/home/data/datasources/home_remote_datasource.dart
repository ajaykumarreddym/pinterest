import 'package:dio/dio.dart';

import 'package:pinterest/core/services/api/api_client.dart';
import 'package:pinterest/core/services/api/api_endpoints.dart';
import 'package:pinterest/core/services/api/network_error_handler.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';

/// Remote data source for home feed photos from Pexels API.
abstract class HomeRemoteDatasource {
  Future<PexelsResponse> getCuratedPhotos({
    required int page,
    int perPage = 20,
  });

  Future<PexelsResponse> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  });

  Future<PhotoModel> getPhotoById({required int id});
}

class HomeRemoteDatasourceImpl implements HomeRemoteDatasource {
  const HomeRemoteDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<PexelsResponse> getCuratedPhotos({
    required int page,
    int perPage = 20,
  }) async {
    AppLogger.info('📡 HomeRemoteDatasource.getCuratedPhotos(page: $page, perPage: $perPage)');
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.curated,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      AppLogger.info('✅ getCuratedPhotos success — got ${response.data?.keys.length} keys');
      final parsed = PexelsResponse.fromJson(response.data!);
      AppLogger.info('✅ Parsed ${parsed.photos.length} photos from page ${parsed.page}');
      return parsed;
    } on DioException catch (e) {
      AppLogger.error(
        '❌ getCuratedPhotos DioException',
        error: e,
        stackTrace: e.stackTrace,
      );
      throw NetworkErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error(
        '❌ getCuratedPhotos unexpected error: ${e.runtimeType}',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  @override
  Future<PexelsResponse> searchPhotos({
    required String query,
    required int page,
    int perPage = 20,
  }) async {
    AppLogger.info('📡 HomeRemoteDatasource.searchPhotos(query: "$query", page: $page)');
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiEndpoints.searchPhotos,
        queryParameters: {'query': query, 'page': page, 'per_page': perPage},
      );
      final parsed = PexelsResponse.fromJson(response.data!);
      AppLogger.info('✅ searchPhotos got ${parsed.photos.length} photos');
      return parsed;
    } on DioException catch (e) {
      AppLogger.error('❌ searchPhotos DioException', error: e, stackTrace: e.stackTrace);
      throw NetworkErrorHandler.handle(e);
    } catch (e, stack) {
      AppLogger.error('❌ searchPhotos unexpected error', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<PhotoModel> getPhotoById({required int id}) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiEndpoints.photoById}/$id',
      );
      return PhotoModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw NetworkErrorHandler.handle(e);
    }
  }
}
