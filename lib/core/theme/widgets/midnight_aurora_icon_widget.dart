import 'package:flutter/material.dart';

class MidnightAuroraIconWidget extends StatelessWidget {
  final String appLabel;
  final String packageName;
  final IconData iconData;
  final double size;

  const MidnightAuroraIconWidget({
    super.key,
    required this.appLabel,
    required this.packageName,
    required this.iconData,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLetter = iconData == Icons.star_border_rounded;
    
    // Northern Lights dynamic shimmer colors (alternates between cosmic teal and bright polar violet)
    final Color auroraColor = packageName.hashCode % 2 == 0 
        ? const Color(0xFF00F5D4) 
        : const Color(0xFF9D4EDD);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0B132B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: auroraColor.withOpacity(0.7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: auroraColor.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: auroraColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                iconData,
                color: auroraColor,
                size: size * 0.55,
              ),
      ),
    );
  }
}
