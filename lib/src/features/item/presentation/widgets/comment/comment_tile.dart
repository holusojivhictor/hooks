import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/extensions/context_extension.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({
    required this.comment,
    required this.fetchMode,
    super.key,
    this.onReplyTapped,
    this.onMoreTapped,
    this.onEditTapped,
    this.onRightMoreTapped,
    this.opUsername,
    this.actionable = true,
    this.level = 0,
    this.onTap,
  });

  final String? opUsername;
  final Comment comment;
  final int level;
  final bool actionable;
  final FetchMode fetchMode;
  final void Function(Comment)? onReplyTapped;
  final void Function(Comment, Rect?)? onMoreTapped;
  final void Function(Comment)? onEditTapped;
  final void Function(Comment)? onRightMoreTapped;
  final VoidCallback? onTap;

  static final Map<int, Color> _colors = <int, Color>{};

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CollapseCubit>(
      key: ValueKey<String>('${comment.id}-BlocProvider'),
      lazy: false,
      create: (_) => CollapseCubit(
        context.tryRead<CollapseCache>() ?? CollapseCache(),
        commentId: comment.id,
      )..init(),
      child: Placeholder(),
    );
  }
}
