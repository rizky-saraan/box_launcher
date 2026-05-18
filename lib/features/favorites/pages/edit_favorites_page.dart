import 'dart:typed_data';
import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/domain/usecases/app_usecases.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/favorites/bloc/favorites_bloc.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditFavoritesPage extends StatefulWidget {
  const EditFavoritesPage({super.key});

  @override
  State<EditFavoritesPage> createState() => _EditFavoritesPageState();
}

class _EditFavoritesPageState extends State<EditFavoritesPage> {
  List<AppInfo> selectedApps = [];
  List<AppInfo> suggestionApps = [];
  bool _initialized = false;
  String _selectedLanguage = 'id';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final lang = await getIt<LocalDataSourceHive>().getLanguageCode();
    if (mounted) {
      setState(() {
        _selectedLanguage = lang;
      });
    }
  }

  void _initializeLists(List<AppInfo> allApps, List<AppInfo> favorites) {
    if (_initialized) return;
    selectedApps = List.from(favorites);
    suggestionApps = allApps.where((app) =>
      !selectedApps.any((fav) => fav.packageName == app.packageName)
    ).toList();
    // Sort suggestions alphabetically
    suggestionApps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    _initialized = true;
  }

  void _saveAndClose() {
    context.read<FavoritesBloc>().add(SetFavoritesEvent(selectedApps));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4), // Let the wallpaper show through
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xDD0A0F24),
              const Color(0xEE050714),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<AppsBloc, AppsState>(
            builder: (context, appsState) {
              return BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, favoritesState) {
                  if (appsState is AppsLoading || favoritesState is FavoritesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8294E3)),
                      ),
                    );
                  }

                  if (appsState is AppsLoaded && favoritesState is FavoritesLoaded) {
                    _initializeLists(appsState.apps, favoritesState.favorites);

                    return CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Title Header
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedLanguage == 'id' ? 'Aplikasi Favorit' : 'Your favorites',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Subtitle 1
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8294E3).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.star_outline,
                                        color: Color(0xFF8294E3),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedLanguage == 'id'
                                                ? 'Favorit muncul di layar beranda untuk akses cepat'
                                                : 'Favorites appear on your home screen for quick access',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Subtitle 2
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF8294E3).withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle_outline,
                                        color: Color(0xFF8294E3),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _selectedLanguage == 'id'
                                            ? 'Kebanyakan orang memilih 4 hingga 8 aplikasi favorit'
                                            : 'Most people choose their 4 to 8 most-used apps',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Section selected ("Terpilih")
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: Text(
                              _selectedLanguage == 'id' ? 'Terpilih' : 'Selected',
                              style: const TextStyle(
                                color: Color(0xFF8294E3),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),

                        // Reorderable list of selected apps
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (selectedApps.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  child: Text(
                                    'Belum ada aplikasi terpilih',
                                    style: TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
                                  ),
                                );
                              }
                              return SizedBox(
                                height: selectedApps.length * 56.0,
                                child: ReorderableListView.builder(
                                  buildDefaultDragHandles: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: selectedApps.length,
                                  onReorder: (oldIndex, newIndex) {
                                    setState(() {
                                      if (oldIndex < newIndex) {
                                        newIndex -= 1;
                                      }
                                      final item = selectedApps.removeAt(oldIndex);
                                      selectedApps.insert(newIndex, item);
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final app = selectedApps[index];
                                    return EditAppListItem(
                                      key: ValueKey(app.packageName),
                                      app: app,
                                      isSelected: true,
                                      onTap: () {
                                        setState(() {
                                          selectedApps.removeAt(index);
                                          suggestionApps.add(app);
                                          suggestionApps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
                                        });
                                      },
                                      trailing: ReorderableDragStartListener(
                                        index: index,
                                        child: const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Icon(
                                            Icons.drag_handle,
                                            color: Colors.white38,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: 1,
                          ),
                        ),

                        // Sort option
                        if (selectedApps.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedApps.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8294E3).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.swap_vert,
                                          color: Color(0xFF8294E3),
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _selectedLanguage == 'id'
                                            ? 'Urutkan sesuai alfabet'
                                            : 'Sort apps alphabetically',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Section suggestions ("Saran")
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                            child: Text(
                              _selectedLanguage == 'id' ? 'Saran' : 'Suggestions',
                              style: const TextStyle(
                                color: Color(0xFF8294E3),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),

                        // List of suggestions
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final app = suggestionApps[index];
                              return EditAppListItem(
                                key: ValueKey('sug_${app.packageName}'),
                                app: app,
                                isSelected: false,
                                onTap: () {
                                  setState(() {
                                    suggestionApps.removeAt(index);
                                    selectedApps.add(app);
                                  });
                                },
                              );
                            },
                            childCount: suggestionApps.length,
                          ),
                        ),

                        // Bottom Spacer for FAB
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 80),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAndClose,
        backgroundColor: const Color(0xFF8294E3),
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        label: Text(
          _selectedLanguage == 'id' ? 'Selesai' : 'Done',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class EditAppListItem extends StatefulWidget {
  final AppInfo app;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const EditAppListItem({
    super.key,
    required this.app,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  State<EditAppListItem> createState() => _EditAppListItemState();
}

class _EditAppListItemState extends State<EditAppListItem> {
  static final Map<String, Uint8List> _iconCache = {};

  @override
  void initState() {
    super.initState();
    if (widget.app.icon != null) {
      _iconCache[widget.app.packageName] = widget.app.icon!;
    } else if (!_iconCache.containsKey(widget.app.packageName)) {
      _loadIcon();
    }
  }

  Future<Uint8List?> _loadIcon() async {
    try {
      final appWithIcon = await getIt<GetAppIconUseCase>().call(widget.app);
      if (appWithIcon.icon != null) {
        _iconCache[widget.app.packageName] = appWithIcon.icon!;
        if (mounted) setState(() {});
        return appWithIcon.icon;
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cachedIcon = _iconCache[widget.app.packageName];
    final accentColor = const Color(0xFF8294E3);

    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onTap(),
                activeColor: accentColor,
                checkColor: Colors.white,
                side: const BorderSide(color: Colors.white54, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // App Icon
            SizedBox(
              width: 32,
              height: 32,
              child: cachedIcon != null
                  ? Image.memory(
                      cachedIcon,
                      width: 32,
                      height: 32,
                      gaplessPlayback: true,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        color: Colors.white12,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // App Label
            Expanded(
              child: Text(
                widget.app.label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
      ),
    );
  }
}
