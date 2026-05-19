import 'dart:typed_data';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/usecases/app_usecases.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/core/theme/themed_icon_widget.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/launcher/pages/launcher_page.dart';
import 'package:box_launcher/features/launcher/widgets/app_lock_pin_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppListItem extends StatefulWidget {
  final AppInfo app;
  final bool isFavoriteList;

  static final ValueNotifier<String> appSizeNotifier = ValueNotifier<String>('medium');

  const AppListItem({
    super.key,
    required this.app,
    this.isFavoriteList = false,
  });

  static void clearIconCache() {
    _AppListItemState._iconCache.clear();
  }

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  static final Map<String, Uint8List> _iconCache = {};
  static final Set<String> _loadingPackages = {};

  @override
  void initState() {
    super.initState();
    if (widget.app.icon != null) {
      _iconCache[widget.app.packageName] = widget.app.icon!;
    } else if (!_iconCache.containsKey(widget.app.packageName)) {
      _loadIcon();
    }
  }

  Future<Uint8List?> _loadIcon() async {
    final pkg = widget.app.packageName;
    if (_iconCache.containsKey(pkg)) {
      return _iconCache[pkg];
    }
    if (_loadingPackages.contains(pkg)) {
      return null;
    }
    _loadingPackages.add(pkg);
    try {
      final appWithIcon = await getIt<GetAppIconUseCase>().call(widget.app);
      if (appWithIcon.icon != null) {
        _iconCache[pkg] = appWithIcon.icon!;
        if (mounted) setState(() {});
        return appWithIcon.icon;
      }
    } catch (e) {
      // ignore
    } finally {
      _loadingPackages.remove(pkg);
    }
    return null;
  }

  void _openApp(BuildContext context) async {
    final hive = getIt<LocalDataSourceHive>();
    final lockedApps = await hive.getLockedApps();
    final pin = await hive.getAppLockPin();

    if (lockedApps.contains(widget.app.packageName) && pin != null && pin.isNotEmpty) {
      if (!context.mounted) return;
      final success = await showAppLockPinSheet(context, pin);
      if (success) {
        if (context.mounted) {
          context.read<AppsBloc>().add(OpenAppEvent(widget.app.packageName));
        }
      }
    } else {
      if (context.mounted) {
        context.read<AppsBloc>().add(OpenAppEvent(widget.app.packageName));
      }
    }
  }

  void _showOptions(BuildContext context) async {
    final hive = getIt<LocalDataSourceHive>();
    final lang = await hive.getLanguageCode();
    final lockedApps = await hive.getLockedApps();
    final hiddenApps = await hive.getHiddenApps();
    final pin = await hive.getAppLockPin();
    final hasPin = pin != null && pin.isNotEmpty;

    if (!context.mounted) return;

    final isLocked = lockedApps.contains(widget.app.packageName);
    final isHidden = hiddenApps.contains(widget.app.packageName);
    final isIndonesian = lang == 'id';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite option
              ListTile(
                leading: const Icon(Icons.star, color: Colors.white),
                title: Text(
                  widget.isFavoriteList
                      ? (isIndonesian ? 'Hapus dari favorit' : 'Remove from favorites')
                      : (isIndonesian ? 'Tambah ke favorit' : 'Add to favorites'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  if (widget.isFavoriteList) {
                    context.read<FavoritesBloc>().add(RemoveFavoriteEvent(widget.app));
                  } else {
                    context.read<FavoritesBloc>().add(AddFavoriteEvent(widget.app));
                  }
                },
              ),
              
              // App Lock option
              ListTile(
                leading: Icon(
                  isLocked ? Icons.lock_open : Icons.lock,
                  color: Colors.white,
                ),
                title: Text(
                  isLocked
                      ? (isIndonesian ? 'Buka Kunci Aplikasi' : 'Unlock App')
                      : (isIndonesian ? 'Kunci Aplikasi dengan PIN' : 'Lock App with PIN'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!hasPin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isIndonesian
                              ? 'Harap atur PIN Keamanan terlebih dahulu di menu Pengaturan!'
                              : 'Please set up a Security PIN first in Launcher Settings!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.amber.shade900,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  
                  final updatedList = List<String>.from(lockedApps);
                  if (isLocked) {
                    updatedList.remove(widget.app.packageName);
                  } else {
                    updatedList.add(widget.app.packageName);
                  }
                  await hive.saveLockedApps(updatedList);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isLocked
                              ? (isIndonesian ? 'Aplikasi Berhasil Dibuka Kunci!' : 'App Unlocked Successfully!')
                              : (isIndonesian ? 'Aplikasi Berhasil Dikunci!' : 'App Locked Successfully!'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),

              // App Hider option
              ListTile(
                leading: Icon(
                  isHidden ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                title: Text(
                  isHidden
                      ? (isIndonesian ? 'Tampilkan Kembali Aplikasi' : 'Unhide App')
                      : (isIndonesian ? 'Sembunyikan Aplikasi' : 'Hide App'),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  if (!hasPin) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isIndonesian
                              ? 'Harap atur PIN Keamanan terlebih dahulu di menu Pengaturan!'
                              : 'Please set up a Security PIN first in Launcher Settings!',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.amber.shade900,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                  
                  final updatedList = List<String>.from(hiddenApps);
                  if (isHidden) {
                    updatedList.remove(widget.app.packageName);
                  } else {
                    updatedList.add(widget.app.packageName);
                  }
                  await hive.saveHiddenApps(updatedList);
                  
                  // Reload the main list so it disappears instantly
                  if (context.mounted) {
                    context.read<AppsBloc>().add(LoadAppsEvent());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isHidden
                              ? (isIndonesian ? 'Aplikasi Ditampilkan Kembali!' : 'App Unhidden Successfully!')
                              : (isIndonesian ? 'Aplikasi Berhasil Disembunyikan!' : 'App Hidden Successfully!'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green.shade800,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedIcon = _iconCache[widget.app.packageName];
    if (cachedIcon == null) {
      _loadIcon();
    }

    return RepaintBoundary(
      child: InkWell(
        onTap: () => _openApp(context),
        onLongPress: () => _showOptions(context),
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        child: ValueListenableBuilder<String>(
          valueListenable: AppListItem.appSizeNotifier,
          builder: (context, appSize, child) {
            double iconSize = 34.0;
            double fontSize = 16.0;
            if (appSize == 'small') {
              iconSize = 29.0;
              fontSize = 13.0;
            } else if (appSize == 'large') {
              iconSize = 39.0;
              fontSize = 18.0;
            } else if (appSize == 'medium') {
              iconSize = 34.0;
              fontSize = 16.0;
            } else {
              final val = int.tryParse(appSize) ?? 5;
              iconSize = 24.0 + (val - 1) * 2.5;
              fontSize = 12.0 + (val - 1) * 1.0;
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isFavoriteList ? 0.0 : 32.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: LauncherPage.activeThemeBundleNotifier,
                    builder: (context, activeBundleId, _) {
                      return ThemedIconWidget(
                        appLabel: widget.app.label,
                        packageName: widget.app.packageName,
                        originalIconBytes: cachedIcon,
                        activeBundleId: activeBundleId,
                        size: iconSize,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.app.label,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
