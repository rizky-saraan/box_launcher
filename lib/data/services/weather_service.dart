import 'dart:convert';

import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final String icon;
  final String description;
  final String cityName;

  WeatherData({
    required this.temperature,
    required this.icon,
    required this.description,
    required this.cityName,
  });

  factory WeatherData.fromWeatherApi(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    final current = json['current'] ?? {};
    final condition = current['condition'] ?? {};
    
    final temp = (current['temp_c'] as num?)?.toDouble() ?? 17.0;
    final code = condition['code'] as int? ?? 1000;
    final name = location['name'] as String? ?? 'Jakarta';
    final desc = condition['text'] as String? ?? 'Cerah';

    String icon = '☀️';

    // WeatherAPI.com Condition Codes: https://www.weatherapi.com/docs/weather_conditions.json
    if (code == 1000) {
      icon = '☀️';
    } else if (code == 1003 || code == 1006 || code == 1009) {
      icon = '☁️';
    } else if (code == 1030 || code == 1135 || code == 1147) {
      icon = '🌫️';
    } else if (code == 1063 || code == 1072 || (code >= 1150 && code <= 1201) || (code >= 1240 && code <= 1246)) {
      icon = '🌧️';
    } else if (code == 1066 || code == 1069 || (code >= 1204 && code <= 1225) || (code >= 1249 && code <= 1258)) {
      icon = '❄️';
    } else if (code == 1087 || (code >= 1273 && code <= 1282)) {
      icon = '🌩️';
    } else {
      icon = '☁️';
    }

    return WeatherData(
      temperature: temp,
      icon: icon,
      description: desc,
      cityName: name,
    );
  }

  factory WeatherData.placeholder() {
    return WeatherData(
      temperature: 17.0,
      icon: '💧',
      description: 'Hujan Gerimis',
      cityName: 'Jakarta',
    );
  }
}

class WeatherService {
  // User's custom API Key for WeatherAPI.com
  static const String _apiKey = '55f74a9a5fe64b50895132419261705';

  static Future<WeatherData> fetchWeather() async {
    // Phase 0: Try to load cached weather from local database
    Map<String, dynamic>? cache;
    try {
      final db = getIt<LocalDataSourceHive>();
      cache = await db.getCachedWeather();
      if (cache != null) {
        final cachedTime = cache['time'] as int;
        final now = DateTime.now().millisecondsSinceEpoch;
        final diffMinutes = (now - cachedTime) / (1000 * 60);
        print('ℹ️ [WeatherService] Ditemukan data cuaca lokal (cache) berumur ${diffMinutes.toStringAsFixed(1)} menit.');
        
        // Cache is fresh if it is less than 30 minutes old
        if (diffMinutes < 30) {
          print('✅ [WeatherService] Menggunakan data cuaca dari cache (Fresh < 30 menit).');
          return WeatherData(
            temperature: cache['temp'] as double,
            icon: cache['icon'] as String,
            description: cache['desc'] as String,
            cityName: cache['city'] as String,
          );
        }
        print('🔄 [WeatherService] Cache kadaluarsa (> 30 menit). Memulai request API baru...');
      }
    } catch (e) {
      print('⚠️ [WeatherService] Gagal memuat cache lokal: $e');
    }

    double lat = -6.2088; // Default: Jakarta
    double lon = 106.8456;
    String cityName = 'Jakarta';
    bool locationFound = false;

    // Phase 1: Try high-speed geolocator IP lookup (https://ipwho.is/)
    try {
      print('☀️ [WeatherService] Mencari lokasi via IP (ipwho.is)...');
      final response = await http.get(Uri.parse('https://ipwho.is/')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final ipData = jsonDecode(response.body);
        if (ipData['success'] == true) {
          lat = (ipData['latitude'] as num).toDouble();
          lon = (ipData['longitude'] as num).toDouble();
          cityName = ipData['city'] ?? 'Jakarta';
          locationFound = true;
          print('📍 [WeatherService] Lokasi ditemukan (ipwho.is): $cityName ($lat, $lon)');
        }
      }
    } catch (e) {
      print('ℹ️ [WeatherService] ipwho.is gagal/timeout ($e). Mencoba backup (freeipapi)...');
    }

    // Phase 2: Try secondary backup geolocator IP lookup (https://freeipapi.com/api/json)
    if (!locationFound) {
      try {
        final response = await http.get(Uri.parse('https://freeipapi.com/api/json')).timeout(const Duration(seconds: 2));
        if (response.statusCode == 200) {
          final ipData = jsonDecode(response.body);
          lat = (ipData['latitude'] as num).toDouble();
          lon = (ipData['longitude'] as num).toDouble();
          cityName = ipData['cityName'] ?? 'Jakarta';
          locationFound = true;
          print('📍 [WeatherService] Lokasi ditemukan (freeipapi): $cityName ($lat, $lon)');
        }
      } catch (e) {
        print('⚠️ [WeatherService] Geolocator backup gagal/timeout ($e). Menggunakan default: $cityName ($lat, $lon)');
      }
    }

    // Phase 3: Fetch weather from WeatherAPI.com using the coordinates
    try {
      print('☁️ [WeatherService] Memanggil API WeatherAPI.com...');
      final weatherUri = Uri.parse(
          'https://api.weatherapi.com/v1/current.json?key=$_apiKey&q=$lat,$lon&aqi=no');
      final response = await http.get(weatherUri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final weatherData = jsonDecode(response.body);
        final result = WeatherData.fromWeatherApi(weatherData);
        // Bind coordinates city name if result city name is empty
        final finalCity = result.cityName.isNotEmpty ? result.cityName : cityName;
        
        final finalResult = WeatherData(
          temperature: result.temperature,
          icon: result.icon,
          description: result.description,
          cityName: finalCity,
        );

        print('✅ [WeatherService] BERHASIL mengambil data dari WeatherAPI.com!');
        print('   -> Kota: ${finalResult.cityName}');
        print('   -> Suhu: ${finalResult.temperature}°C');
        print('   -> Kondisi: ${finalResult.description} (${finalResult.icon})');

        // Save fresh response to Hive
        try {
          final db = getIt<LocalDataSourceHive>();
          await db.saveCachedWeather(
            finalResult.temperature,
            finalResult.icon,
            finalResult.description,
            finalResult.cityName,
            DateTime.now().millisecondsSinceEpoch,
          );
          print('💾 [WeatherService] Berhasil menyimpan data cuaca ke cache lokal.');
        } catch (cacheErr) {
          print('⚠️ [WeatherService] Gagal menyimpan data cuaca ke cache: $cacheErr');
        }

        return finalResult;
      } else {
        print('❌ [WeatherService] Gagal memanggil WeatherAPI.com. Status Code: ${response.statusCode}');
        print('   -> Response: ${response.body}');
      }
    } catch (e) {
      print('⚠️ [WeatherService] Terjadi kesalahan saat memanggil WeatherAPI.com: $e');
    }

    // Phase 4: Stale Cache Fallback (Excellent for offline state)
    if (cache != null) {
      print('⚠️ [WeatherService] API gagal, menggunakan data cache yang ada (Offline Fallback).');
      return WeatherData(
        temperature: cache['temp'] as double,
        icon: cache['icon'] as String,
        description: cache['desc'] as String,
        cityName: cache['city'] as String,
      );
    }

    print('ℹ️ [WeatherService] Menggunakan data cuaca default (fallback).');
    return WeatherData.placeholder();
  }
}
