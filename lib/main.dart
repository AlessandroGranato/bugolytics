import 'package:bugolytics/application/providers/auth_token_storage_provider.dart';
import 'package:bugolytics/application/screens/main_screen.dart';
import 'package:bugolytics/application/utils/environments.dart';
import 'package:bugolytics/application/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  await dotenv.load(fileName: Environments.fileName);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var authState = ref.watch(authTokenStorageProvider);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: authState == AuthStatus.authenticated
          ? const MainScreen()
          : const AuthScreen(),
    );
  }
}
