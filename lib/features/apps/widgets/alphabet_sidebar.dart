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
  
  void _handleScrub(Offset localPosition, double height) {
    if (widget.apps.isEmpty) return;
    
    final itemHeight = height / _alphabet.length;
    int index = (localPosition.dy / itemHeight).floor();
    index = index.clamp(0, _alphabet.length - 1);
    
    final letter = _alphabet[index];
    if (_currentLetter != letter) {
      setState(() {
        _currentLetter = letter;
      });
      
      final appIndex = widget.apps.indexWhere(
        (app) => app.label.toUpperCase().startsWith(letter)
      );
      
      if (appIndex != -1) {
        widget.onLetterScrubbed(appIndex);
      }
    }
  }

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
            });
          },
          child: Container(
            width: 40,
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _alphabet.map((letter) {
                final isSelected = letter == _currentLetter;
                return Text(
                  letter,
                  style: TextStyle(
                    fontSize: isSelected ? 16 : 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.white54,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
