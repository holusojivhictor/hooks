import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/domain/models/db/models.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ItemListView<T extends Item> extends StatelessWidget {
  const ItemListView({
    required this.useCommentTile,
    required this.showCommentBy,
    required this.showMetadata,
    required this.enablePullDown,
    required this.markReadStories,
    required this.useConsistentFontSize,
    required this.items,
    required this.refreshController,
    super.key,
    this.onRefresh,
    this.onLoadMore,
  });

  final bool useCommentTile;
  final bool showCommentBy;
  final bool showMetadata;
  final bool enablePullDown;
  final bool markReadStories;
  final bool useConsistentFontSize;
  final List<T> items;
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final child = ListView(
      children: <Widget>[
        ...items.map((T e) {
          if (e is Story) {
            final hasRead = context.read<StoriesBloc>().hasRead(e);
            return <Widget>[
              GestureDetector(
                child: FadeIn(
                  child: Slidable(
                    enabled: true,
                    child: Placeholder(),
                  ),
                ),
              ),
              const Divider(height: 0),
            ];
          } else if (e is Comment) {
          }

          return <Widget>[Container()];
        }).expand((List<Widget> element) => element),
      ],
    );
    return const Placeholder();
  }
}
