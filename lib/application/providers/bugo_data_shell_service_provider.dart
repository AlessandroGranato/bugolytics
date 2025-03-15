import 'package:bugolytics/application/providers/dio_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugoDataShellService {
  final Dio _dio;

  BugoDataShellService(Ref ref) : _dio = ref.read(dioClientProvider).dio;

  Future<void> getDevices() async {
    try {
      final response = await _dio.get('/bds/api/devices');
      print(response);
    } catch (e) {
      throw Exception("get devices failed");
    }
  }
}

final bugoDataShellServiceProvider = Provider<BugoDataShellService>((ref) {
  return BugoDataShellService(ref);
});
