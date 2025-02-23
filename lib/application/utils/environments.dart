import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environments {
  static String get fileName => kReleaseMode ? ".env_prod" : ".env_dev";
  static String get test => dotenv.env['TEST'] ?? 'test-default';
  static String get boogleBackendUrl => dotenv.env['BOOGLE_BACKEND_URL'] ?? '';
}
