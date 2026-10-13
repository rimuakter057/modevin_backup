import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';
import '../session_events.dart';
import '../token_storage.dart';

/// Converts every DioException into one of our typed exceptions (exceptions.dart)
/// before it reaches services. On a 401 it also clears the stored token and
/// broadcasts [SessionEvents.unauthorized] so AuthController can log the user
/// out, without this layer depending on GetX/controllers directly.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final mapped = _map(err);
    if (mapped is UnauthorizedException) {
      await TokenStorage.instance.clear();
      SessionEvents.instance.emitUnauthorized();
    }
    handler.next(
      err.copyWith(error: mapped),
    );
  }

  Exception _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutExceptionApi();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException('Secure connection could not be established.');
      case DioExceptionType.cancel:
        return const UnknownApiException('Request was cancelled.');
      case DioExceptionType.badResponse:
        return _mapResponse(err);
      case DioExceptionType.unknown:
      default:
        return const NetworkException();
    }
  }

  Exception _mapResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    final message = _extractMessage(data) ?? 'Request failed';

    switch (statusCode) {
      case 400:
        return BadRequestException(message, errors: _extractErrors(data));
      case 401:
        return UnauthorizedException(message);
      case 404:
        return NotFoundException(message);
      case 500:
      case 502:
      case 503:
        return ServerException(message, statusCode: statusCode);
      default:
        return ServerException(message, statusCode: statusCode);
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['error']?.toString();
    }
    return null;
  }

  Map<String, dynamic>? _extractErrors(dynamic data) {
    if (data is Map<String, dynamic> && data['errors'] is Map<String, dynamic>) {
      return data['errors'] as Map<String, dynamic>;
    }
    return null;
  }
}
