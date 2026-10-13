import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request/response/error details — debug builds only, so nothing
/// sensitive (tokens, payloads) ever ends up in a release-mode log.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('➡️ [${options.method}] ${options.uri}');
      if (options.data != null) debugPrint('   body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ [${response.statusCode}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ [${err.response?.statusCode}] ${err.requestOptions.uri} — ${err.message}');
    }
    handler.next(err);
  }
}
