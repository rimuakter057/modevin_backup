import 'exceptions.dart';

/// Domain-level failure shown to controllers/UI. Controllers never see raw
/// [Exception]s from Dio — only a [Failure], so error handling in the UI
/// layer is uniform regardless of what went wrong underneath.
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request took too long. Please try again.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Your session has expired. Please log in again.']);
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure(super.message, {this.errors});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'The requested resource was not found.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong. Please try again.']);
}

/// Maps a raw exception thrown by the network layer into a UI-safe [Failure].
Failure mapExceptionToFailure(Object error) {
  if (error is UnauthorizedException) return UnauthorizedFailure(error.message);
  if (error is NetworkException) return NetworkFailure(error.message);
  if (error is TimeoutExceptionApi) return TimeoutFailure(error.message);
  if (error is BadRequestException) {
    return ValidationFailure(error.message, errors: error.errors);
  }
  if (error is NotFoundException) return NotFoundFailure(error.message);
  if (error is ServerException) {
    return ServerFailure(error.message, statusCode: error.statusCode);
  }
  return UnknownFailure(error.toString());
}
