import 'package:flutter/material.dart';

class AlpineIconWidget extends StatelessWidget {
  final String appLabel;
  final IconData iconData;
  final double size;

  const AlpineIconWidget({
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
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30, width: 1.0),
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                iconData,
                color: Colors.white,
                size: size * 0.55,
              ),
      ),
    );
  }
}
