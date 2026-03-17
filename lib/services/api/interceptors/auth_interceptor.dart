import 'package:dio/dio.dart';

import '../auth_token_store.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenStore tokenStore;

  AuthInterceptor({required this.tokenStore});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStore.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}