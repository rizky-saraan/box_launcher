import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:box_launcher/data/datasources/native_channel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/core/theme/theme_bundle.dart';
import 'package:box_launcher/core/theme/themed_icon_widget.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/favorites/pages/edit_favorites_page.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:box_launcher/features/launcher/pages/launcher_page.dart';

class ThemeBundleSelectorSheet extends StatefulWidget {
  const ThemeBundleSelectorSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ThemeBundleSelectorSheet(),
    );
  }

  @override
  State<ThemeBundleSelectorSheet> createState() => _ThemeBundleSelectorSheetState();
}

class _ThemeBundleSelectorSheetState extends State<ThemeBundleSelectorSheet> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  String _activeBundleId = 'system';
  String _langCode = 'id';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final hive = getIt<LocalDataSourceHive>();
    final activeId = await hive.getActiveThemeBundle();
    final lang = await hive.getLanguageCode();

    if (mounted) {
      setState(() {
        _activeBundleId = activeId;
        _langCode = lang;
        _isLoading = false;
        
        // Auto scroll to active page
        final activeIndex = ThemeBundle.presets.indexWhere((p) => p.id == activeId);
        if (activeIndex != -1) {
          _currentPage = activeIndex;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(activeIndex);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _applyThemeBundle(ThemeBundle bundle) async {
    setState(() {
      _isLoading = true;
    });

    final hive = getIt<LocalDataSourceHive>();
    await hive.saveActiveThemeBundle(bundle.id);

    // Apply icon pack package mapping
    if (mounted) {
      context.read<IconPackBloc>().add(SetIconPackSelectionEvent(bundle.iconPackPackage));
    }

    // Clear lister and detail caches
    AppListItem.clearIconCache();
    EditAppListItem.clearIconCache();

    // Reload list data
    if (mounted) {
      context.read<AppsBloc>().add(LoadAppsEvent());
    }

    // Update active theme state to trigger instant wallpaper swap
    LauncherPage.activeThemeBundleNotifier.value = bundle.id;

    // Download and apply system-wide wallpaper in background to target both screens
    if (bundle.wallpaperUrl.isNotEmpty) {
      _applySystemWallpaperFromUrl(bundle.wallpaperUrl);
    }

    if (mounted) {
      Navigator.pop(context); // Close the sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _langCode == 'id'
                ? 'Tema "${bundle.getName(_langCode)}" berhasil diterapkan!'
                : 'Theme "${bundle.getName(_langCode)}" applied successfully!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green.shade800,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _applySystemWallpaperFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/theme_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);
        await getIt<NativeChannel>().setSystemWallpaper(tempFile.path);
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    } catch (e) {
      debugPrint("Error applying system wallpaper from theme bundle: $e");
    }
  }

  Widget _buildPreviewIcon(String bundleId, String label, String pkg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemedIconWidget(
          appLabel: label,
          packageName: pkg,
          originalIconBytes: null,
          activeBundleId: bundleId,
          size: 24.0,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF161616) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    if (_isLoading) {
      return Container(
        height: 520,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF8294E3)),
        ),
      );
    }

    return Container(
      height: 570,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drag Handle Bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _langCode == 'id' ? 'Pilih Tema Bundle' : 'Select Theme Bundle',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: subColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Swipeable PageView Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: ThemeBundle.presets.length,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  final bundle = ThemeBundle.presets[index];
                  final isActive = bundle.id == _activeBundleId;
                  final hasWallpaper = bundle.wallpaperUrl.isNotEmpty;

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.15)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeOut.transform(value) * 390,
                          width: Curves.easeOut.transform(value) * 350,
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      elevation: isActive ? 10 : 3,
                      shadowColor: isActive ? bundle.accentColor.withOpacity(0.4) : Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: isActive ? bundle.accentColor : Colors.white10,
                          width: isActive ? 2.5 : 1,
                        ),
                      ),
                      color: isDark ? const Color(0xFF222222) : Colors.grey.shade100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // Card Wallpaper Background (with overlay)
                            if (hasWallpaper)
                              Positioned.fill(
                                child: Image.network(
                                  bundle.wallpaperUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(hasWallpaper ? 0.2 : 0.0),
                                      Colors.black.withOpacity(hasWallpaper ? 0.9 : 0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Content info
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Active Dot + Bundle Identifier Label
                                  Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: bundle.accentColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: bundle.accentColor.withOpacity(0.6),
                                              blurRadius: 6,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        bundle.id == 'system' ? 'ORIGINAL' : 'PREMIUM BUNDLE',
                                        style: TextStyle(
                                          color: bundle.accentColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  // Theme Display Name
                                  Text(
                                    bundle.getName(_langCode),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Theme Description
                                  Text(
                                    bundle.getDescription(_langCode),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Gorgeous Live Icon Pack Preview Box!
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildPreviewIcon(bundle.id, 'YouTube', 'com.google.android.youtube'),
                                        _buildPreviewIcon(bundle.id, 'WhatsApp', 'com.whatsapp'),
                                        _buildPreviewIcon(bundle.id, 'Gmail', 'com.google.android.gm'),
                                        _buildPreviewIcon(bundle.id, 'Chrome', 'com.android.chrome'),
                                        _buildPreviewIcon(bundle.id, 'Settings', 'com.android.settings'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Apply Theme Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: ElevatedButton(
                                      onPressed: isActive ? null : () => _applyThemeBundle(bundle),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: bundle.accentColor,
                                        disabledBackgroundColor: Colors.white.withOpacity(0.12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            isActive ? Icons.check_circle : Icons.color_lens_outlined,
                                            size: 18,
                                            color: isActive ? Colors.white54 : Colors.black87,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            isActive
                                                ? (_langCode == 'id' ? 'Sedang Aktif' : 'Currently Active')
                                                : (_langCode == 'id' ? 'Terapkan Tema' : 'Apply Theme'),
                                            style: TextStyle(
                                              color: isActive ? Colors.white54 : Colors.black87,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            // Page Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ThemeBundle.presets.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? ThemeBundle.presets[index].accentColor
                        : isDark
                            ? Colors.white24
                            : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
