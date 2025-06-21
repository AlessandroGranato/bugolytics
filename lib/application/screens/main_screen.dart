import 'package:bugolytics/application/providers/auth_service_provider.dart';
import 'package:bugolytics/application/providers/device_storage_provider.dart';
import 'package:bugolytics/application/providers/temperatures_service_provider.dart';
import 'package:bugolytics/application/widgets/add_device.dart';
import 'package:bugolytics/application/widgets/show_last_temperature.dart';
import 'package:bugolytics/application/widgets/show_last_water_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return MainScreenState();
  }
}

class MainScreenState extends ConsumerState<MainScreen> {
  // ignore: constant_identifier_names
  static const String LOGOUT = 'LOGOUT';
  // ignore: constant_identifier_names
  static const String DISCONNECT_DEVICE = 'DISCONNECT_DEVICE';

  void _performLogout() async {
    await ref.read(authServiceProvider).logout();
  }

  void _openAddDeviceOverlay() async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => const AddDevice(),
    );
    ref.invalidate(lastTemperaturesProvider);
  }

  @override
  Widget build(BuildContext context) {
    print("Build called");
    final deviceState = ref.watch(deviceStorageProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main page"),
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (String result) {
              if (result == LOGOUT) {
                _performLogout();
              } else if (result == DISCONNECT_DEVICE) {
                ref
                    .read(deviceStorageProvider.notifier)
                    .deleteDeviceIdentifier();
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: LOGOUT,
                child: Text('Logout'),
              ),
              const PopupMenuItem<String>(
                value: DISCONNECT_DEVICE,
                child: Text('Disconnect device'),
              ),
            ],
          )
        ],
      ),
      body: deviceState == DeviceStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : deviceState == DeviceStatus.notProvided
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                            'No device found. Insert your device identifier.'),
                        SizedBox(height: screenHeight * 0.01),
                        ElevatedButton(
                          onPressed: () => _openAddDeviceOverlay(),
                          child: const Text("Add device"),
                        ),
                      ],
                    ),
                  ),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ShowLastTemperature(),
                        SizedBox(height: 20),
                        ShowLastWaterLevel(),
                      ],
                    ),
                  ),
                ),
    );
  }
}