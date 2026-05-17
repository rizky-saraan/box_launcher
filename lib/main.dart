import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/core/theme/bloc/theme_bloc.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/launcher/bloc/launcher_bloc.dart';
import 'package:box_launcher/features/launcher/pages/launcher_page.dart';
import 'package:box_launcher/features/search/bloc/search_bloc.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);
  configureDependencies();
  runApp(const BoxLauncherApp());
}

class BoxLauncherApp extends StatelessWidget {
  const BoxLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ThemeBloc>()),
        BlocProvider(create: (_) => getIt<LauncherBloc>()),
        BlocProvider(create: (_) => getIt<AppsBloc>()..add(LoadAppsEvent())),
        BlocProvider(create: (_) => getIt<FavoritesBloc>()..add(LoadFavoritesEvent())),
        BlocProvider(create: (_) => getIt<SearchBloc>()),
        BlocProvider(create: (_) => getIt<IconPackBloc>()..add(LoadIconPackEvent())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Box Launcher',
            theme: ThemeData.light(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: Colors.transparent,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              scaffoldBackgroundColor: Colors.transparent,
              textTheme: Typography.material2021().white.apply(
                fontFamily: 'Roboto',
              ),
            ),
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            debugShowCheckedModeBanner: false,
            home: const LauncherPage(),
          );
        },
      ),
    );
  }
}
