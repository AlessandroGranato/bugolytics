import 'package:bugolytics/application/models/device.dart';

class Temperature {
  final int id;
  final Device device;
  final double value;
  final DateTime creationDate;

  Temperature(
      {required this.id,
      required this.device,
      required this.value,
      required this.creationDate});

  Temperature.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        device = Device.fromJson(json['device']),
        value = (json['value'] as num) as double,
        creationDate = DateTime.parse(json['creationDate']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'device': device.toJson(),
        'value': value,
        'creationDate': creationDate.toIso8601String()
      };

  @override
  String toString() {
    return 'Temperature(id: $id, value: $value, creationDate: $creationDate, device: $device)';
  }
}