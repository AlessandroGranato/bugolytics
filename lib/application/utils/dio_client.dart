import 'dart:io';

import 'package:bugolytics/application/providers/auth_token_storage_provider.dart';
import 'package:bugolytics/application/utils/environments.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static const bool trustSelfCertificate =
      true; // put as variable to remember that it's a custom config, but will remain at true
  late Dio dio;
  final _secureStorage = AuthTokenStorageProvider();

  // public constructor
  factory DioClient() {
    return _instance;
  }

  // private constructor
  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: Environments.boogleBackendUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));

    // allow self-signed certificate
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback =
          (cert, host, port) => trustSelfCertificate;
      return client;
    };

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = await _secureStorage.getAccessToken();
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
          bool tokenRefreshed = await refreshToken();
          if (tokenRefreshed) {
            // Retry the original request
            final options = error.requestOptions;
            options.headers['Authorization'] =
                'Bearer ${await _secureStorage.getAccessToken()}';
            final response = await dio.request(
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

  static Dio get instance => _instance.dio;

  Future<bool> refreshToken() async {
    try {
      String? refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        //TODO TEST: handle login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await _secureStorage.clearTokens();
        return false;
      }
      final response = await dio.post('/auth/api/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await _secureStorage.saveTokens(newAccessToken, newRefreshToken);
        return true;
      } else {
        // TODO TEST: Handle token refresh failure, redirect to login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await _secureStorage.clearTokens();
        return false;
      }
    } catch (e) {
      throw Exception("refresh token failed");
    }
  }
}
