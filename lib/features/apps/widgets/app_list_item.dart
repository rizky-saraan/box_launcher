import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppListItem extends StatefulWidget {
  final AppInfo app;
  final bool isFavoriteList;

  const AppListItem({
    super.key,
    required this.app,
    this.isFavoriteList = false,
  });

  @override
  State<AppListItem> createState() => _AppListItemState();
}

class _AppListItemState extends State<AppListItem> {
  @override
  void initState() {
    super.initState();
    if (widget.app.icon == null) {
      context.read<AppsBloc>().add(LoadAppIconEvent(widget.app));
    }
  }

  void _openApp(BuildContext context) {
    context.read<AppsBloc>().add(OpenAppEvent(widget.app.packageName));
  }

  void _showOptions(BuildContext context) {
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
                  widget.isFavoriteList ? 'Remove from favorites' : 'Add to favorites',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
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
    return InkWell(
      onTap: () => _openApp(context),
      onLongPress: () => _showOptions(context),
      splashColor: Colors.white10,
      highlightColor: Colors.white10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
        child: Row(
          children: [
            if (widget.app.icon != null)
              Image.memory(
                widget.app.icon!,
                width: 40,
                height: 40,
                gaplessPlayback: true,
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white12,
                  shape: BoxShape.circle,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.app.label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
