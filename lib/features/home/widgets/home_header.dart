import 'dart:async';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
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

    return Padding(
      padding: const EdgeInsets.only(left: 32.0, top: 120.0, bottom: 48.0, right: 32.0),
      child: Column(
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
    );
  }
}
