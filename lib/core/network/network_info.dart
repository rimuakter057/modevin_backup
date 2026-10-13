import 'package:connectivity_plus/connectivity_plus.dart';

/// Thin wrapper over connectivity_plus so ApiClient/services can check
/// "are we online" before firing a request, and fail fast with a clear
/// NetworkFailure instead of waiting for a Dio timeout.
class NetworkInfo {
  NetworkInfo._();
  static final NetworkInfo instance = NetworkInfo._();

  final Connectivity _connectivity = Connectivity();

  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}
