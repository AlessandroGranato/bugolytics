import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum DeviceStatus {
  loading,
  notProvided,
  provided,
}

class DeviceStorage extends StateNotifier<DeviceStatus> {
  final String deviceIdentifierKey = 'deviceIdentifier';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DeviceStorage() : super(DeviceStatus.loading) {
    _checkDeviceStatus();
  }

  Future<void> _checkDeviceStatus() async {
    final isProvided = await getDeviceIdentifier();
    state =
        isProvided != null ? DeviceStatus.provided : DeviceStatus.notProvided;
  }

  Future<void> saveDeviceIdentifier(String deviceIdentifier) async {
    await _storage.write(key: deviceIdentifierKey, value: deviceIdentifier);
    state = DeviceStatus.provided;
  }

  Future<String?> getDeviceIdentifier() async {
    return await _storage.read(key: deviceIdentifierKey);
  }

  Future<void> deleteDeviceIdentifier() async {
    await _storage.delete(key: deviceIdentifierKey);
    state = DeviceStatus.notProvided;
  }

  Future<bool> isProvided() async {
    return state == DeviceStatus.provided;
  }
}

final deviceStorageProvider = StateNotifierProvider <DeviceStorage, DeviceStatus>(
  (ref) => DeviceStorage(),
);
