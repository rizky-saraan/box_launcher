import 'dart:async';

import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/native_channel.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'clock/clock_widget.dart';
import 'settings/clock_style_selector_sheet.dart';
import 'settings/widget_box_settings_sheet.dart';

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

  @override
  void initState() {
    super.initState();
    _loadClockStyle();
    _loadLanguage();
    
    // Timer only updates the date text every 30 seconds (low memory/CPU usage)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadClockStyle() async {
    final style = await getIt<LocalDataSourceHive>().getClockStyle();
    if (mounted) {
      setState(() {
        _selectedClockStyle = style;
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

  Future<void> _loadLanguage() async {
    final lang = await getIt<LocalDataSourceHive>().getLanguageCode();
    if (mounted) {
      setState(() {
        _selectedLanguage = lang;
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
              onWeatherChanged: (val) => _showWeather = val,
              onMediaWidgetChanged: (val) => _showMediaWidget = val,
              onBatteryChanged: (val) => _showBattery = val,
              onClockStylePressed: () {
                Navigator.pop(ctx); // Close Widget Box settings first
                _showClockStyleSelector(context);
              },
              onWallpaperPickerPressed: () {
                Navigator.pop(ctx);
                getIt<NativeChannel>().openWallpaperPicker();
              },
              onIconPackPressed: () {
                if (state is IconPackLoaded) {
                  _showIconPackSelector(context, state);
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
                    Text(
                      dateString,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
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
