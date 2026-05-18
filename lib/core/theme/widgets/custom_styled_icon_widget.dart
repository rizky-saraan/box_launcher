import 'package:flutter/material.dart';

class CustomStyledIconWidget extends StatelessWidget {
  final String appLabel;
  final IconData iconData;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final double borderRadius;
  final BoxShape shape;
  final double borderWidth;
  final List<BoxShadow>? boxShadows;

  const CustomStyledIconWidget({
    super.key,
    required this.appLabel,
    required this.iconData,
    required this.size,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
    this.borderWidth = 1.0,
    this.boxShadows,
  });

  @override
  Widget build(BuildContext context) {
    final bool useLetter = iconData == Icons.star_border_rounded;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: boxShadows,
      ),
      child: Center(
        child: useLetter
            ? Text(
                appLabel.isNotEmpty ? appLabel[0].toUpperCase() : 'A',
                style: TextStyle(
                  color: iconColor,
                  fontSize: 15,
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
