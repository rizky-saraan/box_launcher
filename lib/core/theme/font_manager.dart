import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';

class FontManager {
  static final ValueNotifier<String> activeFontNotifier = ValueNotifier<String>('Default');

  // List of 20 premium pre-packaged Google Fonts
  static const List<String> builtinFonts = [
    'Default',
    'Inter',
    'Roboto',
    'Outfit',
    'Plus Jakarta Sans',
    'Montserrat',
    'Poppins',
    'Lora',
    'Merriweather',
    'Playfair Display',
    'Fira Code',
    'JetBrains Mono',
    'Lexend',
    'DM Sans',
    'Quicksand',
    'Oswald',
    'Cinzel',
    'Pacifico',
    'Ubuntu',
    'Syne',
  ];

  // Map of Custom Family Name -> Saved Local File Path
  static final ValueNotifier<Map<String, String>> customFontsNotifier =
      ValueNotifier<Map<String, String>>({});

  // Initialize and register all custom fonts, and load the active font
  static Future<void> initialize() async {
    try {
      final hive = getIt<LocalDataSourceHive>();
      
      // Load saved custom fonts map
      final customFonts = await hive.getCustomFonts();
      customFontsNotifier.value = customFonts;

      // Register all custom fonts with Flutter's FontLoader
      for (final entry in customFonts.entries) {
        await _registerLocalFont(entry.key, entry.value);
      }

      // Load active font selection
      final activeFont = await hive.getActiveFont();
      activeFontNotifier.value = activeFont;
    } catch (e) {
      debugPrint("Error initializing FontManager: $e");
    }
  }

  // Register a .ttf or .otf file from a local path with Flutter Engine
  static Future<void> _registerLocalFont(String familyName, String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint("Font file not found at path: $filePath");
        return;
      }

      final bytes = await file.readAsBytes();
      final fontLoader = FontLoader(familyName);
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();
      debugPrint("Successfully loaded custom font: $familyName");
    } catch (e) {
      debugPrint("Failed to register custom font $familyName: $e");
    }
  }

  // Set active font
  static Future<void> setActiveFont(String fontName) async {
    final hive = getIt<LocalDataSourceHive>();
    await hive.saveActiveFont(fontName);
    activeFontNotifier.value = fontName;
  }

  // Let the user pick a custom .ttf or .otf file from local storage
  static Future<String?> pickAndInstallCustomFont() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf'],
        compressionQuality: 0,
      );

      if (result == null || result.files.single.path == null) {
        return null; // Canceled by user
      }

      final File originalFile = File(result.files.single.path!);
      final String originalName = result.files.single.name;
      
      // Sanitized Font Family Name (e.g. "MyFont_Roboto")
      final String cleanName = originalName
          .replaceAll(RegExp(r'\.(ttf|otf)$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\s]'), '')
          .trim();
      
      final String familyName = 'Custom_$cleanName';

      // Duplicate check
      if (customFontsNotifier.value.containsKey(familyName)) {
        return 'duplicate';
      }

      // Copy file to dynamic fonts folder in app documents
      final directory = await getApplicationDocumentsDirectory();
      final fontsDir = Directory('${directory.path}/custom_fonts');
      if (!await fontsDir.exists()) {
        await fontsDir.create(recursive: true);
      }

      final String extension = originalName.split('.').last.toLowerCase();
      final String targetPath = '${fontsDir.path}/$familyName.$extension';
      
      await originalFile.copy(targetPath);

      // Register the copied file dynamically with Flutter Engine
      await _registerLocalFont(familyName, targetPath);

      // Save to persistent storage
      final updatedCustomFonts = Map<String, String>.from(customFontsNotifier.value);
      updatedCustomFonts[familyName] = targetPath;
      
      final hive = getIt<LocalDataSourceHive>();
      await hive.saveCustomFonts(updatedCustomFonts);
      customFontsNotifier.value = updatedCustomFonts;

      // Automatically set as active font
      await setActiveFont(familyName);

      return familyName;
    } catch (e) {
      debugPrint("Error picking custom font: $e");
      return 'error';
    }
  }

  // Delete an installed custom font
  static Future<void> deleteCustomFont(String familyName) async {
    try {
      final updatedCustomFonts = Map<String, String>.from(customFontsNotifier.value);
      final String? filePath = updatedCustomFonts.remove(familyName);

      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final hive = getIt<LocalDataSourceHive>();
      await hive.saveCustomFonts(updatedCustomFonts);
      customFontsNotifier.value = updatedCustomFonts;

      // If active, fall back to Default
      if (activeFontNotifier.value == familyName) {
        await setActiveFont('Default');
      }
    } catch (e) {
      debugPrint("Error deleting custom font $familyName: $e");
    }
  }

  // Generate TextStyle dynamically for any active font
  static TextStyle getTextStyle(TextStyle baseStyle, {String? family}) {
    final String activeFont = family ?? activeFontNotifier.value;

    if (activeFont == 'Default') {
      return baseStyle.copyWith(fontFamily: null);
    }

    if (activeFont.startsWith('Custom_')) {
      return baseStyle.copyWith(fontFamily: activeFont);
    }

    // Google Fonts selection
    try {
      return GoogleFonts.getFont(
        activeFont,
        textStyle: baseStyle,
      );
    } catch (e) {
      // Fallback in case of network issues or invalid name
      return baseStyle.copyWith(fontFamily: null);
    }
  }

  // Generate a complete dynamic Theme TextTheme based on the active font
  static TextTheme applyDynamicFontToTextTheme(TextTheme baseTextTheme) {
    final String activeFont = activeFontNotifier.value;

    if (activeFont == 'Default') {
      return baseTextTheme;
    }

    if (activeFont.startsWith('Custom_')) {
      return baseTextTheme.apply(fontFamily: activeFont);
    }

    try {
      return GoogleFonts.getTextTheme(activeFont, baseTextTheme);
    } catch (e) {
      return baseTextTheme;
    }
  }
}
