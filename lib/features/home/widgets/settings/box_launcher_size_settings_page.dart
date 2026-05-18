import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:flutter/material.dart';

class BoxLauncherSizeSettingsPage extends StatefulWidget {
  final String selectedLanguage;

  const BoxLauncherSizeSettingsPage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<BoxLauncherSizeSettingsPage> createState() => _BoxLauncherSizeSettingsPageState();
}

class _BoxLauncherSizeSettingsPageState extends State<BoxLauncherSizeSettingsPage> {
  double _sliderValue = 5.0; // Level 1 to 9
  late String _languageCode;

  @override
  void initState() {
    super.initState();
    _languageCode = widget.selectedLanguage;
    _loadCurrentSize();
  }

  Future<void> _loadCurrentSize() async {
    final size = await getIt<LocalDataSourceHive>().getAppSize();
    setState(() {
      if (size == 'small') {
        _sliderValue = 3.0;
      } else if (size == 'large') {
        _sliderValue = 7.0;
      } else if (size == 'medium') {
        _sliderValue = 5.0;
      } else {
        _sliderValue = double.tryParse(size) ?? 5.0;
      }
    });
  }

  String _getSizeString(double value) {
    return value.round().toString();
  }

  String _getSizeLabel(double value, bool isIndonesian) {
    final val = value.round();
    switch (val) {
      case 1:
        return isIndonesian ? 'Sangat Kecil (Level 1)' : 'Extremely Small (Level 1)';
      case 2:
        return isIndonesian ? 'Cukup Kecil (Level 2)' : 'Very Small (Level 2)';
      case 3:
        return isIndonesian ? 'Kecil (Level 3)' : 'Small (Level 3)';
      case 4:
        return isIndonesian ? 'Agak Kecil (Level 4)' : 'Slightly Small (Level 4)';
      case 5:
        return isIndonesian ? 'Sedang (Level 5)' : 'Medium (Level 5)';
      case 6:
        return isIndonesian ? 'Agak Besar (Level 6)' : 'Slightly Large (Level 6)';
      case 7:
        return isIndonesian ? 'Besar (Level 7)' : 'Large (Level 7)';
      case 8:
        return isIndonesian ? 'Cukup Besar (Level 8)' : 'Very Large (Level 8)';
      case 9:
        return isIndonesian ? 'Sangat Besar (Level 9)' : 'Extremely Large (Level 9)';
      default:
        return isIndonesian ? 'Sedang (Level 5)' : 'Medium (Level 5)';
    }
  }

  Future<void> _onSizeChanged(double value) async {
    setState(() {
      _sliderValue = value;
    });
    final sizeString = _getSizeString(value);
    // Persist size in Hive
    await getIt<LocalDataSourceHive>().saveAppSize(sizeString);
    // Instantly notify and update all AppListItems in real-time!
    AppListItem.appSizeNotifier.value = sizeString;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;

    final isIndonesian = _languageCode == 'id';

    // Calculate dimensions for the interactive live preview card
    final int level = _sliderValue.round();
    double previewIconSize = 24.0 + (level - 1) * 2.5;
    double previewFontSize = 12.0 + (level - 1) * 1.0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isIndonesian ? 'Ukuran Ikon & Teks' : 'Icon & Text Size',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          children: [
            // Live Preview Card
            Text(
              isIndonesian ? 'Pratinjau Langsung' : 'Live Preview',
              style: TextStyle(
                color: subColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Mock App 1: Camera
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: previewIconSize,
                        height: previewIconSize,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.camera_alt_outlined, color: Colors.blueAccent, size: previewIconSize * 0.55),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: previewFontSize,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          child: const Text('Kamera'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mock App 2: Spotify
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: previewIconSize,
                        height: previewIconSize,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.music_note_outlined, color: Colors.greenAccent, size: previewIconSize * 0.55),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: previewFontSize,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          child: const Text('Musik'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Controls Card
            Text(
              isIndonesian ? 'Sesuaikan Ukuran' : 'Adjust Size',
              style: TextStyle(
                color: subColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _getSizeLabel(_sliderValue, isIndonesian),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFD49B9B),
                      inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                      thumbColor: const Color(0xFFD49B9B),
                      overlayColor: const Color(0xFFD49B9B).withOpacity(0.2),
                      valueIndicatorColor: const Color(0xFFD49B9B),
                      trackHeight: 6,
                    ),
                    child: Slider(
                      value: _sliderValue,
                      min: 1.0,
                      max: 9.0,
                      divisions: 8,
                      onChanged: _onSizeChanged,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isIndonesian ? 'Sangat Kecil' : 'Extremely Small',
                          style: TextStyle(
                            color: _sliderValue == 1.0 ? const Color(0xFFD49B9B) : subColor,
                            fontSize: 11,
                            fontWeight: _sliderValue == 1.0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          isIndonesian ? 'Sedang (Lvl 5)' : 'Medium (Lvl 5)',
                          style: TextStyle(
                            color: _sliderValue == 5.0 ? const Color(0xFFD49B9B) : subColor,
                            fontSize: 11,
                            fontWeight: _sliderValue == 5.0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          isIndonesian ? 'Sangat Besar' : 'Extremely Large',
                          style: TextStyle(
                            color: _sliderValue == 9.0 ? const Color(0xFFD49B9B) : subColor,
                            fontSize: 11,
                            fontWeight: _sliderValue == 9.0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
