import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/auth/application/auth_bloc.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
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
              return Scrollbar(
                interactive: true,
                child: RefreshIndicator(
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
                        return const Placeholder();
                      } else if (index == state.comments.length + 1) {
                        if ((state.status == CommentsStatus.allLoaded &&
                            state.comments.isNotEmpty) || state.onlyShowTargetComment) {
                          return const SizedBox(
                            height: _trailingBoxHeight,
                            child: Center(
                              child: Text('Nothing found'),
                            ),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }

                      return Placeholder();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
