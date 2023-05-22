import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/auth/application/auth/auth_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:hooks/src/features/item/presentation/widgets/buttons/custom_fab.dart';
import 'package:hooks/src/features/item/presentation/widgets/comment/reply_box.dart';
import 'package:hooks/src/features/item/presentation/widgets/comment/time_machine_dialog.dart';
import 'package:hooks/src/features/item/presentation/widgets/main_view.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ItemPage extends StatefulWidget {
  const ItemPage({
    required this.item,
    required this.parentComments,
    super.key,
  });

  final Item item;
  final List<Comment> parentComments;

  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> with RouteAware {
  static const Duration _storyLinkTapThrottleDelay = Duration(seconds: 2);

  final TextEditingController commentEditingController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  final Throttle storyLinkTapThrottle = Throttle(
    delay: _storyLinkTapThrottleDelay,
  );
  final GlobalKey fontSizeIconButtonKey = GlobalKey();

  @override
  void didPop() {
    super.didPop();
    if (context.read<EditCubit>().state.text.isNullOrEmpty) {
      context.read<EditCubit>().onReplyBoxClosed();
    }
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);

      if (route == null) return;

      getIt<RouteObserver<ModalRoute<dynamic>>>().subscribe(this, route);
    });

    commentEditingController.text = context.read<EditCubit>().state.text ?? '';
  }

  @override
  void dispose() {
    commentEditingController.dispose();
    storyLinkTapThrottle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return MultiBlocListener(
          listeners: <BlocListener<dynamic, dynamic>>[
            BlocListener<PostCubit, PostState>(
              listener: (context, postState) {
                final fToast = ToastUtils.of(context);
                if (postState.status == PostStatus.successful) {
                  // TODO(morpheus): Monitor pop
                  context.go(AppRoute.item.name);

                  final verb =
                      context.read<EditCubit>().state.replyingTo == null
                          ? 'updated'
                          : 'submitted';
                  final msg = 'Comment $verb!';
                  HapticFeedback.lightImpact();
                  ToastUtils.showInfoToast(fToast, msg);
                  context.read<EditCubit>().onReplySubmittedSuccessfully();
                  context.read<PostCubit>().reset();
                } else if (postState.status == PostStatus.failure) {
                  context.go(AppRoute.item.name);

                  ToastUtils.showErrorToast(fToast, Constants.errorMessage);
                  context.read<PostCubit>().reset();
                }
              },
            ),
            BlocListener<EditCubit, EditState>(
              listenWhen: (previous, current) {
                return previous.replyingTo != current.replyingTo ||
                    previous.itemBeingEdited != current.itemBeingEdited ||
                    commentEditingController.text != current.text;
              },
              listener: (context, editState) {
                if (editState.replyingTo != null ||
                    editState.itemBeingEdited != null) {
                  if (editState.text == null) {
                    commentEditingController.clear();
                  } else {
                    final text = editState.text!;
                    commentEditingController
                      ..text = text
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: text.length),
                      );
                  }
                } else {
                  commentEditingController.clear();
                }
              },
            ),
          ],
          child: Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: true,
            appBar: CustomAppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              item: widget.item,
            ),
            body: MainView(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              commentEditingController: commentEditingController,
              authState: authState,
              topPadding: topPadding,
              onMoreTapped: onMoreTapped,
              onRightMoreTapped: onRightMoreTapped,
              onReplyTapped: showReplyBox,
            ),
            floatingActionButton: CustomFloatingActionButton(
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
            ),
          ),
        );
      },
    );
  }

  void showReplyBox() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ReplyBox(
              textEditingController: commentEditingController,
              onSendTapped: onSendTapped,
              onCloseTapped: () {
                context.read<EditCubit>().onReplyBoxClosed();
                commentEditingController.clear();
              },
              onChanged: context.read<EditCubit>().onTextChanged,
            ),
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom,
            )
          ],
        );
      },
    );
  }

  void onRightMoreTapped(Comment comment) {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.av_timer),
                  title: const Text('View ancestors'),
                  onTap: () {
                    Navigator.pop(context);
                    onTimeMachineActivated(comment);
                  },
                  enabled:
                  comment.level > 0 && !(comment.dead || comment.deleted),
                ),
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('View in separate thread'),
                  onTap: () {
                    Navigator.pop(context);
                    goToItemScreen(
                      context: context,
                      args: ItemPageArgs(
                        item: comment,
                        useCommentCache: true,
                      ),
                    );
                  },
                  enabled: !(comment.dead || comment.deleted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onTimeMachineActivated(Comment comment) {
    final size = MediaQuery.of(context).size;
    const widthFactor = 0.9;
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return TimeMachineDialog(
          comment: comment,
          size: size,
          widthFactor: widthFactor,
        );
      },
    );
  }

  void onSendTapped() {
    final authBloc = context.read<AuthBloc>();
    final postCubit = context.read<PostCubit>();
    final editState = context.read<EditCubit>().state;
    final replyingTo = editState.replyingTo;
    final itemEdited = editState.itemBeingEdited;

    if (authBloc.state.isLoggedIn) {
      final text = commentEditingController.text;
      if (text.isEmpty) {
        return;
      }

      if (itemEdited != null) {
        postCubit.edit(text: text, id: itemEdited.id);
      } else if (replyingTo != null) {
        postCubit.post(text: text, to: replyingTo.id);
      }
    } else {
      onLoginTapped();
    }
  }
}
