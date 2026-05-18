import 'package:flutter/material.dart';
import 'package:box_launcher/core/theme/font_manager.dart';

class BoxLauncherFontSettingsPage extends StatefulWidget {
  final String selectedLanguage;

  const BoxLauncherFontSettingsPage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<BoxLauncherFontSettingsPage> createState() => _BoxLauncherFontSettingsPageState();
}

class _BoxLauncherFontSettingsPageState extends State<BoxLauncherFontSettingsPage> {
  final TextEditingController _specimenController = TextEditingController(
    text: "The quick brown fox jumps over the lazy dog.",
  );

  @override
  void dispose() {
    _specimenController.dispose();
    super.dispose();
  }

  Future<void> _pickAndInstallFont() async {
    final isIndonesian = widget.selectedLanguage == 'id';
    
    // Open system file picker
    final result = await FontManager.pickAndInstallCustomFont();

    if (mounted) {
      if (result == 'duplicate') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndonesian ? 'Font ini sudah pernah terpasang!' : 'This font is already installed!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.amber.shade900,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result == 'error') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndonesian ? 'Gagal mengunggah file font!' : 'Failed to upload font file!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (result != null) {
        setState(() {}); // Rebuild list
        final friendlyName = result.replaceFirst('Custom_', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndonesian ? 'Font "$friendlyName" berhasil dipasang!' : 'Font "$friendlyName" installed successfully!',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _deleteCustomFont(String familyName) {
    final isIndonesian = widget.selectedLanguage == 'id';
    final friendlyName = familyName.replaceFirst('Custom_', '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        title: Text(
          isIndonesian ? 'Hapus Font?' : 'Delete Font?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          isIndonesian
              ? 'Apakah Anda yakin ingin menghapus font custom "$friendlyName"?'
              : 'Are you sure you want to delete the custom font "$friendlyName"?',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isIndonesian ? 'Batal' : 'Cancel',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FontManager.deleteCustomFont(familyName);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isIndonesian ? 'Font berhasil dihapus!' : 'Font deleted successfully!',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red.shade800,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: Text(
              isIndonesian ? 'Hapus' : 'Delete',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.white54 : Colors.black54;
    final isIndonesian = widget.selectedLanguage == 'id';

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
          isIndonesian ? 'Jenis Font' : 'Font Styles',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: FontManager.activeFontNotifier,
        builder: (context, activeFont, child) {
          return SafeArea(
            child: Column(
              children: [
                // 1. Live Interactive specimen card
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isDark ? Colors.white10 : Colors.black12, width: 0.8),
                    ),
                    color: cardColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isIndonesian ? 'PREVIEW / UJI FONT' : 'LIVE TYPOGRAPHY SPECIMEN',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : Colors.black38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _specimenController,
                            onChanged: (text) => setState(() {}),
                            style: FontManager.getTextStyle(
                              TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.normal),
                            ),
                            maxLines: 2,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isIndonesian ? 'Ketik di sini...' : 'Type specimen text here...',
                              hintStyle: TextStyle(color: subColor, fontSize: 16),
                            ),
                          ),
                          const Divider(height: 16, color: Colors.white10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${isIndonesian ? 'Aktif' : 'Active'}: ${activeFont.replaceFirst('Custom_', '')}',
                                style: const TextStyle(
                                  color: Color(0xFFD49B9B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.text_fields, color: Colors.grey, size: 18),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 2. Main Font List scroll
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // USER CUSTOM FONTS CATALOG
                      ValueListenableBuilder<Map<String, String>>(
                        valueListenable: FontManager.customFontsNotifier,
                        builder: (context, customFontsMap, child) {
                          if (customFontsMap.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                                child: Text(
                                  isIndonesian ? 'Font Kustom Anda (.ttf/.otf)' : 'Your Custom Fonts (.ttf/.otf)',
                                  style: TextStyle(
                                    color: subColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: customFontsMap.entries.map((entry) {
                                    final fontId = entry.key;
                                    final friendlyName = fontId.replaceFirst('Custom_', '');
                                    final isSelected = activeFont == fontId;

                                    return Column(
                                      children: [
                                        ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                                          leading: Icon(
                                            Icons.font_download_outlined,
                                            color: isSelected ? const Color(0xFFD49B9B) : subColor,
                                          ),
                                          title: Text(
                                            friendlyName,
                                            style: FontManager.getTextStyle(
                                              TextStyle(
                                                color: textColor,
                                                fontSize: 16,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              ),
                                              family: fontId,
                                            ),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (isSelected)
                                                const Icon(Icons.check_circle, color: Color(0xFFD49B9B), size: 20),
                                              const SizedBox(width: 12),
                                              IconButton(
                                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                                onPressed: () => _deleteCustomFont(fontId),
                                              ),
                                            ],
                                          ),
                                          onTap: () => FontManager.setActiveFont(fontId),
                                        ),
                                        if (entry.key != customFontsMap.keys.last)
                                          const Divider(height: 1, color: Colors.white10),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),

                      // PRE-PACKAGED PREMIUM BUILT-IN FONTS
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                        child: Text(
                          isIndonesian ? 'Pilihan Font Premium' : 'Premium Fonts Catalog',
                          style: TextStyle(
                            color: subColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: FontManager.builtinFonts.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white10),
                          itemBuilder: (context, index) {
                            final fontName = FontManager.builtinFonts[index];
                            final isSelected = activeFont == fontName;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                              leading: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFFD49B9B) : subColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              title: Text(
                                fontName,
                                style: FontManager.getTextStyle(
                                  TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  family: fontName,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Color(0xFFD49B9B), size: 20)
                                  : null,
                              onTap: () => FontManager.setActiveFont(fontName),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
                
                // 3. Upload Custom Font action bar
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: isDark ? const Color(0xFF161616) : Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _pickAndInstallFont,
                      icon: const Icon(Icons.add, color: Colors.black87),
                      label: Text(
                        isIndonesian ? 'Tambah Font Custom (.ttf / .otf)' : 'Add Custom Font (.ttf / .otf)',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD49B9B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
