import 'package:bugolytics/application/providers/temperatures_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ShowLastWaterLevel extends ConsumerWidget {
  const ShowLastWaterLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLastTemperatures = ref.watch(lastTemperaturesProvider);
    double size = MediaQuery.of(context).size.width * 0.6;
    return asyncLastTemperatures.when(
      data: (temperatures) {
        final lastTemperature =
            temperatures.isNotEmpty ? temperatures.first : null;
        return SizedBox(
          width: size,
          height: size,
          child: Card(
            elevation: 8,
            color: Theme.of(context).colorScheme.primary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Column(
                children: [
                  const Expanded(
                    flex: 2,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      "Last Water level",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Text(
                      // lastTemperature != null
                      //     ? "${lastTemperature.value.toStringAsFixed(1)}°"
                      //     : "No data",
                      "High",
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(lastTemperature != null
                          ? DateFormat('dd/MM/yyyy - HH:mm').format(lastTemperature.creationDate)
                          : "",
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => Text('Error: $err'),
    );
    /*Expanded(
      child: asyncLastTemperatures.when(
        data: (temperatures) => ListView.builder(
          itemCount: temperatures.length,
          itemBuilder: (_, i) => Text('${temperatures[i].value} °C'),
        ),
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );*/
  }
}
