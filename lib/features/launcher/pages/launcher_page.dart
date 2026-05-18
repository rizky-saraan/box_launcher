import 'package:box_launcher/core/di/injection.dart';
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

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> with WidgetsBindingObserver {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(0.0);
      
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _itemPositionsListener.itemPositions.addListener(_onScroll);
    getIt<LocalDataSourceHive>().getAppSize().then((size) {
      AppListItem.appSizeNotifier.value = size;
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
        _scrollToTop();
      }
    }
  }

  void _onScroll() {
    if (!mounted) return;
    final positions = _itemPositionsListener.itemPositions.value;
    if (positions.isEmpty) return;

    final firstVisible = positions.reduce((a, b) => a.index < b.index ? a : b);
    
    final appsBloc = context.read<AppsBloc>();
    final appsState = appsBloc.state;
    if (appsState is AppsLoaded) {
      final totalItems = appsState.apps.length + 1;
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
            _scrollToTop();
          }
        },
        child: Stack(
          children: [
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
                              itemCount: state.apps.length + 1,
                              itemScrollController: _itemScrollController,
                              itemPositionsListener: _itemPositionsListener,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return const HomeHeader();
                                }
                                final app = state.apps[index - 1];
                                return AppListItem(app: app);
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
                              _scrollToIndex(index + 1);
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                ],
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

  void _scrollToIndex(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToTop() {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
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
              List<AppInfo> appsToShow = allApps;
              if (searchState is SearchLoaded) {
                appsToShow = searchState.results;
                if (appsToShow.isEmpty) {
                  return const Center(
                      child: Text("No apps found",
                          style: TextStyle(color: Colors.white54)));
                }
              }
              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: appsToShow.length,
                itemBuilder: (context, index) {
                  return AppListItem(app: appsToShow[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
