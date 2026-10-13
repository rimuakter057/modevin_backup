/// Raw, low-level exceptions thrown from the network layer (ApiClient/interceptors).
/// These are caught by services/repositories and mapped into [Failure]s before
/// reaching controllers/UI.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, {this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Session expired. Please log in again.']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutExceptionApi implements Exception {
  final String message;
  const TimeoutExceptionApi([this.message = 'Request timed out.']);

  @override
  String toString() => 'TimeoutExceptionApi: $message';
}

class BadRequestException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  const BadRequestException(this.message, {this.errors});

  @override
  String toString() => 'BadRequestException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

class UnknownApiException implements Exception {
  final String message;
  const UnknownApiException([this.message = 'Something went wrong.']);

  @override
  String toString() => 'UnknownApiException: $message';
}
