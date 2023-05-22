import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/auth/application/auth/auth_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/presentation/builders/bloc_builder_2.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/text/centered_text.dart';
import 'package:hooks/src/features/item/presentation/widgets/text/item_text.dart';

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
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider<CollapseCubit>(
      key: ValueKey<String>('${comment.id}-BlocProvider'),
      lazy: false,
      create: (_) => CollapseCubit(
        context.tryRead<CollapseCache>() ?? CollapseCache(),
        commentId: comment.id,
      )..init(),
      child: BlocBuilder2<CollapseCubit, CollapseState, BlocklistCubit, BlocklistState>(
        builder: (context, state, blocklistState) {
          if (actionable && state.hidden) return const SizedBox.shrink();

          final color = _getColor(level);

          final child = Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Slidable(
                  startActionPane: actionable
                      ? ActionPane(
                          motion: const StretchMotion(),
                          children: <Widget>[
                            SlidableAction(
                              onPressed: (_) => onReplyTapped?.call(comment),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              icon: Icons.message,
                            ),
                            if (context.read<AuthBloc>().state.user.id == comment.by)
                              SlidableAction(
                                onPressed: (_) => onEditTapped?.call(comment),
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                icon: Icons.edit,
                              ),
                            SlidableAction(
                              onPressed: (BuildContext context) => onMoreTapped?.call(comment, context.rect),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              icon: Icons.more_horiz,
                            ),
                          ],
                        )
                      : null,
                  endActionPane: actionable
                      ? ActionPane(
                          motion: const StretchMotion(),
                          children: <Widget>[
                            SlidableAction(
                              onPressed: (_) => onRightMoreTapped?.call(comment),
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              icon: Icons.av_timer,
                            ),
                          ],
                        )
                      : null,
                  child: InkWell(
                    onTap: () {
                      if (actionable) {
                        HapticFeedback.selectionClick();
                        context.read<CollapseCubit>().collapse();
                      } else {
                        onTap?.call();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 6,
                            right: 6,
                            top: 6,
                          ),
                          child: Row(
                            children: <Widget>[
                              Text(
                                comment.by,
                                style: textTheme.bodyMedium!.copyWith(color: color),
                              ),
                              if (comment.by == opUsername)
                                const Text(
                                  ' - OP',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                comment.timeAgo,
                                style: const TextStyle(
                                  color: AppColors.grey4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedSize(
                          duration: Constants.kAnimationDuration,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              if (actionable && state.collapsed)
                                CenteredText(
                                  text: '''collapsed (${state.collapsedCount + 1})''',
                                  color: AppColors.primaryShade,
                                )
                              else if (comment.hidden)
                                const CenteredText.hidden()
                              else if (comment.deleted)
                                const CenteredText.deleted()
                              else if (comment.dead)
                                const CenteredText.dead()
                              else if (blocklistState.blocklist.contains(comment.by))
                                const CenteredText.blocked()
                              else
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    right: 2,
                                    top: 6,
                                    bottom: 12,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Semantics(
                                      label: '''At level ${comment.level}.''',
                                      child: ItemText(
                                        key: ValueKey<int>(comment.id),
                                        item: comment,
                                        onTap: () {
                                          if (onTap == null) {
                                            _onTextTapped(context);
                                          } else {
                                            onTap!.call();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_shouldShowLoadButton(context))
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        context.read<CommentsCubit>()
                                            .loadMore(comment: comment);
                                      },
                                      child: Text(
                                        '''Load ${comment.kids.length} ${comment.kids.length > 1 ? 'replies' : 'reply'}''',
                                        style: const TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const Divider(height: 0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          const commentColor = Colors.transparent;
          final isMyComment = comment.deleted == false &&
              context.read<AuthBloc>().state.username == comment.by;

          Widget wrapper = child;

          if (isMyComment && level == 0) {
            return Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
              ),
              child: wrapper,
            );
          }

          for (final i in level.to(0, inclusive: false)) {
            final wrapperBorderColor = _getColor(i);
            final shouldHighlight = isMyComment && i == level;
            wrapper = Container(
              clipBehavior: Clip.hardEdge,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                border: i != 0
                    ? Border(left: BorderSide(color: wrapperBorderColor))
                    : null,
                color: shouldHighlight
                    ? AppColors.primary.withOpacity(0.2)
                    : commentColor,
              ),
              child: wrapper,
            );
          }

          return wrapper;
        },
      ),
    );
  }

  Color _getColor(int level) {
    final initialLevel = level;
    if (_colors[initialLevel] != null) return _colors[initialLevel]!;

    while (level >= 10) {
      // ignore: parameter_assignments
      level = level - 10;
    }

    var r = level * 40 < 255 ? 152 : (level * 20).clamp(0, 255);
    var g = (level * 40).clamp(0, 255);
    final b = (level * 40).clamp(0, 255);

    if (r == 255 && g == 255) {
      r = (level * 30 - 255).clamp(0, 255);
      g = (level * 40 - 255).clamp(0, 255);
    }

    final color = Color.fromRGBO(r, g, b, 1);

    _colors[initialLevel] = color;
    return color;
  }

  bool _shouldShowLoadButton(BuildContext context) {
    final collapseState = context.read<CollapseCubit>().state;
    final commentsState = context.tryRead<CommentsCubit>()?.state;
    return fetchMode == FetchMode.lazy &&
        comment.kids.isNotEmpty &&
        collapseState.collapsed == false &&
        commentsState?.commentIds.contains(comment.kids.first) == false &&
        commentsState?.onlyShowTargetComment == false;
  }

  void _onTextTapped(BuildContext context) {
    if (context.read<SettingsBloc>().tapAnywhereToCollapse) {
      HapticFeedback.selectionClick();
      context.read<CollapseCubit>().collapse();
    }
  }
}
