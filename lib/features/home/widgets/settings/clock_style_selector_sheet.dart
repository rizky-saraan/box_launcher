import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../clock/analog_clock_painter.dart';

class ClockStyleSelectorSheet extends StatefulWidget {
  final String selectedClockStyle;
  final ValueChanged<String> onClockStyleChanged;

  const ClockStyleSelectorSheet({
    super.key,
    required this.selectedClockStyle,
    required this.onClockStyleChanged,
  });

  @override
  State<ClockStyleSelectorSheet> createState() => _ClockStyleSelectorSheetState();
}

class _ClockStyleSelectorSheetState extends State<ClockStyleSelectorSheet> {
  late DateTime _now;
  Timer? _timer;
  late String _currentStyle;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _currentStyle = widget.selectedClockStyle;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildClockPreviewCard(
      BuildContext context, String styleId, String label, StateSetter setSubState) {
    final isSelected = _currentStyle == styleId;
    final timeString = DateFormat('HH.mm').format(_now);

    Widget clockWidget;
    switch (styleId) {
      case 'digital_split':
        clockWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Colors.white,
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                height: 1.0,
                color: Colors.white70,
              ),
            ),
          ],
        );
        break;
      case 'digital_accent_split':
        clockWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Color(0xFFD49B9B),
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        );
        break;
      case 'digital_hollow_split':
        clockWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH').format(_now),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.0,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 1.0
                  ..color = Colors.white,
              ),
            ),
            Text(
              DateFormat('mm').format(_now),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        );
        break;
      case 'digital_accent':
        clockWidget = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: DateFormat('HH').format(_now),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD49B9B),
                ),
              ),
              const TextSpan(
                text: '.',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white54,
                ),
              ),
              TextSpan(
                text: DateFormat('mm').format(_now),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
        break;
      case 'digital_two_tone':
        clockWidget = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: DateFormat('HH').format(_now),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextSpan(
                text: DateFormat('.mm').format(_now),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD49B9B),
                ),
              ),
            ],
          ),
        );
        break;
      case 'digital_italic':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        );
        break;
      case 'digital_ultra_bold':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        );
        break;
      case 'digital_serif':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 28,
            fontFamily: 'serif',
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        );
        break;
      case 'digital_mono':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 24,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        );
        break;
      case 'digital_spacing':
        final spacingString = DateFormat('H H . m m').format(_now);
        clockWidget = Text(
          spacingString,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        );
        break;
      case 'digital_shadow':
        clockWidget = Text(
          timeString,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(0, 0),
              )
            ],
          ),
        );
        break;
      case 'digital_neon':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD49B9B),
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Color(0xFFD49B9B),
                offset: Offset(0, 0),
              )
            ],
          ),
        );
        break;
      case 'digital_gradient':
        clockWidget = ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFD49B9B), Color(0xFFF3C5C5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            timeString,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        break;
      case 'digital_underlined':
        clockWidget = Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD49B9B),
                width: 2,
              ),
            ),
          ),
          child: Text(
            timeString,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
        );
        break;
      case 'digital_mini':
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
        break;
      case 'digital_outline':
        clockWidget = Text(
          timeString,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.0
              ..color = Colors.white,
          ),
        );
        break;
      case 'analog_minimal':
      case 'analog_accent':
      case 'analog_glass':
        clockWidget = SizedBox(
          width: 38,
          height: 38,
          child: CustomPaint(
            painter: AnalogClockPainter(_now, styleId: styleId),
          ),
        );
        break;
      case 'digital_bold':
      default:
        clockWidget = Text(
          timeString,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        );
        break;
    }

    return GestureDetector(
      onTap: () {
        widget.onClockStyleChanged(styleId);
        setState(() {
          _currentStyle = styleId;
        });
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF5B8A6E), Color(0xFF4A725B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: isSelected
              ? Border.all(color: const Color(0xFFD49B9B), width: 3)
              : Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            Positioned(
              bottom: 8,
              left: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  clockWidget,
                  const SizedBox(height: 4),
                  const Text(
                    'Kam, 30 Agu 100%',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD49B9B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_outlined, color: textColor, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Tampilan jam',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildClockPreviewCard(context, 'digital_bold', 'Klasik Digital', setState),
                  _buildClockPreviewCard(context, 'digital_split', 'Vertikal Minimalis', setState),
                  _buildClockPreviewCard(context, 'digital_accent', 'Modern Minimal', setState),
                  _buildClockPreviewCard(context, 'digital_italic', 'Italic Classic', setState),
                  _buildClockPreviewCard(context, 'digital_outline', 'Outline Retro', setState),
                  _buildClockPreviewCard(context, 'digital_accent_split', 'Vertikal Aksen', setState),
                  _buildClockPreviewCard(context, 'digital_ultra_bold', 'Digital Ultra Bold', setState),
                  _buildClockPreviewCard(context, 'digital_serif', 'Serif Classic', setState),
                  _buildClockPreviewCard(context, 'digital_mono', 'Retro Monospace', setState),
                  _buildClockPreviewCard(context, 'digital_spacing', 'Wide Spacing', setState),
                  _buildClockPreviewCard(context, 'digital_shadow', 'Glow Soft Shadow', setState),
                  _buildClockPreviewCard(context, 'digital_neon', 'Neon Rose Glow', setState),
                  _buildClockPreviewCard(context, 'digital_gradient', 'Multicolor Gradient', setState),
                  _buildClockPreviewCard(context, 'digital_two_tone', 'Two-Tone Digital', setState),
                  _buildClockPreviewCard(context, 'digital_hollow_split', 'Vertikal Hollow', setState),
                  _buildClockPreviewCard(context, 'digital_underlined', 'Modern Underline', setState),
                  _buildClockPreviewCard(context, 'digital_mini', 'Super Minimal', setState),
                  _buildClockPreviewCard(context, 'analog_minimal', 'Analog Minimalis', setState),
                  _buildClockPreviewCard(context, 'analog_accent', 'Analog Rose Gold', setState),
                  _buildClockPreviewCard(context, 'analog_glass', 'Analog Cyberpunk', setState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
