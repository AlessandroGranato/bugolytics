import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum AuthStatus {
  loading,
  authenticated,
  notAuthenticated,
}

class AuthTokenStorage extends StateNotifier<AuthStatus> {
  final String accessTokenKey = 'accessToken';
  final String refreshTokenKey = 'refreshToken';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthTokenStorage() : super(AuthStatus.loading) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isAuth = await getAccessToken();
    state =
        isAuth != null ? AuthStatus.authenticated : AuthStatus.notAuthenticated;
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
    state = AuthStatus.authenticated;
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    state = AuthStatus.notAuthenticated;
  }

  Future<bool> isAuthenticated() async {
    return state == AuthStatus.authenticated;
  }
}

final authTokenStorageProvider =
    StateNotifierProvider<AuthTokenStorage, AuthStatus>(
  (ref) => AuthTokenStorage(),
);
