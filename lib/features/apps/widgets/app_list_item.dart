import 'dart:typed_data';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/usecases/app_usecases.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
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

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  static final Map<String, Uint8List> _iconCache = {};

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
    try {
      final appWithIcon = await getIt<GetAppIconUseCase>().call(widget.app);
      if (appWithIcon.icon != null) {
        _iconCache[widget.app.packageName] = appWithIcon.icon!;
        if (mounted) setState(() {});
        return appWithIcon.icon;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  void _openApp(BuildContext context) {
    context.read<AppsBloc>().add(OpenAppEvent(widget.app.packageName));
  }

  void _showOptions(BuildContext context) async {
    final lang = await getIt<LocalDataSourceHive>().getLanguageCode();
    if (!context.mounted) return;

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
              ListTile(
                leading: const Icon(Icons.star, color: Colors.white),
                title: Text(
                  widget.isFavoriteList
                      ? (lang == 'id' ? 'Hapus dari favorit' : 'Remove from favorites')
                      : (lang == 'id' ? 'Tambah ke favorit' : 'Add to favorites'),
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
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cachedIcon = _iconCache[widget.app.packageName];

    return RepaintBoundary(
      child: InkWell(
        onTap: () => _openApp(context),
        onLongPress: () => _showOptions(context),
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        child: ValueListenableBuilder<String>(
          valueListenable: AppListItem.appSizeNotifier,
          builder: (context, appSize, child) {
            double iconSize = 32.0;
            double fontSize = 15.0;
            if (appSize == 'small') {
              iconSize = 28.0;
              fontSize = 13.0;
            } else if (appSize == 'large') {
              iconSize = 40.0;
              fontSize = 18.0;
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isFavoriteList ? 0.0 : 32.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: cachedIcon != null
                        ? Image.memory(
                            cachedIcon,
                            width: iconSize,
                            height: iconSize,
                            gaplessPlayback: true,
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              color: Colors.white12,
                              shape: BoxShape.circle,
                            ),
                          ),
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
