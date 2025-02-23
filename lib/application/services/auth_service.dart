import 'dart:convert';

import 'package:bugolytics/application/utils/connection_utils.dart';
import 'package:bugolytics/application/utils/environments.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _dio = createDio(
    url: '${Environments.boogleBackendUrl}/auth/api/auth',
    trustSelfCertificate: true,
  );
  final _flutterSecureStorage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _flutterSecureStorage.write(key: 'accessToken', value: accessToken);
    await _flutterSecureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> register(
      String username, String email, String password, Set<String> roles) async {
    try {
      await _dio.post('/signup', data: {
        'username': username,
        'email': email,
        'password': password,
        'roles': roles,
      });
    } catch (e) {
      throw Exception("Registration failed");
    }
  }

  Future<void> login(String username, String password) async {
    try {
      final response = await _dio.post('/signin', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        final accessToken = jsonDecode(response.data)['accessToken'];
        final refreshToken = jsonDecode(response.data)['refreshToken'];
        await saveTokens(accessToken, refreshToken);
      } else {
        // TODO Handle different errors based on codes returned
      }
    } catch (e) {
      throw Exception("Login failed");
    }
  }

  Future<void> logout() async {
    await _flutterSecureStorage.delete(key: 'accessToken');
    await _flutterSecureStorage.delete(key: 'refreshToken');
  }

  Future<void> refreshToken() async {
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
}
