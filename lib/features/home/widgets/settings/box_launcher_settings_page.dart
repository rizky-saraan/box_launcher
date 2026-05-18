import 'package:flutter/material.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_appearance_settings_page.dart';

class BoxLauncherSettingsPage extends StatefulWidget {
  final VoidCallback onWallpaperPickerPressed;
  final void Function(BuildContext) onIconPackPressed;
  final String iconPackName;
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const BoxLauncherSettingsPage({
    super.key,
    required this.onWallpaperPickerPressed,
    required this.onIconPackPressed,
    required this.iconPackName,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<BoxLauncherSettingsPage> createState() => _BoxLauncherSettingsPageState();
}

class _BoxLauncherSettingsPageState extends State<BoxLauncherSettingsPage> {
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.selectedLanguage;
  }

  void _showLanguageSelector(BuildContext context) {
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
                  _currentLanguage == 'id' ? 'Pilih Bahasa' : 'Select Language',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white10),
              ListTile(
                title: Text('Bahasa Indonesia',
                    style: TextStyle(color: textColor)),
                trailing: _currentLanguage == 'id'
                    ? const Icon(Icons.check, color: Color(0xFFD49B9B))
                    : null,
                onTap: () {
                  widget.onLanguageChanged('id');
                  setState(() {
                    _currentLanguage = 'id';
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text('English', style: TextStyle(color: textColor)),
                trailing: _currentLanguage == 'en'
                    ? const Icon(Icons.check, color: Color(0xFFD49B9B))
                    : null,
                onTap: () {
                  widget.onLanguageChanged('en');
                  setState(() {
                    _currentLanguage = 'en';
                  });
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    final isIndonesian = _currentLanguage == 'id';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isIndonesian ? 'Pengaturan Saraan Launcher' : 'Saraan Launcher Settings',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          physics: const BouncingScrollPhysics(),
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 1. Tampilan (Sub-Menu)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.palette_outlined, color: Colors.blue, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Tampilan' : 'Appearance',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian
                          ? 'Ubah wallpaper, icon pack, ukuran & tema bundle'
                          : 'Change wallpaper, icon pack, size & theme bundle',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxLauncherAppearanceSettingsPage(
                            onWallpaperPickerPressed: widget.onWallpaperPickerPressed,
                            onIconPackPressed: widget.onIconPackPressed,
                            iconPackName: widget.iconPackName,
                            selectedLanguage: _currentLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),

                  // 2. Pilih Bahasa
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_outlined, color: Colors.orange, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Pilih Bahasa' : 'Select Language',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian ? 'Bahasa Indonesia' : 'English',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () {
                      _showLanguageSelector(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
