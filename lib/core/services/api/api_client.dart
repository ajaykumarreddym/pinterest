import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/config/environment.dart';
import 'package:pinterest/core/constants/api_constants.dart';
import 'package:pinterest/core/services/api/api_interceptors.dart';
import 'package:pinterest/core/utils/app_logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Centralized Dio HTTP client for Pexels API.
class ApiClient {
  ApiClient() {
    final apiKey = Environment.pexelsApiKey;

    AppLogger.info('🔧 ApiClient initializing...');
    AppLogger.info('   Base URL: ${ApiConstants.pexelsV1}');
    AppLogger.info('   API Key present: ${apiKey.isNotEmpty}');

    if (apiKey.isEmpty) {
      AppLogger.error('⚠️ PEXELS_API_KEY is EMPTY! Check your .env file.');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.pexelsV1,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      AuthInterceptor(),
      if (!Environment.isProduction) ApiLoggerInterceptor(),
      RetryInterceptor(),
    ]);

    AppLogger.info('✅ ApiClient initialized with ${_dio.interceptors.length} interceptors');
  }

  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post<T>(path, data: data, queryParameters: queryParameters);
  }
}

