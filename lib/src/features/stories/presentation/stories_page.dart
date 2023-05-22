import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/presentation/loading/loading.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/lists/stories_list_view.dart';
import 'package:hooks/src/features/stories/presentation/widgets/tab/custom_tab_bar.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/utils.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with SingleTickerProviderStateMixin, RouteAware {
  late final TabController tabController;

  static final int tabLength = StoryType.values.length;

  @override
  void didPopNext() {
    super.didPopNext();
    Future<void>.delayed(
      const Duration(milliseconds: 500),
      getIt<CommentCache>().resetComments,
    );
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabLength, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      buildWhen: (previous, current) =>
      (previous.mapOrNull(loaded: (prev) => prev.complexStoryTile)) !=
          (current.mapOrNull(loaded: (curr) => curr.complexStoryTile)),
      builder: (context, state) => state.map(
        loading: (_) => const Loading(useScaffold: false),
        loaded: (state) => DefaultTabController(
          length: tabLength,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: PreferredSize(
              preferredSize: const Size(0, 40),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).padding.top - 8,
                  ),
                  CustomTabBar(tabController: tabController,
                  ),
                ],
              ),
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: <Widget>[
                for (final type in StoryType.values)
                  StoriesListView(
                    key: ValueKey<StoryType>(type),
                    storyType: type,
                    onStoryTapped: onStoryTapped,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onStoryTapped(Story story) {
    final isJobWithLink = story.isJob && story.url.isNotEmpty;

    if (isJobWithLink) {
    } else {
      final args = ItemPageArgs(item: story);

      context.pushNamed(AppRoute.item.name, extra: args);
    }

    if (story.url.isNotEmpty && isJobWithLink) {
      LinkUtils.launch(story.url);
    }

    context.read<StoriesBloc>().add(StoriesEvent.storyRead(story: story));
  }
}
