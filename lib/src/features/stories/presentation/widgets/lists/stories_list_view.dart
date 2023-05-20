import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/loading/loading.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/items/items_list_view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StoriesListView extends StatefulWidget {
  const StoriesListView({
    required this.storyType,
    required this.onStoryTapped,
    super.key,
  });

  final StoryType storyType;
  final ValueChanged<Story> onStoryTapped;

  @override
  State<StoriesListView> createState() => _StoriesListViewState();
}

class _StoriesListViewState extends State<StoriesListView> {
  final RefreshController refreshController = RefreshController();

  @override
  void dispose() {
    super.dispose();
    refreshController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyType = widget.storyType;
    final onStoryTapped = widget.onStoryTapped;

    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: refreshWhen,
      builder: (context, s) => s.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (settingsState) {
          return BlocConsumer<StoriesBloc, StoriesState>(
            listenWhen: (previous, current) =>
                previous.statusByType[storyType] != current.statusByType[storyType],
            listener: (ctx, state) {
              if (state.statusByType[storyType] == StoriesStatus.loaded) {
                refreshController..refreshCompleted(resetFooterState: true)..loadComplete();
              }
            },
            buildWhen: (previous, current) =>
                (current.currentPageByType[storyType] == 0 && previous.currentPageByType[storyType] == 0) ||
                (previous.storiesByType[storyType]!.length != current.storiesByType[storyType]!.length) ||
                (previous.readStoriesIds.length != current.readStoriesIds.length),
            builder: (ctx, state) {
              return ItemsListView(
                showWebPreview: settingsState.complexStoryTile,
                showMetadata: settingsState.showMetadata,
                showUrl: settingsState.showUrl,
                refreshController: refreshController,
                markReadStories: settingsState.markReadStories,
                items: state.storiesByType[storyType]!,
                onTap: onStoryTapped,
                onRefresh: () {
                  HapticFeedback.lightImpact();
                  context
                      .read<StoriesBloc>()
                      .add(StoriesEvent.refresh(type: storyType));
                },
                onLoadMore: () {
                  context
                      .read<StoriesBloc>()
                      .add(StoriesEvent.loadMore(type: storyType));
                },
              );
            },
          );
        },
      ),
    );
  }

  bool refreshWhen(SettingsState previous, SettingsState current) {
    return previous.mapOrNull(loaded: (prev) => prev.complexStoryTile) !=
        current.mapOrNull(loaded: (curr) => curr.complexStoryTile) ||
        previous.mapOrNull(loaded: (prev) => prev.showMetadata) !=
        current.mapOrNull(loaded: (curr) => curr.showMetadata);
  }
}
