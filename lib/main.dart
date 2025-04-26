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

// Theme definitions
final lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF304475),
    brightness: Brightness.light,
  )
  // .copyWith(
  //   secondary: Color(0xFFFCFCFC),
  // )
  ,
  useMaterial3: true,
);

final darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF304475),
    brightness: Brightness.dark,
  )
  // .copyWith(
  //   secondary: Color(0xFFFCFCFC),
  // )
  ,
  useMaterial3: true,
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var authState = ref.watch(authTokenStorageProvider);

    printSchemeColors(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: authState == AuthStatus.authenticated
          ? const MainScreen()
          : const AuthScreen(),
    );
  }

  void printSchemeColors(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      print('--- Current ColorScheme ---');
      print('primary: ${colorScheme.primary}');
      print('onPrimary: ${colorScheme.onPrimary}');
      print('primaryContainer: ${colorScheme.primaryContainer}');
      print('onPrimaryContainer: ${colorScheme.onPrimaryContainer}');
      print('secondary: ${colorScheme.secondary}');
      print('onSecondary: ${colorScheme.onSecondary}');
      print('secondaryContainer: ${colorScheme.secondaryContainer}');
      print('onSecondaryContainer: ${colorScheme.onSecondaryContainer}');
      print('tertiary: ${colorScheme.tertiary}');
      print('onTertiary: ${colorScheme.onTertiary}');
      print('tertiaryContainer: ${colorScheme.tertiaryContainer}');
      print('onTertiaryContainer: ${colorScheme.onTertiaryContainer}');
      print('background: ${colorScheme.background}');
      print('onBackground: ${colorScheme.onBackground}');
      print('surface: ${colorScheme.surface}');
      print('onSurface: ${colorScheme.onSurface}');
      print('surfaceVariant: ${colorScheme.surfaceVariant}');
      print('onSurfaceVariant: ${colorScheme.onSurfaceVariant}');
      print('error: ${colorScheme.error}');
      print('onError: ${colorScheme.onError}');
      print('errorContainer: ${colorScheme.errorContainer}');
      print('onErrorContainer: ${colorScheme.onErrorContainer}');
      print('outline: ${colorScheme.outline}');
      print('outlineVariant: ${colorScheme.outlineVariant}');
      print('inverseSurface: ${colorScheme.inverseSurface}');
      print('onInverseSurface: ${colorScheme.onInverseSurface}');
      print('inversePrimary: ${colorScheme.inversePrimary}');
      print('shadow: ${colorScheme.shadow}');
      print('scrim: ${colorScheme.scrim}');
      print('surfaceTint: ${colorScheme.surfaceTint}');
    }
}
