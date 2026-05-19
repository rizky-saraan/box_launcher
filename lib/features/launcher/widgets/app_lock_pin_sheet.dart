import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/features/home/widgets/settings/box_launcher_appearance_settings_page.dart';

Future<bool> showAppLockPinSheet(BuildContext context, String correctPin) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'App Lock PIN',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, anim1, anim2) {
      return AppLockPinSheet(correctPin: correctPin);
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
        opacity: anim1,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class AppLockPinSheet extends StatefulWidget {
  final String correctPin;

  const AppLockPinSheet({
    super.key,
    required this.correctPin,
  });

  @override
  State<AppLockPinSheet> createState() => _AppLockPinSheetState();
}

class _AppLockPinSheetState extends State<AppLockPinSheet> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String _enteredPin = '';
  bool _isError = false;
  String _language = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reverse();
        }
      });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadLanguage() async {
    final lang = await getIt<LocalDataSourceHive>().getLanguageCode();
    if (mounted) {
      setState(() {
        _language = lang;
      });
    }
  }

  void _triggerHapticTick() {
    if (BoxLauncherAppearanceSettingsPage.enableHapticsNotifier.value) {
      HapticFeedback.lightImpact();
    }
  }

  void _triggerErrorHaptic() {
    if (BoxLauncherAppearanceSettingsPage.enableHapticsNotifier.value) {
      HapticFeedback.heavyImpact();
    }
  }

  void _onKeyPress(String digit) {
    if (_enteredPin.length >= 4) return;
    _triggerHapticTick();
    setState(() {
      _isError = false;
      _enteredPin += digit;
    });

    if (_enteredPin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_enteredPin.isEmpty) return;
    _triggerHapticTick();
    setState(() {
      _isError = false;
      _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
    });
  }

  void _verifyPin() {
    if (_enteredPin == widget.correctPin) {
      _triggerHapticTick();
      Navigator.pop(context, true);
    } else {
      _triggerErrorHaptic();
      setState(() {
        _isError = true;
      });
      _shakeController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _enteredPin.length == 4) {
          setState(() {
            _enteredPin = '';
            _isError = false;
          });
        }
      });
    }
  }

  Widget _buildDot(int index) {
    final isActive = _enteredPin.length > index;
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isError
            ? Colors.redAccent
            : (isActive ? const Color(0xFFD49B9B) : Colors.white24),
        border: Border.all(
          color: _isError
              ? Colors.redAccent
              : (isActive ? const Color(0xFFD49B9B) : Colors.white30),
          width: 1.5,
        ),
        boxShadow: isActive && !_isError
            ? [
                BoxShadow(
                  color: const Color(0xFFD49B9B).withOpacity(0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
    );
  }

  Widget _buildNumberKey(String number) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(number),
        borderRadius: BorderRadius.circular(40),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white10),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIndonesian = _language == 'id';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Premium Glassmorphism blur backdrop
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: Colors.black.withOpacity(0.65),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: Color(0xFFD49B9B),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  isIndonesian ? 'Masukkan PIN Pengunci' : 'Enter Security PIN',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isError
                      ? (isIndonesian ? 'PIN Salah! Coba lagi' : 'Incorrect PIN! Try again')
                      : (isIndonesian ? 'Masukkan 4 digit PIN Anda' : 'Please enter your 4-digit PIN'),
                  style: TextStyle(
                    color: _isError ? Colors.redAccent : Colors.white54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Shake Animated PIN Indicator dots
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    final offset = math.sin(_shakeAnimation.value * math.pi) * 8;
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => _buildDot(index)),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // 1-9 Grid numpad
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['1', '2', '3'].map((n) => _buildNumberKey(n)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['4', '5', '6'].map((n) => _buildNumberKey(n)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['7', '8', '9'].map((n) => _buildNumberKey(n)).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Cancel button
                        IconButton(
                          onPressed: () {
                            _triggerHapticTick();
                            Navigator.pop(context, false);
                          },
                          icon: const Icon(Icons.close, color: Colors.white54, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 72, minHeight: 72),
                        ),
                        _buildNumberKey('0'),
                        // Backspace button
                        IconButton(
                          onPressed: _onBackspace,
                          icon: const Icon(Icons.backspace_outlined, color: Colors.white54, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 72, minHeight: 72),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
