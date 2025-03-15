// import 'package:bugolytics/application/providers/secure_storage_provider.dart';
// import 'package:bugolytics/application/services/auth_service.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// enum AuthStatus { loading, authenticated, notAuthenticated }

// class AuthNotifierProvider extends StateNotifier<AuthStatus> {
//   final Ref _ref;

//   AuthNotifierProvider(this._ref) : super(AuthStatus.loading) {
//     _checkAuthStatus();
//   }

//   Future<void> _checkAuthStatus() async {
//     _ref.read(secureStorageProvider.notifier).isAuthenticated();
//     /*final isAuth = await ref.read.isAuthenticated();
//     state = isAuth ? AuthStatus.authenticated : AuthStatus.notAuthenticated;*/
//   }

//   Future<void> login(String username, String password) async {
//     state = AuthStatus.loading;
//     final isAuth = await _authService.login(username, password);
//     state = isAuth ? AuthStatus.authenticated : AuthStatus.notAuthenticated;
//   }

//   Future<void> logout() async {
//     await _authService.logout();
//     state = AuthStatus.notAuthenticated;
//   }
// }

// final authNotifierProvider =
//     StateNotifierProvider<AuthNotifierProvider, AuthStatus>(
//   (ref) => AuthNotifierProvider(AuthService()),
// );
