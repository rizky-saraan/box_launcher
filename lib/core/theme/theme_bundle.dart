import 'package:flutter/material.dart';

class ThemeBundle {
  final String id;
  final String nameEn;
  final String nameId;
  final String descriptionEn;
  final String descriptionId;
  final String iconPackPackage;
  final String wallpaperUrl;
  final Color accentColor;

  const ThemeBundle({
    required this.id,
    required this.nameEn,
    required this.nameId,
    required this.descriptionEn,
    required this.descriptionId,
    required this.iconPackPackage,
    required this.wallpaperUrl,
    required this.accentColor,
  });

  String getName(String langCode) => langCode == 'id' ? nameId : nameEn;
  String getDescription(String langCode) => langCode == 'id' ? descriptionId : descriptionEn;

  static final List<ThemeBundle> presets = [
    const ThemeBundle(
      id: 'system',
      nameEn: 'System Default',
      nameId: 'Default Sistem',
      descriptionEn: 'Uses your system wallpaper with minimal launcher aesthetic.',
      descriptionId: 'Menggunakan wallpaper sistem Anda dengan estetika minimal.',
      iconPackPackage: '',
      wallpaperUrl: '',
      accentColor: Colors.white,
    ),
    const ThemeBundle(
      id: 'alpine_clouds',
      nameEn: 'Alpine Clouds',
      nameId: 'Awan Alpen',
      descriptionEn: 'Pure minimal mountain peaks with Flight Lite icon pack.',
      descriptionId: 'Puncak gunung minimalis bersih dengan Flight Lite icon pack.',
      iconPackPackage: 'com.natewren.flightlite',
      wallpaperUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1080',
      accentColor: Color(0xFFC3C7DB),
    ),
    const ThemeBundle(
      id: 'nordic_spruce',
      nameEn: 'Nordic Spruce',
      nameId: 'Cemara Nordik',
      descriptionEn: 'Misty atmospheric forests with Lines Free icon pack.',
      descriptionId: 'Hutan pinus berkabut hijau tenang dengan Lines Free icon pack.',
      iconPackPackage: 'com.natewren.linesfree',
      wallpaperUrl: 'https://images.unsplash.com/photo-1511497584788-876760111969?q=80&w=1080',
      accentColor: Color(0xFF8BBCA9),
    ),
    const ThemeBundle(
      id: 'neon_cyberpunk',
      nameEn: 'Neon Cyberpunk',
      nameId: 'Cyberpunk Neon',
      descriptionEn: 'Dark electric retro city vibes with Neon icon pack.',
      descriptionId: 'Gaya kota retro elektrik gelap dengan Neon icon pack.',
      iconPackPackage: 'com.vertumus.neon',
      wallpaperUrl: 'https://images.unsplash.com/photo-1515621061946-eff1c2a352bd?q=80&w=1080',
      accentColor: Color(0xFFF72585),
    ),
    const ThemeBundle(
      id: 'chill_sunset',
      nameEn: 'Chill Sunset',
      nameId: 'Senja Tenang',
      descriptionEn: 'Cozy room scenery with gorgeous Rad Pack retro sunset styled icons.',
      descriptionId: 'Pemandangan kamar santai dengan ikon retro senja Rad Pack yang sangat indah.',
      iconPackPackage: 'com.natewren.radpackfree',
      wallpaperUrl: 'https://images.unsplash.com/photo-1501183007986-d0d080b147f9?q=80&w=1080',
      accentColor: Color(0xFFE07A5F),
    ),
    const ThemeBundle(
      id: 'golden_sahara',
      nameEn: 'Golden Sahara',
      nameId: 'Gurun Sahara',
      descriptionEn: 'Warm sand desert dunes with premium gold outline Mono-themed icons.',
      descriptionId: 'Bukit pasir gurun yang hangat dengan ikon outline emas premium bertema Mono.',
      iconPackPackage: 'com.sikebo.amoled.mono.icons',
      wallpaperUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?q=80&w=1080',
      accentColor: Color(0xFFE0A96D),
    ),
    const ThemeBundle(
      id: 'sakura_blossom',
      nameEn: 'Sakura Blossom',
      nameId: 'Bunga Sakura',
      descriptionEn: 'Dreamy Japanese cherry blossoms with soft white Whicons icons.',
      descriptionId: 'Bunga sakura Jepang yang anggun dengan ikon putih bersih Whicons yang estetik.',
      iconPackPackage: 'com.whicons.pack',
      wallpaperUrl: 'https://images.unsplash.com/photo-1522441815192-d9f04eb0615c?q=80&w=1080',
      accentColor: Color(0xFFFFB7C5),
    ),
    const ThemeBundle(
      id: 'deep_ocean',
      nameEn: 'Deep Ocean',
      nameId: 'Samudra Dalam',
      descriptionEn: 'Abyssal water depths with Linebit Light pastel neon fluid outline icons.',
      descriptionId: 'Kedalaman laut biru misterius dengan outline pastel neon bulat Linebit Light.',
      iconPackPackage: 'com.sagon.linebit.light',
      wallpaperUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=1080',
      accentColor: Color(0xFF00B4D8),
    ),
    const ThemeBundle(
      id: 'volcanic_ash',
      nameEn: 'Volcanic Ash',
      nameId: 'Abu Vulkanik',
      descriptionEn: 'Molten dark basalt rock scenery with fiery neon Linebit outline icons.',
      descriptionId: 'Batuan basal lava hitam legam dengan ikon outline neon membara Linebit.',
      iconPackPackage: 'com.sagon.linebit',
      wallpaperUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=1080',
      accentColor: Color(0xFFD9381E),
    ),
    const ThemeBundle(
      id: 'lavender_fields',
      nameEn: 'Lavender Fields',
      nameId: 'Kebun Lavender',
      descriptionEn: 'French lavender fields under gold sun with dreamy Pastel-themed icons.',
      descriptionId: 'Kebun lavender Prancis di bawah matahari dengan ikon bertema Pastel yang indah.',
      iconPackPackage: 'com.indie.pastel',
      wallpaperUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?q=80&w=1080',
      accentColor: Color(0xFFB39DDB),
    ),
    const ThemeBundle(
      id: 'earthy_terracotta',
      nameEn: 'Earthy Terracotta',
      nameId: 'Tanah Liat',
      descriptionEn: 'Rustic pottery warm clay aesthetics with organic earth-toned Rex icons.',
      descriptionId: 'Estetika tanah liat pedesaan hangat dengan ikon tanah alami Rex yang nyaman.',
      iconPackPackage: 'com.lknninex.rex',
      wallpaperUrl: 'https://images.unsplash.com/photo-1595853035070-59a39fe84de3?q=80&w=1080',
      accentColor: Color(0xFFC97A64),
    ),
    const ThemeBundle(
      id: 'monochrome_slate',
      nameEn: 'Brutalist Slate',
      nameId: 'Semen Brutalis',
      descriptionEn: 'Pure jet-black high-end architecture with pitch-black Zwart icons.',
      descriptionId: 'Arsitektur semen brutalist hitam legam dengan ikon hitam legam Zwart premium.',
      iconPackPackage: 'com.jnd.blacklite',
      wallpaperUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=1080',
      accentColor: Colors.white,
    ),
    const ThemeBundle(
      id: 'retro_arcade',
      nameEn: 'Retro Arcade',
      nameId: 'Arkade Jadul',
      descriptionEn: '80s arcade vaporwave neon grids with 8-bit Pixbit pixel icons.',
      descriptionId: 'Gaya grid neon retro 80-an vaporwave dengan ikon pixel 8-bit Pixbit.',
      iconPackPackage: 'com.moreapps.pixel',
      wallpaperUrl: 'https://images.unsplash.com/photo-1563089145-599997674d42?q=80&w=1080',
      accentColor: Color(0xFF00FFCC),
    ),
    const ThemeBundle(
      id: 'botanical_garden',
      nameEn: 'Botanical Garden',
      nameId: 'Taman Botani',
      descriptionEn: 'Bright tropical leafy monsteras with fresh green Simplicon organic icons.',
      descriptionId: 'Daun monstera tropis yang rimbun dengan ikon organik segar Simplicon.',
      iconPackPackage: 'com.sikebo.simplicon.ap',
      wallpaperUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=1080',
      accentColor: Color(0xFF2EC4B6),
    ),
    const ThemeBundle(
      id: 'midnight_aurora',
      nameEn: 'Midnight Aurora',
      nameId: 'Aurora Malam',
      descriptionEn: 'Arctic northern polar sky lights with cyber green/purple Linebit SE outlines.',
      descriptionId: 'Cahaya aurora kutub utara malam hari dengan outline cyber hijau/ungu Linebit SE.',
      iconPackPackage: 'com.sagon.linebit.se',
      wallpaperUrl: 'https://images.unsplash.com/photo-1483347756197-71ef80e95f73?q=80&w=1080',
      accentColor: Color(0xFF00F5D4),
    ),
  ];
}
