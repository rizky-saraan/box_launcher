import 'dart:async';
import 'package:file_picker/file_picker.dart';

import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/native_channel.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/data/services/weather_service.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/favorites/pages/edit_favorites_page.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'clock/clock_widget.dart';
import 'settings/clock_style_selector_sheet.dart';
import 'settings/widget_box_settings_sheet.dart';
import 'weather_animation_widget.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  bool _showWeather = true;
  bool _showMediaWidget = true;
  bool _showBattery = false;
  String _selectedClockStyle = 'digital_bold';
  String _selectedLanguage = 'id';

  WeatherData? _weatherData;
  bool _isLoadingWeather = false;
  int _batteryLevel = 100;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    
    // Timer only updates the date text and battery level every 30 seconds (low memory/CPU usage)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateBatteryAndDate();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final db = getIt<LocalDataSourceHive>();
    final showWeather = await db.getShowWeather();
    final showMedia = await db.getShowMediaWidget();
    final showBattery = await db.getShowBattery();
    final clockStyle = await db.getClockStyle();
    final lang = await db.getLanguageCode();

    int batteryLevel = 100;
    if (showBattery) {
      batteryLevel = await getIt<NativeChannel>().getBatteryLevel();
    }

    if (mounted) {
      setState(() {
        _showWeather = showWeather;
        _showMediaWidget = showMedia;
        _showBattery = showBattery;
        _selectedClockStyle = clockStyle;
        _selectedLanguage = lang;
        _batteryLevel = batteryLevel;
      });
      if (_showWeather) {
        _fetchLiveWeather();
      }
    }
  }

  Future<void> _updateBatteryAndDate() async {
    final now = DateTime.now();
    int batteryLevel = _batteryLevel;
    if (_showBattery) {
      batteryLevel = await getIt<NativeChannel>().getBatteryLevel();
    }
    if (mounted) {
      setState(() {
        _now = now;
        _batteryLevel = batteryLevel;
      });
    }
  }

  Future<void> _fetchLiveWeather() async {
    if (_isLoadingWeather) return;
    setState(() {
      _isLoadingWeather = true;
    });
    final data = await WeatherService.fetchWeather();
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _changeClockStyle(String style) async {
    await getIt<LocalDataSourceHive>().saveClockStyle(style);
    if (mounted) {
      setState(() {
        _selectedClockStyle = style;
      });
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    await getIt<LocalDataSourceHive>().saveLanguageCode(langCode);
    if (mounted) {
      setState(() {
        _selectedLanguage = langCode;
      });
    }
  }

  void _showIconPackSelector(BuildContext context, IconPackLoaded state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Pilih Icon Pack',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.availableIconPacks.length,
                  itemBuilder: (context, index) {
                    final pack = state.availableIconPacks[index];
                    final isSelected =
                        pack['packageName'] == state.selectedIconPack ||
                            (state.selectedIconPack == null &&
                                pack['packageName'] == "");
                    return ListTile(
                      title: Text(pack['label'] ?? 'Unknown',
                          style: TextStyle(color: textColor)),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        AppListItem.clearIconCache();
                        EditAppListItem.clearIconCache();
                        context.read<IconPackBloc>().add(
                            SetIconPackSelectionEvent(
                                pack['packageName']));
                        context.read<AppsBloc>().add(LoadAppsEvent());
                        Navigator.pop(ctx); // Close icon pack selector
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showClockStyleSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return ClockStyleSelectorSheet(
          selectedClockStyle: _selectedClockStyle,
          onClockStyleChanged: (newStyle) {
            _changeClockStyle(newStyle);
          },
        );
      },
    );
  }

  void _showThemeSettings(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocBuilder<IconPackBloc, IconPackState>(
          builder: (context, state) {
            final iconPackName = (state is IconPackLoaded &&
                    state.selectedIconPack != null &&
                    state.selectedIconPack!.isNotEmpty)
                ? state.selectedIconPack!.split('.').last
                : 'Default System';

            return WidgetBoxSettingsSheet(
              showWeather: _showWeather,
              showMediaWidget: _showMediaWidget,
              showBattery: _showBattery,
              onWeatherChanged: (val) async {
                await getIt<LocalDataSourceHive>().saveShowWeather(val);
                if (mounted) {
                  setState(() {
                    _showWeather = val;
                  });
                  if (val) {
                    _fetchLiveWeather();
                  }
                }
              },
              onMediaWidgetChanged: (val) async {
                await getIt<LocalDataSourceHive>().saveShowMediaWidget(val);
                if (mounted) {
                  setState(() {
                    _showMediaWidget = val;
                  });
                }
              },
              onBatteryChanged: (val) async {
                await getIt<LocalDataSourceHive>().saveShowBattery(val);
                int batteryLevel = _batteryLevel;
                if (val) {
                  batteryLevel = await getIt<NativeChannel>().getBatteryLevel();
                }
                if (mounted) {
                  setState(() {
                    _showBattery = val;
                    _batteryLevel = batteryLevel;
                  });
                }
              },
              onClockStylePressed: () {
                if (ctx.mounted) {
                  try {
                    Navigator.pop(ctx);
                  } catch (_) {}
                }
                _showClockStyleSelector(context);
              },
              onWallpaperPickerPressed: () {
                if (ctx.mounted) {
                  try {
                    Navigator.pop(ctx);
                  } catch (_) {}
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _showWallpaperSourceChooser();
                  }
                });
              },
              onIconPackPressed: (settingsContext) {
                if (state is IconPackLoaded) {
                  _showIconPackSelector(settingsContext, state);
                }
              },
              iconPackName: iconPackName,
              selectedLanguage: _selectedLanguage,
              onLanguageChanged: (lang) {
                _changeLanguage(lang);
              },
            );
          },
        );
      },
    );
  }

  void _showWallpaperSourceChooser() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;
    final isIndonesian = _selectedLanguage == 'id';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isIndonesian ? 'Sumber Wallpaper' : 'Wallpaper Source',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isIndonesian
                    ? 'Pilih bagaimana Anda ingin mengubah wallpaper'
                    : 'Choose how you want to change your wallpaper',
                style: TextStyle(
                  color: subColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              
              // Option 1: System / Wallpaper Apps
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.app_shortcut_outlined, color: Colors.blue, size: 24),
                ),
                title: Text(
                  isIndonesian ? 'Aplikasi Wallpaper / Sistem' : 'Wallpaper Apps / System',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isIndonesian
                      ? 'Pilih dari Zedge, Google Wallpapers, Live Wallpaper, dll.'
                      : 'Select from Zedge, Google Wallpapers, Live Wallpapers, etc.',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  getIt<NativeChannel>().openWallpaperPicker();
                },
              ),
              Divider(height: 1, color: dividerColor),
              
              // Option 2: Gallery / Local Image (sets on both)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: Colors.green, size: 24),
                ),
                title: Text(
                  isIndonesian ? 'Pilih dari Galeri Foto' : 'Choose from Gallery',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  isIndonesian
                      ? 'Pilih foto Anda & terapkan ke Home Screen + Lock Screen sekaligus'
                      : 'Select a photo & apply to Home Screen + Lock Screen at once',
                  style: TextStyle(color: subColor, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndApplyGalleryWallpaper();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndApplyGalleryWallpaper() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        compressionQuality: 0,
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final filePath = result.files.single.path!;
      final isIndonesian = _selectedLanguage == 'id';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndonesian
                  ? 'Menerapkan wallpaper pada home & lock screen...'
                  : 'Applying wallpaper to home & lock screen...',
              style: const TextStyle(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }

      final success = await getIt<NativeChannel>().setSystemWallpaper(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (isIndonesian
                      ? 'Wallpaper berhasil diterapkan ke semua layar!'
                      : 'Wallpaper applied to all screens successfully!')
                  : (isIndonesian ? 'Gagal menerapkan wallpaper!' : 'Failed to apply wallpaper!'),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: success ? Colors.green.shade800 : Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error picking/setting wallpaper: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeStr = _selectedLanguage == 'id' ? 'id_ID' : 'en_US';
    final dateString = DateFormat('EEEE, d MMM', localeStr).format(_now);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: () => _showThemeSettings(context),
      child: Container(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
        ),
        padding: const EdgeInsets.only(
            left: 32.0, top: 120.0, bottom: 48.0, right: 32.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClockWidget(selectedClockStyle: _selectedClockStyle),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          dateString,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                        if (_showBattery)
                          Text(
                            '$_batteryLevel%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        if (_showWeather && _weatherData != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              WeatherAnimationWidget(icon: _weatherData!.icon),
                              const SizedBox(width: 6),
                              Text(
                                '${(_weatherData!.temperature).toStringAsFixed(0)}°',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 64),
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, state) {
                    if (state is FavoritesLoaded) {
                      if (state.favorites.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'Long press an app to add to favorites',
                            style: TextStyle(
                                color: Colors.white54,
                                fontStyle: FontStyle.italic),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: state.favorites.map((app) {
                          return AppListItem(app: app, isFavoriteList: true);
                        }).toList(),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white24,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
