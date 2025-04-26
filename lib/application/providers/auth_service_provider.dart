import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bugolytics/application/providers/auth_token_storage_provider.dart';
import 'package:bugolytics/application/utils/environments.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class AuthService {
  final Ref _ref;
  late final Dio _dio; //Dio instance only for authService. Other service will use DioClient, which will use AuthService::refreshToken in case of 401 response

  AuthService(this._ref) {
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
  }

  Future<void> register(String username, String email, String password, Set<String>? roles) async {
    try {
      await _dio.post('/auth/api/auth/signup', data: {
        'username': username,
        'email': email,
        'password': password,
        'roles': roles ?? ["user"],
      });
    } catch (e) {
      throw Exception("Registration failed");
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/api/auth/signin', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        await _ref
            .read(authTokenStorageProvider.notifier)
            .saveTokens(accessToken, refreshToken);
        print("Login executed successfully");
        print("Login response: $response");
        return true;
      } else {
        // TODO Handle different errors based on codes returned
        print("Error during login");
        return false;
      }
    } catch (e) {
      throw Exception("Login failed");
    }
  }

  Future<void> logout() async {
    await _ref.read(authTokenStorageProvider.notifier).clearTokens();
  }

  Future<bool> refreshToken() async {
    print("Calling refreshToken...");
    try {
      String? refreshToken =
          await _ref.read(authTokenStorageProvider.notifier).getRefreshToken();
      if (refreshToken == null) {
        await logout();
        return false;
      }
      final response = await _dio.post('/auth/api/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await _ref
            .read(authTokenStorageProvider.notifier)
            .saveTokens(newAccessToken, newRefreshToken);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      throw Exception("refresh token failed");
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken =
        await _ref.read(authTokenStorageProvider.notifier).getAccessToken();
    return accessToken != null;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
