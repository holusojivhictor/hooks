import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/domain/models/db/models.dart';
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
      builder: (context, settingsState) {
        return BlocConsumer<StoriesBloc, StoriesState>(
          listenWhen: (previous, current) =>
              previous.statusByType[storyType] != current.statusByType[storyType],
          listener: (ctx, state) {
            if (state.statusByType[storyType] == StoriesStatus.loaded) {
              refreshController
                ..refreshCompleted(resetFooterState: true)
                ..loadComplete();
            }
          },
          buildWhen: (previous, current) =>
              (current.currentPageByType[storyType] == 0 &&
                  previous.currentPageByType[storyType] == 0) ||
              (previous.storiesByType[storyType]!.length !=
                  current.storiesByType[storyType]!.length) ||
              (previous.readStoriesIds.length != current.readStoriesIds.length),
          builder: (ctx, state) {
            return Placeholder();
          },
        );
      },
    );
  }
}
