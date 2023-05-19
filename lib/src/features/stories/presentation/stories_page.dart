import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/loading/loading.dart';
import 'package:hooks/src/features/stories/presentation/widgets/tab/custom_tab_bar.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with SingleTickerProviderStateMixin {
  late final TabController tabController;

  static final int tabLength = StoryType.values.length;

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
                  const Placeholder(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
