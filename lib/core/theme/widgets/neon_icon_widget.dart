import 'package:flutter/material.dart';

class NeonIconWidget extends StatelessWidget {
  final String appLabel;
  final String packageName;
  final IconData iconData;
  final double size;

  const NeonIconWidget({
    super.key,
    required this.appLabel,
    required this.packageName,
    required this.iconData,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLetter = iconData == Icons.star_border_rounded;
    
    final Color neonColor;
    if (packageName.hashCode % 2 == 0) {
      neonColor = const Color(0xFFF72585);
    } else {
      neonColor = const Color(0xFF4CC9F0);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: neonColor.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: neonColor.withOpacity(0.25),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: neonColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                iconData,
                color: neonColor,
                size: size * 0.52,
              ),
      ),
    );
  }
}
