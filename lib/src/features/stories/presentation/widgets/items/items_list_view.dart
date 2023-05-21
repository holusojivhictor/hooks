import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/custom_circular_progress_indicator.dart';
import 'package:hooks/src/features/common/presentation/linkify/linkify.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/items/widgets/story_tile.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ItemsListView<T extends Item> extends StatelessWidget {
  const ItemsListView({
    required this.showWebPreview,
    required this.showMetadata,
    required this.showUrl,
    required this.items,
    required this.onTap,
    required this.refreshController,
    this.useCommentTile = false,
    this.showCommentBy = false,
    this.enablePullDown = true,
    this.markReadStories = false,
    this.useConsistentFontSize = false,
    super.key,
    this.onRefresh,
    this.onLoadMore,
    this.onMoreTapped,
  });

  final bool showWebPreview;
  final bool useCommentTile;
  final bool showCommentBy;
  final bool showMetadata;
  final bool showUrl;
  final bool enablePullDown;
  final bool markReadStories;
  final bool useConsistentFontSize;
  final List<T> items;
  final RefreshController refreshController;
  final VoidCallback? onRefresh;
  final VoidCallback? onLoadMore;
  final void Function(T) onTap;
  final void Function(Story, Rect?)? onMoreTapped;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final child = ListView(
      children: <Widget>[
        ...items.map((T e) {
          if (e is Story) {
            final hasRead = context.read<StoriesBloc>().hasRead(e);
            return <Widget>[
              FadeIn(
                child: Slidable(
                  startActionPane: ActionPane(
                    motion: const BehindMotion(),
                    children: <Widget>[
                      SlidableAction(
                        onPressed: (_) => onMoreTapped?.call(e, context.rect),
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        icon: showWebPreview ? Icons.more_horiz : null,
                        label: showWebPreview ? null : 'more',
                      ),
                    ],
                  ),
                  child: StoryTile(
                    key: ValueKey<int>(e.id),
                    story: e,
                    onTap: () => onTap(e),
                    showWebPreview: showWebPreview,
                    showMetadata: showMetadata,
                    showUrl: showUrl,
                    hasRead: markReadStories && hasRead,
                    simpleTileFontSize: useConsistentFontSize ? 14 : 16,
                  ),
                ),
              ),
              if (!showWebPreview)
                const Divider(height: 0),
            ];
          } else if (e is Comment) {
            if (useCommentTile) {
              return <Widget>[
                if (showWebPreview)
                  const Divider(height: 0),
                _CommentTile(
                  comment: e,
                  onTap: () => onTap(e),
                  fontSize: showWebPreview ? 14 : 16,
                ),
                const Divider(height: 0),
              ];
            }
            return <Widget>[
              FadeIn(
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: InkWell(
                    onTap: () => onTap(e),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (e.deleted)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'deleted',
                                style: TextStyle(color: AppColors.grey4),
                              ),
                            ),
                          ),
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 6,
                                ),
                                child: Linkify(
                                  text: '''${showCommentBy ? '${e.by}: ' : ''}${e.text}''',
                                  maxLines: 4,
                                  linkStyle: textTheme.bodyMedium!.copyWith(color: AppColors.primary),
                                  onOpen: (link) => LinkUtils.launch(link.url),
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                  e.timeAgo,
                                  style: textTheme.bodyMedium!.copyWith(color: AppColors.grey4),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 0),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(height: 0),
            ];
          }

          return <Widget>[Container()];
        }).expand((List<Widget> element) => element),
      ],
    );

    return SmartRefresher(
      enablePullUp: true,
      enablePullDown: enablePullDown,
      header: const MaterialClassicHeader(),
      footer: CustomFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
        builder: (context, mode) {
          const height = 55.0;
          late final Widget body;

          if (mode == LoadStatus.loading) {
            body = const CustomCircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = const Text('Loading failed');
          } else {
            body = const SizedBox.shrink();
          }
          return SizedBox(
            height: height,
            child: Center(child: body),
          );
        },
      ),
      controller: refreshController,
      onLoading: onLoadMore,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onTap,
    this.fontSize = 16,
  });

  final Comment comment;
  final VoidCallback onTap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    comment.text,
                    style: TextStyle(
                      fontSize: fontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    comment.metadata,
                    style: TextStyle(
                      color: AppColors.grey4,
                      fontSize: fontSize - 2,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
