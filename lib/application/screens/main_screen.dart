import 'package:bugolytics/application/providers/auth_service_provider.dart';
import 'package:bugolytics/application/providers/bugo_data_shell_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  void _performLogout(AuthService authService) async {
    await authService.logout();
  }

  _printDevices(BugoDataShellService bugoDataShellService) {
    bugoDataShellService.getDevices();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(authServiceProvider);
    final bugoDataShellService = ref.read(bugoDataShellServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Main page")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _performLogout(authService),
                child: const Text("Logout"),
              ),
              ElevatedButton(
                onPressed: () => _printDevices(bugoDataShellService),
                child: const Text("Print devices"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
