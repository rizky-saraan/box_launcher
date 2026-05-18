import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@singleton
class LocalDataSourceHive {
  static const String _boxName = 'launcher_box';
  static const String _favoritesKey = 'favorites';

  static const String _iconPackKey = 'icon_pack';

  Future<List<String>> getFavoritePackages() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? list = box.get(_favoritesKey);
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> saveFavoritePackages(List<String> packages) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_favoritesKey, packages);
  }

  Future<String?> getIconPack() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_iconPackKey) as String?;
  }

  Future<void> saveIconPack(String? packageName) async {
    final box = await Hive.openBox(_boxName);
    if (packageName == null || packageName.isEmpty) {
      await box.delete(_iconPackKey);
    } else {
      await box.put(_iconPackKey, packageName);
    }
  }

  static const String _clockStyleKey = 'clock_style';
  static const String _languageKey = 'selected_language';
  static const String _showWeatherKey = 'show_weather';
  static const String _showMediaWidgetKey = 'show_media_widget';
  static const String _showBatteryKey = 'show_battery';
  static const String _appSizeKey = 'app_size';

  Future<String> getAppSize() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_appSizeKey) as String? ?? 'medium';
  }

  Future<void> saveAppSize(String size) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_appSizeKey, size);
  }

  Future<String> getClockStyle() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_clockStyleKey) as String? ?? 'digital_bold';
  }

  Future<void> saveClockStyle(String style) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_clockStyleKey, style);
  }

  Future<String> getLanguageCode() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_languageKey) as String? ?? 'id';
  }

  Future<void> saveLanguageCode(String langCode) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_languageKey, langCode);
  }

  Future<bool> getShowWeather() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_showWeatherKey) as bool? ?? true;
  }

  Future<void> saveShowWeather(bool show) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_showWeatherKey, show);
  }

  Future<bool> getShowMediaWidget() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_showMediaWidgetKey) as bool? ?? true;
  }

  Future<void> saveShowMediaWidget(bool show) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_showMediaWidgetKey, show);
  }

  Future<bool> getShowBattery() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_showBatteryKey) as bool? ?? false;
  }

  Future<void> saveShowBattery(bool show) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_showBatteryKey, show);
  }

  static const String _weatherTempKey = 'weather_temp';
  static const String _weatherIconKey = 'weather_icon';
  static const String _weatherDescKey = 'weather_desc';
  static const String _weatherCityKey = 'weather_city';
  static const String _weatherTimeKey = 'weather_time';

  Future<Map<String, dynamic>?> getCachedWeather() async {
    final box = await Hive.openBox(_boxName);
    final temp = box.get(_weatherTempKey) as double?;
    final icon = box.get(_weatherIconKey) as String?;
    final desc = box.get(_weatherDescKey) as String?;
    final city = box.get(_weatherCityKey) as String?;
    final time = box.get(_weatherTimeKey) as int?;

    if (temp == null || icon == null || desc == null || city == null || time == null) {
      return null;
    }
    return {
      'temp': temp,
      'icon': icon,
      'desc': desc,
      'city': city,
      'time': time,
    };
  }

  Future<void> saveCachedWeather(
      double temp, String icon, String desc, String city, int timestamp) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_weatherTempKey, temp);
    await box.put(_weatherIconKey, icon);
    await box.put(_weatherDescKey, desc);
    await box.put(_weatherCityKey, city);
    await box.put(_weatherTimeKey, timestamp);
  }

  static const String _themeBundleKey = 'active_theme_bundle';

  Future<String> getActiveThemeBundle() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_themeBundleKey) as String? ?? 'system';
  }

  Future<void> saveActiveThemeBundle(String bundleId) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeBundleKey, bundleId);
  }
}
