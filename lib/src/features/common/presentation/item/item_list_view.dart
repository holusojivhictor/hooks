import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
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
    final child = ListView();
    return const Placeholder();
  }
}
