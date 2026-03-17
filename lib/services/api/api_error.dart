import 'package:dio/dio.dart';

enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  badRequest,
  server,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException($type, $statusCode, $message)';

  static ApiException fromDio(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          type: ApiErrorType.timeout,
          message: 'Request timeout',
          statusCode: status,
          data: data,
        );
      case DioExceptionType.cancel:
        return ApiException(
          type: ApiErrorType.cancelled,
          message: 'Request cancelled',
          statusCode: status,
          data: data,
        );
      case DioExceptionType.badResponse:
        return _fromStatus(status, data);
      case DioExceptionType.connectionError:
        return ApiException(
          type: ApiErrorType.network,
          message: 'No internet connection',
          statusCode: status,
          data: data,
        );
      case DioExceptionType.unknown:
      default:
        return ApiException(
          type: ApiErrorType.unknown,
          message: 'Unexpected error',
          statusCode: status,
          data: data,
        );
    }
  }

  static ApiException _fromStatus(int? status, dynamic data) {
    if (status == 400) {
      return ApiException(
        type: ApiErrorType.badRequest,
        message: 'Bad request',
        statusCode: status,
        data: data,
      );
    }
    if (status == 401) {
      return ApiException(
        type: ApiErrorType.unauthorized,
        message: 'Unauthorized',
        statusCode: status,
        data: data,
      );
    }
    if (status == 403) {
      return ApiException(
        type: ApiErrorType.forbidden,
        message: 'Forbidden',
        statusCode: status,
        data: data,
      );
    }
    if (status == 404) {
      return ApiException(
        type: ApiErrorType.notFound,
        message: 'Not found',
        statusCode: status,
        data: data,
      );
    }
    if (status != null && status >= 500) {
      return ApiException(
        type: ApiErrorType.server,
        message: 'Server error',
        statusCode: status,
        data: data,
      );
    }
    return ApiException(
      type: ApiErrorType.unknown,
      message: 'HTTP error',
      statusCode: status,
      data: data,
    );
  }
}