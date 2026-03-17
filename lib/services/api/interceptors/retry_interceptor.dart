import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;
  final Duration maxRetryDelay;

  RetryInterceptor({
    required this.dio,
    required this.maxRetries,
    required this.retryDelay,
    required this.maxRetryDelay,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['retry'] as int?) ?? 0;
    if (attempt >= maxRetries || !_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final nextAttempt = attempt + 1;
    err.requestOptions.extra['retry'] = nextAttempt;

    await Future.delayed(_backoff(nextAttempt));

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.cancel) return false;

    final status = err.response?.statusCode;
    if (status != null) {
      return status == 408 ||
          status == 429 ||
          status == 500 ||
          status == 502 ||
          status == 503 ||
          status == 504;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }

  Duration _backoff(int attempt) {
    final baseMs = retryDelay.inMilliseconds;
    var delayMs = baseMs * (1 << (attempt - 1));
    final maxMs = maxRetryDelay.inMilliseconds;
    if (delayMs > maxMs) delayMs = maxMs;
    return Duration(milliseconds: delayMs);
  }
}