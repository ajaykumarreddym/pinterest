import 'dart:io';

import 'package:dio/dio.dart';

import 'package:pinterest/config/environment.dart';
import 'package:pinterest/core/utils/app_logger.dart';

/// Attaches the Pexels API key to every request.
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = Environment.pexelsApiKey;
    handler.next(options);
  }
}

/// Retries failed requests with exponential backoff.
class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final shouldRetry = _isRetryable(err);
    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final extra = err.requestOptions.extra;
    final retryCount = (extra['retryCount'] as int?) ?? 0;

    if (retryCount >= _maxRetries) {
      handler.next(err);
      return;
    }

    final delay = Duration(seconds: 1 << retryCount);
    await Future<void>.delayed(delay);

    err.requestOptions.extra['retryCount'] = retryCount + 1;

    try {
      final dio = Dio();
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _isRetryable(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.error is SocketException ||
        (err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}

/// Full request/response/error logger — logs everything for debugging.
class ApiLoggerInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final separator = '═' * 60;
    AppLogger.info('''
$separator
📤 REQUEST
$separator
  Method : ${options.method}
  URL    : ${options.uri}
  Headers: ${_sanitizeHeaders(options.headers)}
  Query  : ${options.queryParameters}
  Data   : ${options.data ?? 'null'}
$separator''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final separator = '═' * 60;
    final data = response.data;
    final preview = data.toString();
    final truncated =
        preview.length > 500 ? '${preview.substring(0, 500)}...' : preview;

    AppLogger.info('''
$separator
📥 RESPONSE [${response.statusCode}]
$separator
  URL    : ${response.requestOptions.uri}
  Status : ${response.statusCode} ${response.statusMessage}
  Data   : $truncated
$separator''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final separator = '═' * 60;
    AppLogger.error('''
$separator
❌ API ERROR
$separator
  URL        : ${err.requestOptions.uri}
  Method     : ${err.requestOptions.method}
  Type       : ${err.type}
  Message    : ${err.message}
  Status     : ${err.response?.statusCode}
  Response   : ${err.response?.data}
  Headers TX : ${_sanitizeHeaders(err.requestOptions.headers)}
$separator''');
    handler.next(err);
  }

  /// Hide full API key in logs — show only first 8 chars.
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      final value = sanitized['Authorization']?.toString() ?? '';
      if (value.length > 8) {
        sanitized['Authorization'] = '${value.substring(0, 8)}...REDACTED';
      }
    }
    return sanitized;
  }
}
