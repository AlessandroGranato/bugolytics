class Device {
  final int id;
  final String deviceIdentifier;
  final DateTime creationDate;

  Device(
      {required this.id,
      required this.deviceIdentifier,
      required this.creationDate});

  Device.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        deviceIdentifier = json['deviceIdentifier'] as String,
        creationDate = DateTime.parse(json['creationDate']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceIdentifier': deviceIdentifier,
        'creationDate': creationDate.toIso8601String()
      };

  @override
  String toString() {
    return 'Device(id: $id, deviceIdentifier: $deviceIdentifier, creationDate: $creationDate)';
  }
}
