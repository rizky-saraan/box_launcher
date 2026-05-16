import 'package:box_launcher/features/apps/bloc/apps_bloc.dart';
import 'package:box_launcher/features/apps/widgets/alphabet_sidebar.dart';
import 'package:box_launcher/features/apps/widgets/app_list_item.dart';
import 'package:box_launcher/features/home/widgets/home_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class LauncherPage extends StatefulWidget {
  const LauncherPage({super.key});

  @override
  State<LauncherPage> createState() => _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener = ItemPositionsListener.create();

  void _scrollToIndex(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.jumpTo(index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<AppsBloc, AppsState>(
                    builder: (context, state) {
                      if (state is AppsLoading) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      } else if (state is AppsLoaded) {
                        return ScrollablePositionedList.builder(
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
                      } else if (state is AppsError) {
                        return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
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
    );
  }
}
