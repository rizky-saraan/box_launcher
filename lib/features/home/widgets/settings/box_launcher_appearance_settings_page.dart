import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/core/theme/font_manager.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_font_settings_page.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_size_settings_page.dart';
import 'package:box_launcher/features/home/widgets/settings/theme_bundle_selector_sheet.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/launcher/widgets/app_lock_pin_sheet.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BoxLauncherAppearanceSettingsPage extends StatefulWidget {
  final VoidCallback onWallpaperPickerPressed;
  final void Function(BuildContext) onIconPackPressed;
  final String iconPackName;
  final String selectedLanguage;

  // Global static ValueNotifiers to enable real-time reactive UI changes across pages
  static final ValueNotifier<bool> enableHapticsNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> enableWeatherAnimationsNotifier = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> hasPinNotifier = ValueNotifier<bool>(false);

  const BoxLauncherAppearanceSettingsPage({
    super.key,
    required this.onWallpaperPickerPressed,
    required this.onIconPackPressed,
    required this.iconPackName,
    required this.selectedLanguage,
  });

  @override
  State<BoxLauncherAppearanceSettingsPage> createState() => _BoxLauncherAppearanceSettingsPageState();
}

class _BoxLauncherAppearanceSettingsPageState extends State<BoxLauncherAppearanceSettingsPage> {
  bool _enableHaptics = true;
  bool _enableWeatherAnimations = true;
  bool _hasPin = false;

  @override
  void initState() {
    super.initState();
    _loadPremiumSettings();
  }

  Future<void> _loadPremiumSettings() async {
    final hive = getIt<LocalDataSourceHive>();
    final haptics = await hive.getEnableHaptics();
    final weather = await hive.getEnableWeatherAnimations();
    final pin = await hive.getAppLockPin();

    setState(() {
      _enableHaptics = haptics;
      _enableWeatherAnimations = weather;
      _hasPin = pin != null && pin.isNotEmpty;
    });

    // Sync static ValueNotifiers
    BoxLauncherAppearanceSettingsPage.enableHapticsNotifier.value = haptics;
    BoxLauncherAppearanceSettingsPage.enableWeatherAnimationsNotifier.value = weather;
    BoxLauncherAppearanceSettingsPage.hasPinNotifier.value = _hasPin;
  }

  void _triggerHapticTick() {
    if (_enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _toggleHaptics(bool val) async {
    final hive = getIt<LocalDataSourceHive>();
    await hive.saveEnableHaptics(val);
    setState(() {
      _enableHaptics = val;
    });
    BoxLauncherAppearanceSettingsPage.enableHapticsNotifier.value = val;
    _triggerHapticTick();
  }

  Future<void> _toggleWeatherAnimations(bool val) async {
    final hive = getIt<LocalDataSourceHive>();
    await hive.saveEnableWeatherAnimations(val);
    setState(() {
      _enableWeatherAnimations = val;
    });
    BoxLauncherAppearanceSettingsPage.enableWeatherAnimationsNotifier.value = val;
    _triggerHapticTick();
  }

  Future<void> _setupSecurityPin(BuildContext context) async {
    _triggerHapticTick();
    final controller = TextEditingController();
    final isIndonesian = widget.selectedLanguage == 'id';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            isIndonesian ? 'Atur 4-Digit PIN Baru' : 'Set New 4-Digit PIN',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isIndonesian
                    ? 'PIN ini akan digunakan untuk membuka aplikasi terkunci dan aplikasi tersembunyi.'
                    : 'This PIN will be used to unlock locked and hidden applications.',
                style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                autofocus: true,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 24, letterSpacing: 8),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFD49B9B), width: 2)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _triggerHapticTick();
                Navigator.pop(ctx);
              },
              child: Text(
                isIndonesian ? 'Batal' : 'Cancel',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                _triggerHapticTick();
                final pin = controller.text;
                final messenger = ScaffoldMessenger.of(context);
                if (pin.length == 4 && int.tryParse(pin) != null) {
                  Navigator.pop(ctx);
                  await getIt<LocalDataSourceHive>().saveAppLockPin(pin);
                  if (mounted) {
                    setState(() {
                      _hasPin = true;
                    });
                    BoxLauncherAppearanceSettingsPage.hasPinNotifier.value = true;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isIndonesian ? 'PIN Pengunci Berhasil Disimpan!' : 'Security PIN Set Successfully!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          isIndonesian ? 'PIN harus berupa 4 digit angka!' : 'PIN must be exactly 4 digits!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Color(0xFFD49B9B), fontWeight: FontWeight.bold),
              ),
            ),
          ],
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

    final isIndonesian = widget.selectedLanguage == 'id';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () {
            _triggerHapticTick();
            Navigator.pop(context);
          },
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
            Text(
              isIndonesian ? 'Estetika & Gaya' : 'Aesthetics & Style',
              style: TextStyle(
                color: subColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
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
                    onTap: widget.onWallpaperPickerPressed,
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
                      widget.iconPackName.isNotEmpty ? widget.iconPackName : (isIndonesian ? 'Sistem Default' : 'System Default'),
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () => widget.onIconPackPressed(context),
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
                      _triggerHapticTick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxLauncherSizeSettingsPage(
                            selectedLanguage: widget.selectedLanguage,
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
                      _triggerHapticTick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoxLauncherFontSettingsPage(
                            selectedLanguage: widget.selectedLanguage,
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
                      _triggerHapticTick();
                      ThemeBundleSelectorSheet.show(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isIndonesian ? 'Keamanan & Privasi' : 'Security & Privacy',
              style: TextStyle(
                color: subColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
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
                  // 1. Security PIN config
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security, color: Colors.deepOrange, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Atur PIN Pengunci & Penyembunyi' : 'Set Security PIN Code',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      _hasPin
                          ? (isIndonesian ? 'PIN Aktif (Klik untuk mengubah)' : 'PIN is active (Click to change)')
                          : (isIndonesian ? 'PIN Belum Diatur' : 'PIN Not Set Yet'),
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                    trailing: Icon(Icons.chevron_right, color: iconColor),
                    onTap: () => _setupSecurityPin(context),
                  ),
                  if (_hasPin) ...[
                    Divider(height: 1, thickness: 1, color: dividerColor),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.visibility_off_outlined, color: Colors.purple, size: 22),
                      ),
                      title: Text(
                        isIndonesian ? 'Kelola Aplikasi Tersembunyi' : 'Manage Hidden Apps',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: Text(
                        isIndonesian ? 'Tampilkan kembali aplikasi tersembunyi' : 'Unhide applications previously hidden',
                        style: TextStyle(color: subColor, fontSize: 12),
                      ),
                      trailing: Icon(Icons.chevron_right, color: iconColor),
                      onTap: () => _manageHiddenApps(context),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isIndonesian ? 'Interaksi Premium' : 'Premium Interaction',
              style: TextStyle(
                color: subColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
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
                  // 1. Weather Animations Toggle
                  SwitchListTile(
                    activeColor: const Color(0xFFD49B9B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_sunny_outlined, color: Colors.amber, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Animasi Cuaca di Header' : 'Animated Weather Card',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian ? 'Ganti ikon cuaca statis dengan animasi indah' : 'Replace static weather icon with beautiful micro-animations',
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                    value: _enableWeatherAnimations,
                    onChanged: _toggleWeatherAnimations,
                  ),
                  Divider(height: 1, thickness: 1, color: dividerColor),
                  // 2. Haptic Feedback Toggle
                  SwitchListTile(
                    activeColor: const Color(0xFFD49B9B),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.vibration, color: Colors.blue, size: 22),
                    ),
                    title: Text(
                      isIndonesian ? 'Getaran Haptic (Taktil)' : 'Haptic Vibration Feedback',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      isIndonesian ? 'Umpan balik getar pada menu dan A-Z sidebar' : 'Vibrates when using navigation and scrubbing the A-Z list',
                      style: TextStyle(color: subColor, fontSize: 12),
                    ),
                    value: _enableHaptics,
                    onChanged: _toggleHaptics,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manageHiddenApps(BuildContext context) async {
    _triggerHapticTick();
    final hive = getIt<LocalDataSourceHive>();
    final pin = await hive.getAppLockPin();
    if (pin == null || pin.isEmpty) return;

    if (!context.mounted) return;
    
    // 1. Verify PIN
    final authenticated = await showAppLockPinSheet(context, pin);
    if (!authenticated) return;

    if (!context.mounted) return;

    // 2. Load and show list of hidden apps in a beautiful glassmorphic dialog
    final isIndonesian = widget.selectedLanguage == 'id';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return FutureBuilder<List<String>>(
              future: hive.getHiddenApps(),
              builder: (context, snapshot) {
                final hiddenApps = snapshot.data ?? [];
                
                return AlertDialog(
                  backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(
                    isIndonesian ? 'Aplikasi Tersembunyi' : 'Hidden Apps',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  content: hiddenApps.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Text(
                            isIndonesian
                                ? 'Tidak ada aplikasi yang disembunyikan.'
                                : 'No applications are hidden.',
                            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : SizedBox(
                          width: double.maxFinite,
                          height: 300,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: hiddenApps.length,
                            separatorBuilder: (c, i) => Divider(color: isDark ? Colors.white12 : Colors.black12),
                            itemBuilder: (context, index) {
                              final pkg = hiddenApps[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.visibility_off_outlined, color: Colors.purpleAccent),
                                title: Text(
                                  pkg.split('.').last,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  pkg,
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.green),
                                  onPressed: () async {
                                    final updatedList = List<String>.from(hiddenApps);
                                    updatedList.remove(pkg);
                                    await hive.saveHiddenApps(updatedList);
                                    
                                    // Trigger main apps bloc refresh
                                    if (dialogCtx.mounted) {
                                      dialogCtx.read<AppsBloc>().add(LoadAppsEvent());
                                    }
                                    
                                    setDialogState(() {});
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogCtx),
                      child: Text(
                        isIndonesian ? 'Tutup' : 'Close',
                        style: const TextStyle(color: Color(0xFFD49B9B), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
