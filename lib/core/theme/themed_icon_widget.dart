import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'widgets/alpine_icon_widget.dart';
import 'widgets/nordic_icon_widget.dart';
import 'widgets/neon_icon_widget.dart';
import 'widgets/chill_sunset_icon_widget.dart';
import 'widgets/custom_styled_icon_widget.dart';
import 'widgets/midnight_aurora_icon_widget.dart';

class ThemedIconWidget extends StatelessWidget {
  final String appLabel;
  final String packageName;
  final Uint8List? originalIconBytes;
  final String activeBundleId;
  final double size;

  const ThemedIconWidget({
    super.key,
    required this.appLabel,
    required this.packageName,
    required this.originalIconBytes,
    required this.activeBundleId,
    this.size = 32.0,
  });

  // Static Outlined Vector Icon Mappings
  static const Map<String, IconData> _mappings = {
    'instagram': Icons.camera_alt_outlined,
    'telegram': Icons.send_rounded,
    'whatsapp': Icons.chat_bubble_outline_rounded,
    'youtube': Icons.play_circle_outline_rounded,
    'gmail': Icons.mail_outline_rounded,
    'email': Icons.mail_outline_rounded,
    'mail': Icons.mail_outline_rounded,
    'chrome': Icons.language_rounded,
    'browser': Icons.language_rounded,
    'camera': Icons.camera_alt_outlined,
    'phone': Icons.phone_outlined,
    'dialer': Icons.phone_outlined,
    'telepon': Icons.phone_outlined,
    'message': Icons.sms_outlined,
    'sms': Icons.sms_outlined,
    'mms': Icons.sms_outlined,
    'pesan': Icons.sms_outlined,
    'setting': Icons.settings_outlined,
    'pengaturan': Icons.settings_outlined,
    'play': Icons.shop_outlined,
    'spotify': Icons.music_note_outlined,
    'music': Icons.music_note_outlined,
    'musik': Icons.music_note_outlined,
    'gallery': Icons.photo_outlined,
    'photo': Icons.photo_outlined,
    'galeri': Icons.photo_outlined,
    'calendar': Icons.calendar_today_outlined,
    'kalender': Icons.calendar_today_outlined,
    'clock': Icons.access_time,
    'jam': Icons.access_time,
    'time': Icons.access_time,
    'calculator': Icons.calculate_outlined,
    'kalkulator': Icons.calculate_outlined,
    'map': Icons.map_outlined,
    'peta': Icons.map_outlined,
    'file': Icons.folder_open_outlined,
    'folder': Icons.folder_open_outlined,
    'berkas': Icons.folder_open_outlined,
    'shopee': Icons.shopping_bag_outlined,
    'tokopedia': Icons.shopping_bag_outlined,
    'store': Icons.shopping_bag_outlined,
    'shop': Icons.shopping_bag_outlined,
    'toko': Icons.shopping_bag_outlined,
    'game': Icons.sports_esports_outlined,
    'permainan': Icons.sports_esports_outlined,
  };

  IconData _getIconData() {
    final label = appLabel.toLowerCase();
    final pkg = packageName.toLowerCase();

    for (final entry in _mappings.entries) {
      if (pkg.contains(entry.key) || label.contains(entry.key)) {
        return entry.value;
      }
    }

    return Icons.star_border_rounded;
  }

  @override
  Widget build(BuildContext context) {
    // If system default theme is active, always show the original colorful system icon!
    if (activeBundleId == 'system') {
      if (originalIconBytes != null) {
        return Image.memory(
          originalIconBytes!,
          width: size,
          height: size,
          gaplessPlayback: true,
        );
      }
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white12,
          shape: BoxShape.circle,
        ),
      );
    }

    final iconData = _getIconData();

    switch (activeBundleId) {
      case 'alpine_clouds':
        return AlpineIconWidget(appLabel: appLabel, iconData: iconData, size: size);
      case 'nordic_spruce':
        return NordicIconWidget(appLabel: appLabel, iconData: iconData, size: size);
      case 'neon_cyberpunk':
        return NeonIconWidget(appLabel: appLabel, packageName: packageName, iconData: iconData, size: size);
      case 'chill_sunset':
        return ChillSunsetIconWidget(appLabel: appLabel, packageName: packageName, iconData: iconData, size: size);
      case 'midnight_aurora':
        return MidnightAuroraIconWidget(appLabel: appLabel, packageName: packageName, iconData: iconData, size: size);

      // Remaining 10 themes map to our dynamic CustomStyledIconWidget!
      case 'golden_sahara':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFF2C221E).withOpacity(0.4),
          borderColor: const Color(0xFFE0A96D).withOpacity(0.5),
          iconColor: const Color(0xFFE0A96D),
          borderRadius: 12,
          shape: BoxShape.rectangle,
        );
      case 'sakura_blossom':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFFFFB7C5).withOpacity(0.12),
          borderColor: const Color(0xFFFFB7C5).withOpacity(0.5),
          iconColor: const Color(0xFFFFB7C5),
          borderRadius: 16,
          shape: BoxShape.rectangle,
        );
      case 'deep_ocean':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFF03045E).withOpacity(0.3),
          borderColor: const Color(0xFF00B4D8).withOpacity(0.6),
          iconColor: const Color(0xFF00B4D8),
          borderRadius: size / 2,
          shape: BoxShape.circle,
        );
      case 'volcanic_ash':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFF150A0A).withOpacity(0.8),
          borderColor: const Color(0xFFD9381E).withOpacity(0.7),
          iconColor: const Color(0xFFD9381E),
          borderRadius: 8,
          shape: BoxShape.rectangle,
        );
      case 'lavender_fields':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFFE8E5F7).withOpacity(0.15),
          borderColor: const Color(0xFFB39DDB).withOpacity(0.6),
          iconColor: const Color(0xFFB39DDB),
          borderRadius: size / 2,
          shape: BoxShape.circle,
        );
      case 'earthy_terracotta':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFFF9F5F0),
          borderColor: const Color(0xFFC97A64).withOpacity(0.4),
          iconColor: const Color(0xFFC97A64),
          borderRadius: 10,
          shape: BoxShape.rectangle,
          borderWidth: 1.2,
        );
      case 'monochrome_slate':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFF121212),
          borderColor: const Color(0xFF333333),
          iconColor: Colors.white,
          borderRadius: 4,
          shape: BoxShape.rectangle,
        );
      case 'retro_arcade':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: Colors.black87,
          borderColor: const Color(0xFFF1F514),
          iconColor: const Color(0xFF00FFCC),
          borderRadius: 6,
          shape: BoxShape.rectangle,
          borderWidth: 1.2,
        );
      case 'botanical_garden':
        return CustomStyledIconWidget(
          appLabel: appLabel,
          iconData: iconData,
          size: size,
          backgroundColor: const Color(0xFFE8F5E9).withOpacity(0.2),
          borderColor: const Color(0xFF2EC4B6).withOpacity(0.6),
          iconColor: const Color(0xFF2EC4B6),
          borderRadius: 14,
          shape: BoxShape.rectangle,
        );

      default:
        return AlpineIconWidget(appLabel: appLabel, iconData: iconData, size: size);
    }
  }
}
