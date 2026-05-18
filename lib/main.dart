import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/core/theme/bloc/theme_bloc.dart';
import 'package:box_launcher/core/theme/font_manager.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/features/launcher/bloc/launcher_bloc.dart';
import 'package:box_launcher/features/launcher/pages/launcher_page.dart';
import 'package:box_launcher/features/search/bloc/search_bloc.dart';
import 'package:box_launcher/domain/usecases/theme_usecases.dart';
import 'package:box_launcher/features/icon_pack/bloc/icon_pack_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Intercept and quietly filter out the known internal Flutter framework hardware keyboard state assertion bug
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exception.toString();
    if (exceptionStr.contains("hardware_keyboard.dart") ||
        exceptionStr.contains("physical key is not pressed")) {
      // Quietly ignore this harmless framework keyboard keyup assertion mismatch
      return;
    }
    FlutterError.presentError(details);
  };

  await Hive.initFlutter();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);
  configureDependencies();

  // Initialize the FontManager to load the active font and register custom OTF/TTF files
  await FontManager.initialize();

  // Initialize the native channel with the selected icon pack BEFORE launcher loads UI and icons!
  try {
    final activeIconPack = await getIt<GetIconPackUseCase>().call();
    await getIt<SetIconPackUseCase>().call(activeIconPack);
  } catch (e) {
    // ignore
  }

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
          return ValueListenableBuilder<String>(
            valueListenable: FontManager.activeFontNotifier,
            builder: (context, activeFont, child) {
              // Get core Material TextThemes
              final TextTheme baseTextThemeLight = Typography.material2021().black;
              final TextTheme baseTextThemeDark = Typography.material2021().white;

              // Apply dynamic (built-in Google Font or loaded custom family) text themes
              final TextTheme dynamicTextThemeLight = FontManager.applyDynamicFontToTextTheme(baseTextThemeLight);
              final TextTheme dynamicTextThemeDark = FontManager.applyDynamicFontToTextTheme(baseTextThemeDark);

              return MaterialApp(
                title: 'Saraan Launcher',
                theme: ThemeData.light(useMaterial3: true).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  textTheme: dynamicTextThemeLight,
                ),
                darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
                  scaffoldBackgroundColor: Colors.transparent,
                  textTheme: dynamicTextThemeDark,
                ),
                themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                home: const LauncherPage(),
              );
            },
          );
        },
      ),
    );
  }
}
