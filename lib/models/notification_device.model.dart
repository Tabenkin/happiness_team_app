typedef NotificationDevices = List<NotificationDevice>;

class NotificationDevice {
  String deviceId;
  String token;

  NotificationDevice({
    required this.deviceId,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'token': token,
    };
  }

  factory NotificationDevice.fromMap(Map<String, dynamic> map) {
    return NotificationDevice(
      deviceId: map['deviceId'] as String,
      token: map['token'] as String,
    );
  }
}
