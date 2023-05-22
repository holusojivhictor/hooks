import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/auth/application/auth/auth_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/custom_circular_progress_indicator.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/poll/poll_view.dart';
import 'package:hooks/src/features/item/presentation/widgets/text/item_text.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/utils/utils.dart';

class ParentItemSection extends StatelessWidget {
  const ParentItemSection({
    required this.commentEditingController,
    required this.state,
    required this.authState,
    required this.topPadding,
    required this.onMoreTapped,
    required this.onRightMoreTapped,
    required this.onReplyTapped,
    super.key,
  });

  final TextEditingController commentEditingController;
  final CommentsState state;
  final AuthState authState;
  final double topPadding;
  final void Function(Item item, Rect? rect) onMoreTapped;
  final ValueChanged<Comment> onRightMoreTapped;
  final VoidCallback onReplyTapped;

  static const double _viewParentButtonWidth = 100;
  static const double _viewRootButtonWidth = 80;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      label: '''Posted by ${state.item.by} ${state.item.timeAgo}, ${state.item.title}. ${state.item.text}''',
      child: Column(
        children: <Widget>[
          Slidable(
            startActionPane: ActionPane(
              motion: const BehindMotion(),
              children: <Widget>[
                SlidableAction(
                  onPressed: (_) {
                    HapticFeedback.lightImpact();

                    if (state.item.id != context.read<EditCubit>().state.replyingTo?.id) {
                      commentEditingController.clear();
                    }
                    context.read<EditCubit>().onReplyTapped(state.item);

                    onReplyTapped();
                  },
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  icon: Icons.message,
                ),
                SlidableAction(
                  onPressed: (BuildContext context) => onMoreTapped(state.item, context.rect),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  icon: Icons.more_horiz,
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    children: <Widget>[
                      Text(
                        state.item.by,
                        style: const TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        state.item.timeAgo,
                        style: const TextStyle(
                          color: AppColors.grey4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: <Widget>[
                    if (state.item is Story)
                      InkWell(
                        onTap: () => LinkUtils.launch(state.item.url),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 6,
                          ),
                          child: Text.rich(
                            TextSpan(
                              style: textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  semanticsLabel: state.item.title,
                                  text: state.item.title,
                                  style: textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: state.item.url.isNotEmpty
                                        ? AppColors.primary : null,
                                  ),
                                ),
                                if (state.item.url.isNotEmpty)
                                  TextSpan(
                                    text: ''' (${(state.item as Story).readableUrl})''',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            textScaleFactor: MediaQuery.of(context).textScaleFactor,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                    if (state.item.text.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ItemText(
                            item: state.item,
                          ),
                        ),
                      ),
                  ],
                ),
                if (state.item.isPoll)
                  BlocProvider<PollCubit>(
                    create: (context) {
                      return PollCubit(
                        getIt<StoriesService>(),
                        story: state.item as Story,
                      )..init();
                    },
                    child: const PollView(),
                  ),
              ],
            ),
          ),
          if (state.item.text.isNotEmpty)
            const SizedBox(height: 8),
          const Divider(height: 0),
          if (state.onlyShowTargetComment) ...<Widget>[
            Center(
              child: TextButton(
                onPressed: () => context.read<CommentsCubit>().loadAll(state.item as Story),
                child: const Text('View all comments'),
              ),
            ),
            const Divider(height: 0),
          ] else ...<Widget>[
            Row(
              children: <Widget>[
                if (state.item is Story) ...<Widget>[
                  const SizedBox(width: 12),
                  Text(
                    '''${state.item.score} karma, ${state.item.descendants} comment${state.item.descendants > 1 ? 's' : ''}''',
                    style: textTheme.bodyMedium!.copyWith(fontSize: 13),
                  ),
                ] else ...<Widget>[
                  const SizedBox(width: 4),
                  SizedBox(
                    width: _viewParentButtonWidth,
                    child: TextButton(
                      onPressed: context.read<CommentsCubit>().loadParentThread,
                      child: state.fetchParentStatus == CommentsStatus.loading
                          ? const _LoadingComments()
                          : Text('View parent', style: textTheme.bodyMedium!.copyWith(fontSize: 13)),
                    ),
                  ),
                  SizedBox(
                    width: _viewRootButtonWidth,
                    child: TextButton(
                      onPressed: context.read<CommentsCubit>().loadRootThread,
                      child: state.fetchRootStatus == CommentsStatus.loading
                          ? const _LoadingComments()
                          : Text('View root', style: textTheme.bodyMedium!.copyWith(fontSize: 13)),
                    ),
                  ),
                ],
                const Spacer(),
                DropdownButton<FetchMode>(
                  value: state.fetchMode,
                  underline: const SizedBox.shrink(),
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  items: FetchMode.values.map((FetchMode val) {
                    return DropdownMenuItem<FetchMode>(
                      value: val,
                      child: Text(
                        val.description,
                        style: textTheme.bodyMedium!.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: context.read<CommentsCubit>().onFetchModeChanged,
                ),
                const SizedBox(width: 6),
                DropdownButton<CommentsOrder>(
                  value: state.order,
                  underline: const SizedBox.shrink(),
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  items: CommentsOrder.values.map((CommentsOrder val) {
                    return DropdownMenuItem<CommentsOrder>(
                      value: val,
                      child: Text(
                        val.description,
                        style: textTheme.bodyMedium!.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: context.read<CommentsCubit>().onOrderChanged,
                ),
                const SizedBox(width: 4),
              ],
            ),
            const Divider(height: 0),
          ],
          if (state.comments.isEmpty && state.status == CommentsStatus.allLoaded) ...<Widget>[
            const SizedBox(height: 240),
            const Center(
              child: Text(
                'Nothing yet',
                style: TextStyle(color: AppColors.grey4),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _LoadingComments extends StatelessWidget {
  const _LoadingComments();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 12,
      width: 12,
      child: CustomCircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}
