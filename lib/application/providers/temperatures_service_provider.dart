import 'package:bugolytics/application/models/temperature.dart';
import 'package:bugolytics/application/providers/bugo_data_shell_service_provider.dart';
import 'package:bugolytics/application/providers/device_storage_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastTemperaturesProvider = FutureProvider<List<Temperature>>(
  (ref) async {
    String? deviceIdentifier =
        await ref.read(deviceStorageProvider.notifier).getDeviceIdentifier();
    if (deviceIdentifier == null) {
      return [];
    }
    return ref
        .read(bugoDataShellServiceProvider)
        .getTemperaturesByDeviceIdentifier(deviceIdentifier);
  },
);
