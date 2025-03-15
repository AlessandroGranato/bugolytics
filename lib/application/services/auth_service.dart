import 'package:bugolytics/application/providers/auth_token_storage_provider.dart';
import 'package:bugolytics/application/utils/dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService {
  final Ref ref;
  final _dio = DioClient.instance;

  AuthService(this.ref);

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

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/api/auth/signin', data: {
        'username': username,
        'password': password,
      });
      if (response.statusCode == 200) {
        final accessToken = response.data['accessToken'];
        final refreshToken = response.data['refreshToken'];
        await ref
            .read(authTokenStorageProvider.notifier)
            .saveTokens(accessToken, refreshToken);
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
    await ref.read(authTokenStorageProvider.notifier).clearTokens();
  }

  Future<bool> refreshToken() async {
    try {
      String? refreshToken =
          await ref.read(authTokenStorageProvider.notifier).getRefreshToken();
      if (refreshToken == null) {
        //TODO TEST: handle login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await logout();
        return false;
      }
      final response = await _dio.post('/auth/api/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'];
        final newRefreshToken = response.data['refreshToken'];
        await ref
            .read(authTokenStorageProvider.notifier)
            .saveTokens(newAccessToken, newRefreshToken);
        return true;
      } else {
        // TODO TEST: Handle token refresh failure, redirect to login. Try in this way: call here logout function and check if automatically return to login (after you write the part that connects main page to accessToken being not null)
        await logout();
        return false;
      }
    } catch (e) {
      throw Exception("refresh token failed");
    }
  }

  Future<bool> isAuthenticated() async {
    final accessToken =
        await ref.read(authTokenStorageProvider.notifier).getAccessToken();
    return accessToken != null;
  }
}
