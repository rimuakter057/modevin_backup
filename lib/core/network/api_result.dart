import '../errors/failures.dart';

/// Generic success/failure wrapper returned by every service method, so
/// controllers never deal with try/catch around raw Dio/SQLite calls.
sealed class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiSuccess<T>;
  factory ApiResult.failure(Failure failure) = ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is ApiSuccess<T>) return success(self.data);
    if (self is ApiFailure<T>) return failure(self.failure);
    throw StateError('Unreachable');
  }

  bool get isSuccess => this is ApiSuccess<T>;
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final Failure failure;
  const ApiFailure(this.failure);
}
