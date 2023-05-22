import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/comment/comment_tile.dart';
import 'package:hooks/src/features/item/presentation/widgets/parent_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MainView extends StatelessWidget {
  const MainView({
    required this.itemScrollController,
    required this.itemPositionsListener,
    required this.commentEditingController,
    required this.authState,
    required this.topPadding,
    required this.onMoreTapped,
    required this.onRightMoreTapped,
    required this.onReplyTapped,
    super.key,
  });

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;
  final TextEditingController commentEditingController;
  final AuthState authState;
  final double topPadding;
  final void Function(Item item, Rect? rect) onMoreTapped;
  final ValueChanged<Comment> onRightMoreTapped;
  final VoidCallback onReplyTapped;

  static const int _loadingIndicatorOpacityAnimationDuration = 300;
  static const double _trailingBoxHeight = 240;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: BlocBuilder<CommentsCubit, CommentsState>(
            builder: (context, state) {
              return RefreshIndicator(
                displacement: 100,
                onRefresh: () async {
                  unawaited(HapticFeedback.lightImpact());

                  if (state.onlyShowTargetComment == false) {
                    unawaited(context.read<CommentsCubit>().refresh());
                    if (state.item.isPoll) {
                      context.read<PollCubit>().refresh();
                    }
                  }
                },
                child: ScrollablePositionedList.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemScrollController: itemScrollController,
                  itemPositionsListener: itemPositionsListener,
                  itemCount: state.comments.length + 2,
                  padding: EdgeInsets.only(top: topPadding),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ParentItemSection(
                        commentEditingController: commentEditingController,
                        state: state,
                        authState: authState,
                        topPadding: topPadding,
                        onMoreTapped: onMoreTapped,
                        onRightMoreTapped: onRightMoreTapped,
                        onReplyTapped: onReplyTapped,
                      );
                    } else if (index == state.comments.length + 1) {
                      if ((state.status == CommentsStatus.allLoaded && state.comments.isNotEmpty) || state.onlyShowTargetComment) {
                        return const SizedBox(
                          height: _trailingBoxHeight,
                          child: Center(
                            child: Text('Nothing found'),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }

                    index = index - 1;
                    final comment = state.comments.elementAt(index);
                    return FadeIn(
                      key: ValueKey<String>('${comment.id}-FadeIn'),
                      child: CommentTile(
                        comment: comment,
                        level: comment.level,
                        opUsername: state.item.by,
                        fetchMode: state.fetchMode,
                        onReplyTapped: (cmt) {
                          HapticFeedback.lightImpact();
                          if (cmt.deleted || cmt.dead) {
                            return;
                          }

                          if (cmt.id != context.read<EditCubit>().state.replyingTo?.id) {
                            commentEditingController.clear();
                          }

                          context.read<EditCubit>().onReplyTapped(cmt);
                          onReplyTapped();
                        },
                        onEditTapped: (cmt) {
                          HapticFeedback.lightImpact();
                          if (cmt.deleted || cmt.dead) {
                            return;
                          }
                          commentEditingController.clear();
                          context.read<EditCubit>().onEditTapped(cmt);

                          onReplyTapped();
                        },
                        onMoreTapped: onMoreTapped,
                        onRightMoreTapped: onRightMoreTapped,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Positioned(
          height: 4,
          bottom: 0,
          left: 0,
          right: 0,
          child: BlocBuilder<CommentsCubit, CommentsState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (BuildContext context, CommentsState state) {
              return AnimatedOpacity(
                opacity: state.status == CommentsStatus.loading ? 1 : 0,
                duration: const Duration(
                  milliseconds: _loadingIndicatorOpacityAnimationDuration,
                ),
                child: const LinearProgressIndicator(),
              );
            },
          ),
        ),
      ],
    );
  }
}
