import 'package:dio/dio.dart';
import '../token_storage.dart';

/// Attaches the stored access token to every outgoing request, unless the
/// request has explicitly opted out via `options.extra['requiresAuth'] = false`
/// (e.g. login/register/refresh calls).
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] != false;
    if (requiresAuth) {
      final token = await TokenStorage.instance.accessToken;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }
}
