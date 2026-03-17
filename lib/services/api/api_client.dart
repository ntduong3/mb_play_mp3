import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_error.dart';
import 'auth_token_store.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class ApiClient {
  final Dio _dio;
  final ApiConfig config;
  final AuthTokenStore tokenStore;

  ApiClient({
    required this.config,
    AuthTokenStore? tokenStore,
  })  : tokenStore = tokenStore ?? InMemoryTokenStore(),
        _dio = Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(AuthInterceptor(tokenStore: this.tokenStore));
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        maxRetries: config.maxRetries,
        retryDelay: config.retryDelay,
        maxRetryDelay: config.maxRetryDelay,
      ),
    );
    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
    ));
  }

  Future<void> setToken(String token) => tokenStore.saveToken(token);

  Future<void> clearToken() => tokenStore.clearToken();

  Future<Response<T>> request<T>(
    String path, {
    String method = 'GET',
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options?.copyWith(method: method) ?? Options(method: method),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return request<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return request<T>(
      path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
    );
  }
}