import 'package:flutter/material.dart';
import 'package:box_launcher/core/theme/font_manager.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_font_settings_page.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_size_settings_page.dart';
import 'package:box_launcher/features/home/widgets/settings/theme_bundle_selector_sheet.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';

class BoxLauncherAppearanceSettingsPage extends StatelessWidget {
  final VoidCallback onWallpaperPickerPressed;
  final void Function(BuildContext) onIconPackPressed;
  final String iconPackName;
  final String selectedLanguage;

  const BoxLauncherAppearanceSettingsPage({
    super.key,
    required this.onWallpaperPickerPressed,
    required this.onIconPackPressed,
    required this.iconPackName,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final iconColor = isDark ? Colors.white70 : Colors.black54;
    final dividerColor = isDark ? Colors.white10 : Colors.black12;

    final isIndonesian = selectedLanguage == 'id';

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
          isIndonesian ? 'Tampilan' : 'Appearance',
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
                  // 1. Ubah Wallpaper
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wallpaper_outlined, color: Colors.blue, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Ubah Wallpaper' : 'Change Wallpaper',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian ? 'Ganti latar belakang layar' : 'Change screen background',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: onWallpaperPickerPressed,
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  
                  // 2. Pilih Icon Pack
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.palette_outlined, color: Colors.purple, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Pilih Icon Pack' : 'Select Icon Pack',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      iconPackName.isNotEmpty ? iconPackName : (isIndonesian ? 'Sistem Default' : 'System Default'),
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () => onIconPackPressed(context),
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),

                  // 3. Ukuran Ikon & Teks
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.format_size_outlined, color: Colors.green, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Ukuran Ikon & Teks' : 'Icon & Text Size',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: ValueListenableBuilder<String>(
                      valueListenable: AppListItem.appSizeNotifier,
                      builder: (context, currentSize, child) {
                        String sizeLabel = isIndonesian ? 'Sedang (Level 5)' : 'Medium (Level 5)';
                        if (currentSize == 'small') {
                          sizeLabel = isIndonesian ? 'Kecil (Level 3)' : 'Small (Level 3)';
                        } else if (currentSize == 'large') {
                          sizeLabel = isIndonesian ? 'Besar (Level 7)' : 'Large (Level 7)';
                        } else if (currentSize == 'medium') {
                          sizeLabel = isIndonesian ? 'Sedang (Level 5)' : 'Medium (Level 5)';
                        } else {
                          final val = int.tryParse(currentSize) ?? 5;
                          switch (val) {
                            case 1:
                              sizeLabel = isIndonesian ? 'Sangat Kecil (Level 1)' : 'Extremely Small (Level 1)';
                              break;
                            case 2:
                              sizeLabel = isIndonesian ? 'Cukup Kecil (Level 2)' : 'Very Small (Level 2)';
                              break;
                            case 3:
                              sizeLabel = isIndonesian ? 'Kecil (Level 3)' : 'Small (Level 3)';
                              break;
                            case 4:
                              sizeLabel = isIndonesian ? 'Agak Kecil (Level 4)' : 'Slightly Small (Level 4)';
                              break;
                            case 5:
                              sizeLabel = isIndonesian ? 'Sedang (Level 5)' : 'Medium (Level 5)';
                              break;
                            case 6:
                              sizeLabel = isIndonesian ? 'Agak Besar (Level 6)' : 'Slightly Large (Level 6)';
                              break;
                            case 7:
                              sizeLabel = isIndonesian ? 'Besar (Level 7)' : 'Large (Level 7)';
                              break;
                            case 8:
                              sizeLabel = isIndonesian ? 'Cukup Besar (Level 8)' : 'Very Large (Level 8)';
                              break;
                            case 9:
                              sizeLabel = isIndonesian ? 'Sangat Besar (Level 9)' : 'Extremely Large (Level 9)';
                              break;
                          }
                        }
                        return Text(
                          sizeLabel,
                          style: TextStyle(color: subColor, fontSize: 13),
                        );
                      },
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxLauncherSizeSettingsPage(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),

                  // 4. Jenis Font (Font Style)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.text_fields_outlined, color: Colors.orange, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Jenis Font' : 'Font Style',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: ValueListenableBuilder<String>(
                      valueListenable: FontManager.activeFontNotifier,
                      builder: (context, activeFont, child) {
                        return Text(
                          activeFont.replaceFirst('Custom_', ''),
                          style: TextStyle(color: subColor, fontSize: 13),
                        );
                      },
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxLauncherFontSettingsPage(
                            selectedLanguage: selectedLanguage,
                          ),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),

                  // 5. Ganti Tema Bundle
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pink.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.color_lens_outlined, color: Colors.pink, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Ganti Tema Bundle' : 'Change Theme Bundle',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian ? 'Geser & pilih dari 15 tema premium' : 'Swipe & select from 15 premium themes',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () {
                      ThemeBundleSelectorSheet.show(context);
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
