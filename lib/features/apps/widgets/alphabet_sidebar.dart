import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:flutter/material.dart';

class AlphabetSidebar extends StatefulWidget {
  final List<AppInfo> apps;
  final ValueChanged<int> onLetterScrubbed;

  const AlphabetSidebar({
    super.key,
    required this.apps,
    required this.onLetterScrubbed,
  });

  @override
  State<AlphabetSidebar> createState() => _AlphabetSidebarState();
}

class _AlphabetSidebarState extends State<AlphabetSidebar> {
  final List<String> _alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split("");
  String? _currentLetter;
  double? _touchY;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            _handleScrub(details.localPosition, constraints.maxHeight);
          },
          onVerticalDragDown: (details) {
            _handleScrub(details.localPosition, constraints.maxHeight);
          },
          onVerticalDragEnd: (_) {
            setState(() {
              _currentLetter = null;
              _touchY = null;
            });
          },
          onVerticalDragCancel: () {
            setState(() {
              _currentLetter = null;
              _touchY = null;
            });
          },
          child: Container(
            width: 80, // Increased width to accommodate the curve
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_alphabet.length, (index) {
                final letter = _alphabet[index];

                double offsetX = 0;
                double scale = 1.0;

                if (_touchY != null) {
                  final itemHeight = constraints.maxHeight / _alphabet.length;
                  final itemCenterY = (index + 0.5) * itemHeight;
                  final distance = (_touchY! - itemCenterY).abs();

                  // S-Curve Effect: Gaussian-like distribution for offset
                  if (distance < 150) {
                    final factor = 1.0 - (distance / 150);
                    // Move letters to the left (negative X) as you get closer to touch
                    offsetX = -30 * (factor * factor);
                    scale = 1.0 + (0.6 * factor);
                  }
                }

                final isSelected = letter == _currentLetter;

                return Transform.translate(
                  offset: Offset(offsetX, 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  void _handleScrub(Offset localPosition, double height) {
    if (widget.apps.isEmpty) return;

    setState(() {
      _touchY = localPosition.dy;
    });

    final itemHeight = height / _alphabet.length;
    int index = (localPosition.dy / itemHeight).floor();
    index = index.clamp(0, _alphabet.length - 1);

    final letter = _alphabet[index];
    if (_currentLetter != letter) {
      setState(() {
        _currentLetter = letter;
      });

      final appIndex = widget.apps
          .indexWhere((app) => app.label.toUpperCase().startsWith(letter));

      if (appIndex != -1) {
        widget.onLetterScrubbed(appIndex);
      }
    }
  }
}
