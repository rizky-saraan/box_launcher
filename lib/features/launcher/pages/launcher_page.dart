import 'package:box_launcher/core/di/injection.dart';
import 'package:box_launcher/core/theme/theme_bundle.dart';
import 'package:box_launcher/data/datasources/native_channel.dart';
import 'package:box_launcher/data/datasources/local_datasource_hive.dart';
import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/apps/widgets/alphabet_sidebar.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/home/widgets/home_header.dart';
import 'package:box_launcher/domain/entities/app_info.dart';
import 'package:box_launcher/features/search/bloc/search_bloc.dart';
import 'package:box_launcher/features/search/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LauncherPage extends StatefulWidget {
  const LauncherPage({super.key});

  static final ValueNotifier<String> activeThemeBundleNotifier = ValueNotifier<String>('system');

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> with WidgetsBindingObserver {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(0.0);
      
  bool _isSearching = false;
  String? _activeScrubLetter;
  int _targetScrollIndex = 0;
  bool _isFadingToTop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _itemPositionsListener.itemPositions.addListener(_onScroll);
    getIt<LocalDataSourceHive>().getAppSize().then((size) {
      AppListItem.appSizeNotifier.value = size;
    });
    // Load initial active theme bundle from Hive
    getIt<LocalDataSourceHive>().getActiveThemeBundle().then((bundleId) {
      LauncherPage.activeThemeBundleNotifier.value = bundleId;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _itemPositionsListener.itemPositions.removeListener(_onScroll);
    _scrollProgressNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_isSearching) {
        _stopSearch();
      }
      if (!_isAtTop) {
        _jumpToIndex(0);
      }
    }
  }

  void _onScroll() {
    if (!mounted) return;
    if (_activeScrubLetter != null) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisible = positions.reduce((a, b) => a.index < b.index ? a : b);
    
    final appsBloc = context.read<AppsBloc>();
    final appsState = appsBloc.state;
    if (appsState is AppsLoaded) {
      final totalItems = appsState.apps.length + 2;
      final scrolledCount = firstVisible.index - firstVisible.itemLeadingEdge;
      double progress = scrolledCount / totalItems;
      progress = progress.clamp(0.0, 1.0);
      
      _scrollProgressNotifier.value = progress;
      
      // Update system wallpaper scroll offset (y-axis)
      // 1.0 - progress works perfectly as it moves the wallpaper with scrolling down.
      getIt<NativeChannel>().updateWallpaperOffset(1.0 - progress);
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    context.read<SearchBloc>().add(ClearSearch());
  }

  bool get _isAtTop {
    if (!_itemPositionsListener.itemPositions.value.any((p) => p.index == 0)) {
      return false;
    }
    final first = _itemPositionsListener.itemPositions.value
        .firstWhere((p) => p.index == 0);
    return first.itemLeadingEdge >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          if (_isSearching) {
            _stopSearch();
            return;
          }

          if (!_isAtTop) {
            _fadeToTop();
          }
        },
        child: Stack(
          children: [
            // Dynamic premium custom theme bundle wallpaper with 3D parallax scroll effect!
            ValueListenableBuilder<String>(
              valueListenable: LauncherPage.activeThemeBundleNotifier,
              builder: (context, activeBundleId, _) {
                final activeBundle = ThemeBundle.presets.firstWhere(
                  (b) => b.id == activeBundleId,
                  orElse: () => ThemeBundle.presets.first,
                );
                if (activeBundle.wallpaperUrl.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ValueListenableBuilder<double>(
                  valueListenable: _scrollProgressNotifier,
                  builder: (context, progress, _) {
                    // Parallax factor: shift wallpaper slightly vertically based on scroll progress
                    final double verticalShift = -progress * 30.0;
                    return Positioned(
                      top: verticalShift - 20.0,
                      bottom: -verticalShift - 20.0,
                      left: -20.0,
                      right: -20.0,
                      child: Image.network(
                        activeBundle.wallpaperUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white30,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black87,
                            child: const Center(
                              child: Icon(Icons.broken_image_outlined, color: Colors.white30),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            // Dynamic Background overlay for premium readability when scrolled
            ValueListenableBuilder<double>(
              valueListenable: _scrollProgressNotifier,
              builder: (context, progress, child) {
                return Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(progress * 0.4),
                  ),
                );
              },
            ),
            SafeArea(
              child: AnimatedOpacity(
                opacity: _isFadingToTop ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                onEnd: () {
                  if (_isFadingToTop) {
                    _jumpToIndex(0);
                    setState(() {
                      _isFadingToTop = false;
                    });
                  }
                },
                child: Row(
                  children: [
                  Expanded(
                    child: BlocBuilder<AppsBloc, AppsState>(
                      builder: (context, state) {
                        Widget child;
                        if (state is AppsLoading) {
                          child = const Center(
                              key: ValueKey('loading'),
                              child: CircularProgressIndicator(color: Colors.white));
                        } else if (state is AppsLoaded) {
                          if (_isSearching) {
                            child = _buildSearchResults(state.apps);
                          } else {
                            child = ScrollablePositionedList.builder(
                              key: const ValueKey('all_apps'),
                              itemCount: state.apps.length + 2,
                              itemScrollController: _itemScrollController,
                              itemPositionsListener: _itemPositionsListener,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  final isMatch = _activeScrubLetter == null;
                                  return AnimatedOpacity(
                                    opacity: isMatch ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    child: IgnorePointer(
                                      ignoring: !isMatch,
                                      child: const HomeHeader(),
                                    ),
                                  );
                                }
                                
                                if (index == state.apps.length + 1) {
                                  return SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.7,
                                  );
                                }
                                
                                final app = state.apps[index - 1];
                                final isMatch = _activeScrubLetter == null ||
                                    app.label.toUpperCase().startsWith(_activeScrubLetter!);

                                return AnimatedOpacity(
                                  opacity: isMatch ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                  child: IgnorePointer(
                                    ignoring: !isMatch,
                                    child: index == 1
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                              top: MediaQuery.of(context).size.height * 0.25,
                                            ),
                                            child: AppListItem(app: app),
                                          )
                                        : AppListItem(app: app),
                                  ),
                                );
                              },
                            );
                          }
                        } else if (state is AppsError) {
                          child = Center(
                              key: const ValueKey('error'),
                              child: Text(state.message, style: const TextStyle(color: Colors.white)));
                        } else {
                          child = const SizedBox.shrink(key: ValueKey('empty'));
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: child,
                        );
                      },
                    ),
                  ),
                  if (!_isSearching)
                    BlocBuilder<AppsBloc, AppsState>(
                      builder: (context, state) {
                        if (state is AppsLoaded) {
                          return AlphabetSidebar(
                            apps: state.apps,
                            onLetterScrubbed: (index) {
                              // Handled by onLetterSelected
                            },
                            onLetterSelected: (letter, index) {
                              setState(() {
                                _activeScrubLetter = letter;
                                _targetScrollIndex = index + 1;
                              });
                              _scrollToIndex(index + 1);
                            },
                            onScrubEnd: () {
                              setState(() {
                                _activeScrubLetter = null;
                              });
                              _jumpToIndex(_targetScrollIndex);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
      floatingActionButton: !_isSearching 
          ? ValueListenableBuilder<Iterable<ItemPosition>>(
              valueListenable: _itemPositionsListener.itemPositions,
              builder: (context, positions, child) {
                bool isAtTop = false;
                if (positions.any((p) => p.index == 0)) {
                  final first = positions.firstWhere((p) => p.index == 0);
                  isAtTop = first.itemLeadingEdge >= -0.1; // small threshold to hide
                }

                if (isAtTop) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(right: 60.0, bottom: 16.0),
                  child: FloatingActionButton(
                    onPressed: _startSearch,
                    backgroundColor: Colors.white24,
                    elevation: 0,
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                );
              },
            )
          : null,
    );
  }

  void _scrollToIndex(int index, {Duration duration = const Duration(milliseconds: 50)}) {
    if (_itemScrollController.isAttached) {
      double alignment = 0.0;
      if (index > 1) {
        alignment = 0.25; // Align items somewhat in the middle of the screen
      }
      _itemScrollController.scrollTo(
        index: index,
        alignment: alignment,
        duration: duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _jumpToIndex(int index) {
    if (_itemScrollController.isAttached) {
      double alignment = 0.0;
      if (index > 1) {
        alignment = 0.25; // Align items somewhat in the middle of the screen
      }
      _itemScrollController.jumpTo(
        index: index,
        alignment: alignment,
      );
    }
  }

  void _fadeToTop() {
    setState(() {
      _isFadingToTop = true;
    });
  }

  Widget _buildSearchResults(List<AppInfo> allApps) {
    return Column(
      key: const ValueKey('search_results'),
      children: [
        SearchBarWidget(
          onChanged: (query) {
            context.read<SearchBloc>().add(SearchQueryChanged(query, allApps));
          },
          onBack: _stopSearch,
        ),
        Expanded(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, searchState) {
              if (searchState is SearchInitial) {
                return const SizedBox.shrink(); // Hide all apps when search query is empty
              }
              if (searchState is SearchLoaded) {
                final appsToShow = searchState.results;
                if (appsToShow.isEmpty) {
                  return const Center(
                    child: Text(
                      "No apps found",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: appsToShow.length,
                  itemBuilder: (context, index) {
                    return AppListItem(app: appsToShow[index]);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}
