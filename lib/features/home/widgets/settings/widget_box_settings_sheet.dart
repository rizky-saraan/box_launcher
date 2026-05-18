import 'package:box_launcher/features/favorites/pages/edit_favorites_page.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_settings_page.dart';
import 'package:box_launcher/features/home/widgets/settings/theme_bundle_selector_sheet.dart';
import 'package:flutter/material.dart';

class WidgetBoxSettingsSheet extends StatefulWidget {
  final bool showWeather;
  final bool showMediaWidget;
  final bool showBattery;
  final ValueChanged<bool> onWeatherChanged;
  final ValueChanged<bool> onMediaWidgetChanged;
  final ValueChanged<bool> onBatteryChanged;

  final VoidCallback onClockStylePressed;
  final VoidCallback onWallpaperPickerPressed;
  final void Function(BuildContext) onIconPackPressed;
  final String iconPackName;

  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const WidgetBoxSettingsSheet({
    super.key,
    required this.showWeather,
    required this.showMediaWidget,
    required this.showBattery,
    required this.onWeatherChanged,
    required this.onMediaWidgetChanged,
    required this.onBatteryChanged,
    required this.onClockStylePressed,
    required this.onWallpaperPickerPressed,
    required this.onIconPackPressed,
    required this.iconPackName,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<WidgetBoxSettingsSheet> createState() => _WidgetBoxSettingsSheetState();
}

class _WidgetBoxSettingsSheetState extends State<WidgetBoxSettingsSheet> {
  late bool _showWeather;
  late bool _showMediaWidget;
  late bool _showBattery;

  @override
  void initState() {
    super.initState();
    _showWeather = widget.showWeather;
    _showMediaWidget = widget.showMediaWidget;
    _showBattery = widget.showBattery;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.dashboard_customize_outlined,
                        color: textColor, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Widget Box',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.wb_sunny_outlined, color: iconColor),
                title: Text('Cuaca',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Switch.adaptive(
                  value: _showWeather,
                  activeColor: const Color(0xFFD49B9B),
                  onChanged: (val) {
                    setState(() {
                      _showWeather = val;
                    });
                    widget.onWeatherChanged(val);
                  },
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.access_time_outlined, color: iconColor),
                title: Text('Tampilan jam',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: widget.onClockStylePressed,
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.swap_vert, color: iconColor),
                title: Text('Pindahkan widget',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: () {},
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                title: Text('Tampilkan media widget',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                subtitle: Text('Disaat memainkan musik',
                    style: TextStyle(color: subColor, fontSize: 13)),
                trailing: Switch.adaptive(
                  value: _showMediaWidget,
                  activeColor: const Color(0xFFD49B9B),
                  onChanged: (val) {
                    setState(() {
                      _showMediaWidget = val;
                    });
                    widget.onMediaWidgetChanged(val);
                  },
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                title: Text('Tampilkan persentase baterai',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Switch.adaptive(
                  value: _showBattery,
                  activeColor: const Color(0xFFD49B9B),
                  onChanged: (val) {
                    setState(() {
                      _showBattery = val;
                    });
                    widget.onBatteryChanged(val);
                  },
                ),
              ),
              Divider(height: 32, thickness: 1, color: dividerColor),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.star_outline, color: iconColor),
                title: Text('Ubah favorit',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditFavoritesPage(),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.color_lens_outlined, color: iconColor),
                title: Text(widget.selectedLanguage == 'id' ? 'Ganti tema bundle' : 'Change theme bundle',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: () {
                  Navigator.pop(context);
                  ThemeBundleSelectorSheet.show(context);
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.settings_outlined, color: iconColor),
                title: Text('Pengaturan Box Launcher',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: () {
                  Navigator.pop(context); // Close Widget Box settings bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BoxLauncherSettingsPage(
                        onWallpaperPickerPressed: widget.onWallpaperPickerPressed,
                        onIconPackPressed: widget.onIconPackPressed,
                        iconPackName: widget.iconPackName,
                        selectedLanguage: widget.selectedLanguage,
                        onLanguageChanged: widget.onLanguageChanged,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
                leading: Icon(Icons.auto_awesome_outlined, color: iconColor),
                title: Text('Box Launcher Pro',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.w500)),
                subtitle: Text('Cobalah untuk 7 hari',
                    style: TextStyle(color: subColor, fontSize: 13)),
                trailing: Icon(Icons.chevron_right, color: iconColor),
                onTap: () {},
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
