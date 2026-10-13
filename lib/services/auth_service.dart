import '../core/errors/failures.dart';
import '../core/network/api_client.dart';
import '../core/network/api_result.dart';
import '../core/network/api_url.dart';
import '../core/network/token_storage.dart';

/// Talks to the auth endpoints only. Returns ApiResult<T> so callers
/// (controllers/repositories) never need a try/catch — every failure is
/// already mapped to a UI-safe [Failure].
///
/// Not wired into AuthController yet — AuthController still runs on local
/// SQLite mock data. This is the first endpoint to migrate once the backend
/// is reachable (see collection.json → "01. Authentication & Sessions").
class AuthService {
  final _client = ApiClient.instance;

  Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        ApiUrl.login,
        data: {'email': email, 'password': password},
        requiresAuth: false,
      );
      final data = response.data!;
      await TokenStorage.instance.saveTokens(
        accessToken: data['accessToken'] as String,
        refreshToken: data['refreshToken'] as String?,
      );
      return ApiResult.success(data);
    } catch (e) {
      return ApiResult.failure(mapExceptionToFailure(e));
    }
  }

  Future<ApiResult<void>> logout() async {
    try {
      await _client.post<void>(ApiUrl.logout);
      await TokenStorage.instance.clear();
      return ApiResult.success(null);
    } catch (e) {
      await TokenStorage.instance.clear();
      return ApiResult.failure(mapExceptionToFailure(e));
    }
  }
}
