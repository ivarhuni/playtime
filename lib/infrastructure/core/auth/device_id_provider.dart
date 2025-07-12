import 'package:device_info_plus/device_info_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

@LazySingleton()
class DeviceIdProvider {
  static const String _deviceIdKey = 'device_id';
  String? _deviceId;

  String? get deviceId => _deviceId;

  Future<void> initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _deviceId = prefs.getString(_deviceIdKey);
    
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, _deviceId!);
    }
  }

  Future<String> getDeviceInfo() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    
    try {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.brand} ${androidInfo.model}';
    } catch (e) {
      try {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      } catch (e) {
        return 'Unknown Device';
      }
    }
  }
} 