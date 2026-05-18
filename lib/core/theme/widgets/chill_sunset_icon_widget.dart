import 'package:flutter/material.dart';

class ChillSunsetIconWidget extends StatelessWidget {
  final String appLabel;
  final String packageName;
  final IconData iconData;
  final double size;

  const ChillSunsetIconWidget({
    super.key,
    required this.appLabel,
    required this.packageName,
    required this.iconData,
    required this.size,
  });

  static const Map<String, int> _sunsetHexColors = {
    'instagram': 0xFFE1306C,
    'telegram': 0xFF0088CC,
    'whatsapp': 0xFF25D366,
    'youtube': 0xFFFF0000,
    'gmail': 0xFFD44638,
    'email': 0xFFD44638,
    'mail': 0xFFD44638,
    'chrome': 0xFF4285F4,
    'browser': 0xFF4285F4,
    'shopee': 0xFFEE4D2D,
    'tokopedia': 0xFF03AC0E,
    'spotify': 0xFF1DB954,
    'setting': 0xFF607D8B,
  };

  @override
  Widget build(BuildContext context) {
    final bool useLetter = iconData == Icons.star_border_rounded;
    final pkg = packageName.toLowerCase();

    int hexColor = 0xFFE07A5F;
    for (final entry in _sunsetHexColors.entries) {
      if (pkg.contains(entry.key)) {
        hexColor = entry.value;
        break;
      }
    }

    final Color iconColor = Color(hexColor);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black12, width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: iconColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                iconData,
                color: iconColor,
                size: size * 0.55,
              ),
      ),
    );
  }
}
