import 'dart:io';

import 'package:bugolytics/application/providers/auth_service_provider.dart';
import 'package:bugolytics/application/providers/auth_token_storage_provider.dart';
import 'package:bugolytics/application/utils/environments.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DioClient {
  final Ref _ref;
  late final Dio
      _dio; //Dio instance used by all the services expect for authService.

  DioClient(this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: Environments.boogleBackendUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // allow self-signed certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (cert, host, port) => true; // true to skip certificate verification
      return client;
    };

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken =
            await _ref.read(authTokenStorageProvider.notifier).getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        print('Request: ${options.method} ${options.uri}');
        print('Request Headers: ${options.headers}');
        print('Request Body: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response status code: ${response.statusCode}');
        print('Response data: ${response.data}');
        return handler.next(response); // continue with the response
      },
      onError: (DioException error, handler) async {
        if (error.response?.statusCode == 401) {
          // Attempt to refresh token
          bool tokenRefreshed =
              await _ref.read(authServiceProvider).refreshToken();
          if (tokenRefreshed) {
            // Retry the original request
            final options = error.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${await _ref.read(authTokenStorageProvider.notifier).getAccessToken()}';
            final response = await _dio.request(
              options.path,
              data: options.data,
              queryParameters: options.queryParameters,
              options: Options(
                method: options.method,
                headers: options.headers,
                contentType: options.contentType,
                responseType: options.responseType,
              ),
            );
            return handler.resolve(response);
          }
        }
        return handler.next(error);
      },
    ));
  }

  // Method to return the configured Dio instance
  Dio get dio => _dio;
}

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref);
});
