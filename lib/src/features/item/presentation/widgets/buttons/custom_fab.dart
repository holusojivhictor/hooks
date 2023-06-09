import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    required this.itemScrollController,
    required this.itemPositionsListener,
    super.key,
  });

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton.small(
              backgroundColor: theme.canvasColor.withOpacity(0.8),
              heroTag: UniqueKey().hashCode,
              onPressed: () {
                if (state.status == CommentsStatus.loading) return;

                HapticFeedback.selectionClick();
                context.read<CommentsCubit>().jumpUp(
                  itemScrollController,
                  itemPositionsListener,
                );
              },
              child: Icon(
                Icons.keyboard_arrow_up,
                color: state.status == CommentsStatus.loading
                    ? AppColors.grey3
                    : AppColors.variantBlack,
              ),
            ),
            FloatingActionButton.small(
              backgroundColor: theme.canvasColor.withOpacity(0.8),
              heroTag: UniqueKey().hashCode,
              onPressed: () {
                if (state.status == CommentsStatus.loading) return;

                HapticFeedback.selectionClick();
                context.read<CommentsCubit>().jump(
                  itemScrollController,
                  itemPositionsListener,
                );
              },
              child: Icon(
                Icons.keyboard_arrow_down,
                color: state.status == CommentsStatus.loading
                    ? AppColors.grey3
                    : AppColors.variantBlack,
              ),
            ),
          ],
        );
      },
    );
  }
}
