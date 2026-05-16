import 'dart:async';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(_now);
    final dateString = DateFormat('EEEE, d MMM').format(_now);

    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
      ),
      padding: const EdgeInsets.only(left: 32.0, top: 120.0, bottom: 48.0, right: 32.0),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                          letterSpacing: -2,
                          color: Colors.white,
                        ),
                      ),
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
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, color: Colors.white54),
                    onPressed: () => _showThemeSettings(context),
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
                          style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
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
    );
  }
  void _showThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: BlocBuilder<IconPackBloc, IconPackState>(
            builder: (context, state) {
              if (state is IconPackLoading) {
                return const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is IconPackLoaded) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Select Icon Pack',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.availableIconPacks.length,
                        itemBuilder: (context, index) {
                          final pack = state.availableIconPacks[index];
                          final isSelected = pack['packageName'] == state.selectedIconPack || 
                                            (state.selectedIconPack == null && pack['packageName'] == "");
                          return ListTile(
                            title: Text(pack['label'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
                            trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                            onTap: () {
                              context.read<IconPackBloc>().add(SetIconPackSelectionEvent(pack['packageName']));
                              // Reload apps so the icons refresh
                              context.read<AppsBloc>().add(LoadAppsEvent());
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }
}
