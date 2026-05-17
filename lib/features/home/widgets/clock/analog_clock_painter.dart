import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnalogClockPainter extends CustomPainter {
  final DateTime dateTime;
  final String styleId;

  AnalogClockPainter(this.dateTime, {this.styleId = 'analog_minimal'});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final center = Offset(centerX, centerY);
    final radius = size.width / 2;

    Paint fillPaint;
    Paint outlinePaint;
    Paint hourHandPaint;
    Paint minuteHandPaint;
    Paint centerDotPaint;

    if (styleId == 'analog_accent') {
      fillPaint = Paint()
        ..color = const Color(0xFFD49B9B).withOpacity(0.2)
        ..style = PaintingStyle.fill;

      outlinePaint = Paint()
        ..color = const Color(0xFFD49B9B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      centerDotPaint = Paint()..color = const Color(0xFFD49B9B);

      hourHandPaint = Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5;

      minuteHandPaint = Paint()
        ..color = Colors.white70
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;
    } else if (styleId == 'analog_glass') {
      fillPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      outlinePaint = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

      centerDotPaint = Paint()..color = const Color(0xFFFF007F);

      hourHandPaint = Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5;

      minuteHandPaint = Paint()
        ..color = const Color(0xFFFF007F)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1);
    } else {
      fillPaint = Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill;

      outlinePaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      centerDotPaint = Paint()..color = Colors.white;

      hourHandPaint = Paint()
        ..color = Colors.white
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.5;

      minuteHandPaint = Paint()
        ..color = const Color(0xFFD49B9B)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2.0;
    }

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, outlinePaint);
    canvas.drawCircle(center, 3, centerDotPaint);

    final hour = dateTime.hour % 12;
    final minute = dateTime.minute;
    final hourAngle = (hour * 30 + minute * 0.5) * math.pi / 180;
    final hourHandLength = radius * 0.5;
    canvas.drawLine(
      center,
      Offset(centerX + hourHandLength * math.sin(hourAngle), centerY - hourHandLength * math.cos(hourAngle)),
      hourHandPaint,
    );

    final minuteAngle = (minute * 6) * math.pi / 180;
    final minuteHandLength = radius * 0.75;
    canvas.drawLine(
      center,
      Offset(centerX + minuteHandLength * math.sin(minuteAngle), centerY - minuteHandLength * math.cos(minuteAngle)),
      minuteHandPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.dateTime != dateTime || oldDelegate.styleId != styleId;
  }
}
