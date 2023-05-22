import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/text/item_text.dart';

class ReplyBox extends StatefulWidget {
  const ReplyBox({
    required this.textEditingController,
    required this.onSendTapped,
    required this.onCloseTapped,
    required this.onChanged,
    super.key,
  });

  final TextEditingController textEditingController;
  final VoidCallback onSendTapped;
  final VoidCallback onCloseTapped;
  final ValueChanged<String> onChanged;

  @override
  State<ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<ReplyBox> {
  bool expanded = false;
  double? expandedHeight;

  static const double _collapsedHeight = 100;

  @override
  Widget build(BuildContext context) {
    expandedHeight ??= MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<EditCubit, EditState>(
      buildWhen: (EditState previous, EditState current) =>
          previous.showReplyBox != current.showReplyBox ||
          previous.itemBeingEdited != current.itemBeingEdited ||
          previous.replyingTo != current.replyingTo,
      builder: (context, editState) {
        return BlocBuilder<PostCubit, PostState>(
          builder: (context, postState) {
            final replyingTo = editState.replyingTo;
            final isLoading = postState.status == PostStatus.loading;

            return AnimatedContainer(
              height: expanded ? expandedHeight : _collapsedHeight,
              duration: Constants.kAnimationDuration,
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: expanded ? Colors.transparent : Colors.black26,
                    blurRadius: 40,
                  ),
                ],
              ),
              child: Material(
                child: Column(
                  children: <Widget>[
                    AnimatedContainer(
                      height: expanded ? 36 : 0,
                      duration: Constants.kAnimationDuration,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              top: 8,
                              bottom: 8,
                            ),
                            child: Text(
                              replyingTo == null
                                  ? 'Editing'
                                  : 'Replying ${replyingTo.by}',
                              style: textTheme.bodyMedium!.copyWith(color: AppColors.grey4),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (!isLoading) ...<Widget>[
                          ...<Widget>[
                            if (replyingTo != null)
                              AnimatedOpacity(
                                opacity: expanded ? 1 : 0,
                                duration: const Duration(milliseconds: 300),
                                child: IconButton(
                                  key: const Key('quote'),
                                  icon: const Icon(
                                    Icons.code,
                                    color: AppColors.primary,
                                    size: 18,
                                  ),
                                  onPressed: expanded ? showTextPopup : null,
                                ),
                              ),
                            IconButton(
                              key: const Key('expand'),
                              icon: Icon(
                                expanded
                                    ? Icons.close_fullscreen
                                    : Icons.open_in_full,
                                color: AppColors.primary,
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  expanded = !expanded;
                                });
                              },
                            ),
                          ],
                          IconButton(
                            key: const Key('close'),
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              Navigator.pop(context);

                              final state = context.read<EditCubit>().state;
                              if (state.replyingTo != null &&
                                  state.text.isNotNullNorEmpty) {
                                closeDialog(context);
                              }
                              widget.onCloseTapped();
                              expanded = false;
                            },
                          ),
                        ],
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            key: const Key('send'),
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primary,
                            ),
                            onPressed: () {
                              widget.onSendTapped();
                              expanded = false;
                            },
                          ),
                      ],
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: widget.textEditingController,
                          maxLines: 100,
                          style: const TextStyle(
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            alignLabelWithHint: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: '...',
                            hintStyle: TextStyle(
                              color: AppColors.grey4,
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                          ),
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.newline,
                          onChanged: widget.onChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void closeDialog(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text(
            'Save draft?',
            style: TextStyle(color: AppColors.grey7),
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                context.read<EditCubit>().deleteDraft();
                Navigator.pop(context);
              },
              child: Text(
                'No',
                style: textTheme.bodyMedium!.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showTextPopup() {
    final replyingTo = context.read<EditCubit>().state.replyingTo;

    if (replyingTo == null) return;
    final textTheme = Theme.of(context).textTheme;
    showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 24,
          ),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 500,
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 6),
                  child: Row(
                    children: <Widget>[
                      Text(
                        replyingTo.by,
                        style: textTheme.bodyMedium!.copyWith(
                          color: AppColors.grey6,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        child: Text(
                          'View thread',
                          style: textTheme.bodyMedium!.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            expanded = false;
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);

                          goToItemScreen(
                            context: context,
                            args: ItemPageArgs(
                              item: replyingTo,
                              useCommentCache: true,
                            ),
                          );
                        },
                      ),
                      TextButton(
                        child: Text(
                          'Copy all',
                          style: textTheme.bodyMedium!.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                        onPressed: () => FlutterClipboard.copy(
                          replyingTo.text,
                        ).then((_) => HapticFeedback.selectionClick()),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 6,
                        top: 6,
                      ),
                      child: SingleChildScrollView(
                        child: ItemText(
                          item: replyingTo,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
