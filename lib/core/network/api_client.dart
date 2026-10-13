import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'network_info.dart';

/// Single shared Dio instance for the whole app. Services call this instead
/// of constructing their own Dio, so base URL, timeouts, auth and error
/// handling stay consistent everywhere.
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([
        AuthInterceptor(),
        ErrorInterceptor(),
        LoggingInterceptor(),
      ]);
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) =>
      _guarded(() => _dio.get<T>(
            path,
            queryParameters: queryParameters,
            options: Options(extra: {'requiresAuth': requiresAuth}),
          ));

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    bool requiresAuth = true,
  }) =>
      _guarded(() => _dio.post<T>(
            path,
            data: data,
            options: Options(extra: {'requiresAuth': requiresAuth}),
          ));

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    bool requiresAuth = true,
  }) =>
      _guarded(() => _dio.patch<T>(
            path,
            data: data,
            options: Options(extra: {'requiresAuth': requiresAuth}),
          ));

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    bool requiresAuth = true,
  }) =>
      _guarded(() => _dio.delete<T>(
            path,
            data: data,
            options: Options(extra: {'requiresAuth': requiresAuth}),
          ));

  /// Fails fast with a clear [NetworkException] when offline, instead of
  /// letting the request hang until Dio's own connect timeout fires.
  Future<Response<T>> _guarded<T>(Future<Response<T>> Function() request) async {
    final isOnline = await NetworkInfo.instance.isConnected;
    if (!isOnline) {
      throw const NetworkException();
    }
    try {
      return await request();
    } on DioException catch (e) {
      // ErrorInterceptor already mapped e.error to a typed exception.
      if (e.error is Exception) throw e.error as Exception;
      rethrow;
    }
  }
}
