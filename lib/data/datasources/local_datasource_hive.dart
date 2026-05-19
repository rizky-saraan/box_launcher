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
  static const String _activeFontKey = 'active_font_family';
  static const String _customFontsMapKey = 'custom_fonts_map';

  Future<String> getActiveThemeBundle() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_themeBundleKey) as String? ?? 'system';
  }

  Future<void> saveActiveThemeBundle(String bundleId) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_themeBundleKey, bundleId);
  }

  Future<String> getActiveFont() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_activeFontKey) as String? ?? 'Default';
  }

  Future<void> saveActiveFont(String fontFamily) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_activeFontKey, fontFamily);
  }

  Future<Map<String, String>> getCustomFonts() async {
    final box = await Hive.openBox(_boxName);
    final map = box.get(_customFontsMapKey);
    if (map == null) return {};
    return Map<String, String>.from(map);
  }

  Future<void> saveCustomFonts(Map<String, String> fontsMap) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_customFontsMapKey, fontsMap);
  }

  static const String _showDynamicBlurKey = 'show_dynamic_blur';
  static const String _enableHapticsKey = 'enable_haptics';
  static const String _enableGesturesKey = 'enable_gestures';
  static const String _enableSmartSuggestionsKey = 'enable_smart_suggestions';
  static const String _enableWeatherAnimationsKey = 'enable_weather_animations';
  static const String _appLockPinKey = 'app_lock_pin';
  static const String _hiddenAppsKey = 'hidden_apps_list';
  static const String _lockedAppsKey = 'locked_apps_list';
  static const String _customAppNamesKey = 'custom_app_names_map';
  static const String _customAppIconsKey = 'custom_app_icons_map';

  Future<bool> getShowDynamicBlur() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_showDynamicBlurKey) as bool? ?? true;
  }

  Future<void> saveShowDynamicBlur(bool show) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_showDynamicBlurKey, show);
  }

  Future<bool> getEnableHaptics() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_enableHapticsKey) as bool? ?? true;
  }

  Future<void> saveEnableHaptics(bool enable) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_enableHapticsKey, enable);
  }

  Future<bool> getEnableGestures() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_enableGesturesKey) as bool? ?? true;
  }

  Future<void> saveEnableGestures(bool enable) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_enableGesturesKey, enable);
  }

  Future<bool> getEnableSmartSuggestions() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_enableSmartSuggestionsKey) as bool? ?? true;
  }

  Future<void> saveEnableSmartSuggestions(bool enable) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_enableSmartSuggestionsKey, enable);
  }

  Future<bool> getEnableWeatherAnimations() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_enableWeatherAnimationsKey) as bool? ?? true;
  }

  Future<void> saveEnableWeatherAnimations(bool enable) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_enableWeatherAnimationsKey, enable);
  }

  Future<String?> getAppLockPin() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_appLockPinKey) as String?;
  }

  Future<void> saveAppLockPin(String? pin) async {
    final box = await Hive.openBox(_boxName);
    if (pin == null || pin.isEmpty) {
      await box.delete(_appLockPinKey);
    } else {
      await box.put(_appLockPinKey, pin);
    }
  }

  Future<List<String>> getHiddenApps() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? list = box.get(_hiddenAppsKey);
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> saveHiddenApps(List<String> packages) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_hiddenAppsKey, packages);
  }

  Future<List<String>> getLockedApps() async {
    final box = await Hive.openBox(_boxName);
    final List<dynamic>? list = box.get(_lockedAppsKey);
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> saveLockedApps(List<String> packages) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_lockedAppsKey, packages);
  }

  Future<Map<String, String>> getCustomAppNames() async {
    final box = await Hive.openBox(_boxName);
    final map = box.get(_customAppNamesKey);
    if (map == null) return {};
    return Map<String, String>.from(map);
  }

  Future<void> saveCustomAppNames(Map<String, String> map) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_customAppNamesKey, map);
  }

  Future<Map<String, String>> getCustomAppIcons() async {
    final box = await Hive.openBox(_boxName);
    final map = box.get(_customAppIconsKey);
    if (map == null) return {};
    return Map<String, String>.from(map);
  }

  Future<void> saveCustomAppIcons(Map<String, String> map) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_customAppIconsKey, map);
  }
}
