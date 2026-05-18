import 'package:flutter/material.dart';

class NordicIconWidget extends StatelessWidget {
  final String appLabel;
  final IconData iconData;
  final double size;

  const NordicIconWidget({
    super.key,
    required this.appLabel,
    required this.iconData,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLetter = iconData == Icons.star_border_rounded;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E2A).withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8BBCA9).withOpacity(0.4), width: 1.2),
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Color(0xFF8BBCA9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                iconData,
                color: const Color(0xFF8BBCA9),
                size: size * 0.55,
              ),
      ),
    );
  }
}
