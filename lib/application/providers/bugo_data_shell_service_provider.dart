import 'package:bugolytics/application/models/temperature.dart';
import 'package:bugolytics/application/providers/dio_client_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BugoDataShellService {
  final Dio _dio;

  BugoDataShellService(Ref ref) : _dio = ref.read(dioClientProvider).dio;

  Future<String> getDevices() async {
    try {
      final response = await _dio.get('/bds/api/devices');
      print(response);

      return response.toString();
    } catch (e) {
      throw Exception("get devices failed");
    }
  }

  Future<List<Temperature>> getTemperaturesByDeviceIdentifier(
      String deviceIdentifier) async {
    try {
      final response =
          await _dio.get('/bds/api/temperatures/device/$deviceIdentifier');
      print("response");
      print(response);
      final responseList = response.data as List<dynamic>;
      final temperatures = responseList.map((e) => Temperature.fromJson(e)).toList();
      print("Temperatures $temperatures");
      return temperatures;
    } catch (e) {
      throw Exception("getTemperaturesByDeviceIdentifier failed");
    }
  }
}

final bugoDataShellServiceProvider = Provider<BugoDataShellService>((ref) {
  return BugoDataShellService(ref);
});
