import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_appearance_settings_page.dart';

enum WeatherType { sunny, cloudy, rainy, snowy, thunderstorm }

class WeatherAnimationWidget extends StatefulWidget {
  final String icon;

  const WeatherAnimationWidget({super.key, required this.icon});

  @override
  State<WeatherAnimationWidget> createState() => _WeatherAnimationWidgetState();
}

class _WeatherAnimationWidgetState extends State<WeatherAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Listen to changes in the weather animation setting
    BoxLauncherAppearanceSettingsPage.enableWeatherAnimationsNotifier.addListener(_onSettingChanged);
    _onSettingChanged();
  }

  void _onSettingChanged() {
    if (!mounted) return;
    if (BoxLauncherAppearanceSettingsPage.enableWeatherAnimationsNotifier.value) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    BoxLauncherAppearanceSettingsPage.enableWeatherAnimationsNotifier.removeListener(_onSettingChanged);
    _controller.dispose();
    super.dispose();
  }

  WeatherType _getWeatherType() {
    final icon = widget.icon.toLowerCase();
    if (icon.contains('01')) {
      return WeatherType.sunny;
    } else if (icon.contains('11')) {
      return WeatherType.thunderstorm;
    } else if (icon.contains('09') ||
        icon.contains('10') ||
        icon.contains('drizzle') ||
        icon.contains('rain')) {
      return WeatherType.rainy;
    } else if (icon.contains('13') || icon.contains('snow')) {
      return WeatherType.snowy;
    } else {
      return WeatherType.cloudy;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 32,
          height: 32,
          child: CustomPaint(
            painter: _WeatherPainter(
              type: _getWeatherType(),
              progress: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _WeatherPainter extends CustomPainter {
  final WeatherType type;
  final double progress;

  _WeatherPainter({required this.type, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    switch (type) {
      case WeatherType.sunny:
        _paintSunny(canvas, w, h);
        break;
      case WeatherType.cloudy:
        _paintCloudy(canvas, w, h);
        break;
      case WeatherType.rainy:
        _paintRainy(canvas, w, h);
        break;
      case WeatherType.snowy:
        _paintSnowy(canvas, w, h);
        break;
      case WeatherType.thunderstorm:
        _paintThunderstorm(canvas, w, h);
        break;
    }
  }

  void _paintSunny(Canvas canvas, double w, double h) {
    final center = Offset(w / 2, h / 2);
    
    // 1. Sun Core Pulsing
    final double pulse = 1.0 + 0.08 * math.sin(progress * 2 * math.pi * 2);
    final double radius = 7.5 * pulse;

    final sunPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    
    // Subtle sun core radial glow
    final glowPaint = Paint()
      ..color = Colors.amber.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius + 2.5, glowPaint);
    canvas.drawCircle(center, radius, sunPaint);

    // 2. Rotating rays
    final rayPaint = Paint()
      ..color = Colors.amber.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const int numRays = 8;
    final double startRadius = radius + 3.0;
    final double endRadius = radius + 6.0;
    final double rotationOffset = progress * 2 * math.pi;

    for (int i = 0; i < numRays; i++) {
      final double angle = (i * 2 * math.pi / numRays) + rotationOffset;
      final start = Offset(
        center.dx + startRadius * math.cos(angle),
        center.dy + startRadius * math.sin(angle),
      );
      final end = Offset(
        center.dx + endRadius * math.cos(angle),
        center.dy + endRadius * math.sin(angle),
      );
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _paintCloudy(Canvas canvas, double w, double h) {
    // 1. Double layering for deep premium aesthetic
    // Back cloud (slower, darker, smaller)
    final backSway = 1.0 * math.sin(progress * 2 * math.pi + 1.0);
    _drawCloudShape(
      canvas,
      xOffset: backSway - 1.0,
      yOffset: -2.0,
      scale: 0.85,
      color: Colors.white30,
    );

    // Front cloud (faster, swaying breathing)
    final frontSway = 1.6 * math.sin(progress * 2 * math.pi);
    final double breathingOpacity = 0.85 + 0.12 * math.cos(progress * 2 * math.pi);
    _drawCloudShape(
      canvas,
      xOffset: frontSway,
      yOffset: 0.0,
      scale: 1.0,
      color: Colors.white.withOpacity(breathingOpacity),
    );
  }

  void _paintRainy(Canvas canvas, double w, double h) {
    // 1. Draw top dark grey cloud
    final cloudSway = 1.0 * math.sin(progress * 2 * math.pi);
    _drawCloudShape(
      canvas,
      xOffset: cloudSway,
      yOffset: -3.0,
      scale: 0.95,
      color: Colors.blueGrey[300]!.withOpacity(0.9),
    );

    // 2. Falling rain drops
    final rainPaint = Paint()
      ..color = Colors.blue[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final drops = [
      {'x': 11.0, 'yStart': 19.0, 'offset': 0.0},
      {'x': 16.0, 'yStart': 21.0, 'offset': 0.35},
      {'x': 21.0, 'yStart': 19.0, 'offset': 0.7},
    ];

    for (var drop in drops) {
      final double normProgress = (progress + drop['offset']!) % 1.0;
      final double y = drop['yStart']! + 10.0 * normProgress;
      final double opacity = 1.0 - normProgress;

      rainPaint.color = Colors.blue[300]!.withOpacity(opacity);

      // Draw short diagonal drop stroke line
      final start = Offset(drop['x']!, y);
      final end = Offset(drop['x']! - 1.5, y + 3.0);
      canvas.drawLine(start, end, rainPaint);
    }
  }

  void _paintSnowy(Canvas canvas, double w, double h) {
    // 1. Draw top cloud
    final cloudSway = 0.8 * math.sin(progress * 2 * math.pi);
    _drawCloudShape(
      canvas,
      xOffset: cloudSway,
      yOffset: -3.0,
      scale: 0.95,
      color: Colors.white.withOpacity(0.95),
    );

    // 2. Draw spinning / falling snowflakes
    final snowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final flakes = [
      {'xStart': 11.0, 'yStart': 19.0, 'offset': 0.1},
      {'xStart': 17.0, 'yStart': 21.0, 'offset': 0.5},
      {'xStart': 22.0, 'yStart': 19.0, 'offset': 0.8},
    ];

    for (var flake in flakes) {
      final double normProgress = (progress + flake['offset']!) % 1.0;
      final double y = flake['yStart']! + 9.0 * normProgress;
      
      // Horizontal drift (swaying drift as they float down)
      final double drift = 1.8 * math.sin(progress * 2 * math.pi * 1.5 + flake['offset']! * 10);
      final double x = flake['xStart']! + drift;
      final double opacity = 1.0 - normProgress;

      snowPaint.color = Colors.white.withOpacity(opacity);

      final center = Offset(x, y);
      const double size = 1.8;
      
      // Draw a tiny rotating snowflake cross star
      final double angle = progress * 4 * math.pi + flake['offset']! * 5;
      
      canvas.drawLine(
        Offset(center.dx - size * math.cos(angle), center.dy - size * math.sin(angle)),
        Offset(center.dx + size * math.cos(angle), center.dy + size * math.sin(angle)),
        snowPaint,
      );
      canvas.drawLine(
        Offset(center.dx - size * math.cos(angle + math.pi/2), center.dy - size * math.sin(angle + math.pi/2)),
        Offset(center.dx + size * math.cos(angle + math.pi/2), center.dy + size * math.sin(angle + math.pi/2)),
        snowPaint,
      );
    }
  }

  void _paintThunderstorm(Canvas canvas, double w, double h) {
    // 1. Draw top cloud (very dark thunderstorm grey)
    final cloudSway = 1.2 * math.sin(progress * 2 * math.pi);
    _drawCloudShape(
      canvas,
      xOffset: cloudSway,
      yOffset: -3.0,
      scale: 0.95,
      color: Colors.blueGrey[700]!.withOpacity(0.95),
    );

    // 2. Draw falling drops underneath
    final rainPaint = Paint()
      ..color = Colors.blueGrey[400]!.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final drops = [
      {'x': 10.0, 'yStart': 19.0, 'offset': 0.0},
      {'x': 22.0, 'yStart': 19.0, 'offset': 0.5},
    ];

    for (var drop in drops) {
      final double normProgress = (progress + drop['offset']!) % 1.0;
      final double y = drop['yStart']! + 9.0 * normProgress;
      
      final start = Offset(drop['x']!, y);
      final end = Offset(drop['x']! - 1.2, y + 2.5);
      canvas.drawLine(start, end, rainPaint);
    }

    // 3. Lightning bolt flash
    // Periodic double-flashes with math calculation
    final double flashInterval = (progress * 10) % 2.0;
    final bool isFlashing = (flashInterval > 0.05 && flashInterval < 0.18) ||
                            (flashInterval > 0.30 && flashInterval < 0.43);

    if (isFlashing) {
      final lightningPaint = Paint()
        ..color = Colors.yellowAccent
        ..style = PaintingStyle.fill;

      // Draw lightning bolt path
      final path = Path();
      path.moveTo(17.0 + cloudSway, 17.0); // start under cloud
      path.lineTo(13.0 + cloudSway, 23.0); // middle joint
      path.lineTo(17.5 + cloudSway, 23.0); // joint offset
      path.lineTo(14.5 + cloudSway, 29.5); // bottom tip
      path.lineTo(18.5 + cloudSway, 22.0); // recovery joint
      path.lineTo(14.5 + cloudSway, 22.0); // recovery joint offset
      path.close();

      // Outer glow shadow
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, lightningPaint);
    }
  }

  void _drawCloudShape(
    Canvas canvas, {
    required double xOffset,
    required double yOffset,
    required double scale,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw the rounded segments of a cloud
    // Left circle
    canvas.drawCircle(
      Offset((11.5 + xOffset) * scale, (19.0 + yOffset) * scale),
      5.0 * scale,
      paint,
    );
    // Center big circle
    canvas.drawCircle(
      Offset((16.5 + xOffset) * scale, (14.0 + yOffset) * scale),
      7.0 * scale,
      paint,
    );
    // Right circle
    canvas.drawCircle(
      Offset((21.5 + xOffset) * scale, (19.0 + yOffset) * scale),
      5.0 * scale,
      paint,
    );
    // Baseline bridging rectangle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          (11.5 + xOffset) * scale,
          (14.5 + yOffset) * scale,
          (21.5 + xOffset) * scale,
          (24.0 + yOffset) * scale,
        ),
        Radius.circular(4.0 * scale),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _WeatherPainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.progress != progress;
  }
}