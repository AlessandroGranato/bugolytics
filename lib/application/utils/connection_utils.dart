import 'dart:io';

import 'package:bugolytics/application/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

//I created this utils to allow dio connection to trust self signed certificates, since my backend is selfSigned
Dio createDio({required String url, bool trustSelfCertificate = false}) {
  final _flutterSecureStorage = const FlutterSecureStorage();

  final Dio dio = Dio(BaseOptions(
    baseUrl: url,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
  ));

  // allow self-signed certificate
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => trustSelfCertificate;
    return client;
  };

  dio.interceptors.add(InterceptorsWrapper(
    onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401) {
        // Attempt to refresh token
        bool tokenRefreshed = await refreshToken();
        if (tokenRefreshed) {
          // Retry the original request
          final options = error.requestOptions;
          options.headers['Authorization'] =
              'Bearer ${await _flutterSecureStorage.read(key: "accessToken")}';
          final response = await dio.request(options.path, options: options);
          return handler.resolve(response);
        }
      }
      return handler.next(error);
    },
  ));

  return dio;
}

Future<bool> refreshToken() async {
    try {
      String? refreshToken =
          await _flutterSecureStorage.read(key: 'refreshToken');
      if (refreshToken == null) {
        //TODO TEST: handle login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await logout();
        return;
      }
      final response = await _dio.post('/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = jsonDecode(response.data)['accessToken'];
        final newRefreshToken = jsonDecode(response.data)['refreshToken'];
        await saveTokens(newAccessToken, newRefreshToken);
      } else {
        // TODO TEST: Handle token refresh failure, redirect to login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await logout();
      }
    } catch (e) {
      throw Exception("refresh token failed");
    }
  }
