import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/auth/application/auth_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
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

                  final verb = context.read<EditCubit>().state.replyingTo == null ? 'updated' : 'submitted';
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
                if (editState.replyingTo != null || editState.itemBeingEdited != null) {
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
          child: const Placeholder(),
        );
      },
    );
  }
}
