import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'analog_clock_painter.dart';

class ClockWidget extends StatefulWidget {
  final String selectedClockStyle;

  const ClockWidget({
    super.key,
    required this.selectedClockStyle,
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final isAnalog = widget.selectedClockStyle.startsWith('analog');
    final duration = isAnalog ? const Duration(seconds: 1) : const Duration(seconds: 30);
    _timer = Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant ClockWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedClockStyle != widget.selectedClockStyle) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH.mm').format(_now);

    switch (widget.selectedClockStyle) {
      case 'digital_split':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1.0,
                color: Colors.white70,
              ),
            ),
          ],
        );
      case 'digital_accent_split':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Color(0xFFD49B9B),
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        );
      case 'digital_hollow_split':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2
                  ..color = Colors.white,
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        );
      case 'digital_accent':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: DateFormat('HH').format(_now),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                  color: Color(0xFFD49B9B),
                ),
              ),
              const TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                  color: Colors.white54,
                ),
              ),
              TextSpan(
                text: DateFormat('mm').format(_now),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  letterSpacing: -2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      case 'digital_two_tone':
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: DateFormat('HH').format(_now),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: DateFormat('.mm').format(_now),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD49B9B),
                ),
              ),
            ],
          ),
        );
      case 'digital_italic':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            letterSpacing: -2,
            color: Colors.white,
          ),
        );
      case 'digital_ultra_bold':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            letterSpacing: -3,
            color: Colors.white,
          ),
        );
      case 'digital_serif':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 72,
            fontFamily: 'serif',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        );
      case 'digital_mono':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 64,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        );
      case 'digital_spacing':
        final spacingString = DateFormat('H H . m m').format(_now);
        return Text(
          spacingString,
          style: const TextStyle(
            fontSize: 54,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        );
      case 'digital_shadow':
        return Text(
          timeString,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 16,
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(0, 0),
              )
            ],
          ),
        );
      case 'digital_neon':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
            color: Color(0xFFD49B9B),
            shadows: [
              Shadow(
                blurRadius: 12,
                color: Color(0xFFD49B9B),
                offset: Offset(0, 0),
              )
            ],
          ),
        );
      case 'digital_gradient':
        return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD49B9B), Color(0xFFF3C5C5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            timeString,
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.bold,
              letterSpacing: -2,
              color: Colors.white,
            ),
          ),
        );
      case 'digital_underlined':
        return Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD49B9B),
                width: 3,
              ),
            ),
          ),
          child: Text(
            timeString,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        );
      case 'digital_mini':
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: Colors.white,
          ),
        );
      case 'digital_outline':
        return Text(
          timeString,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            letterSpacing: -2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2
              ..color = Colors.white,
          ),
        );
      case 'analog_minimal':
      case 'analog_accent':
      case 'analog_glass':
        return Container(
          width: 96,
          height: 96,
          margin: const EdgeInsets.only(bottom: 8),
          child: CustomPaint(
            painter: AnalogClockPainter(_now, styleId: widget.selectedClockStyle),
          ),
        );
      case 'digital_bold':
      default:
        return Text(
          timeString,
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
            color: Colors.white,
          ),
        );
    }
  }
}
