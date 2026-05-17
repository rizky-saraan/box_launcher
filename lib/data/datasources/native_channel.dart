import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@singleton
class NativeChannel {
  static const MethodChannel _channel = MethodChannel('com.box_launcher/apps');

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final List<dynamic>? apps = await _channel.invokeMethod('getInstalledApps');
    if (apps == null) return [];
    return apps.cast<Map<Object?, Object?>>().map((e) => e.cast<String, dynamic>()).toList();
  }

  Future<bool> openApp(String packageName) async {
    final bool? result = await _channel.invokeMethod('openApp', {'packageName': packageName});
    return result ?? false;
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final Uint8List? icon = await _channel.invokeMethod('getAppIcon', {'packageName': packageName});
      return icon;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, String>>> getInstalledIconPacks() async {
    final List<dynamic>? packs = await _channel.invokeMethod('getInstalledIconPacks');
    if (packs == null) return [];
    return packs.cast<Map<Object?, Object?>>().map((e) => e.cast<String, String>()).toList();
  }

  Future<bool> setIconPack(String? packageName) async {
    final bool? result = await _channel.invokeMethod('setIconPack', {'packageName': packageName});
    return result ?? false;
  }

  Future<void> openWallpaperPicker() async {
    await _channel.invokeMethod('openWallpaperPicker');
  }

  Future<void> updateWallpaperOffset(double offset) async {
    try {
      await _channel.invokeMethod('updateWallpaperOffset', {'offset': offset});
    } catch (e) {
      // ignore
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      final int? level = await _channel.invokeMethod('getBatteryLevel');
      return level ?? 100;
    } catch (e) {
      return 100;
    }
  }
}
