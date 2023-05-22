import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/auth/presentation/login_dialog.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/menu/more_popup_menu.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/utils.dart';

extension StateExtensions on State {
  Future<void>? goToItemScreen({
    required ItemPageArgs args,
    required BuildContext context,
  }) {
    return context.pushNamed(
      AppRoute.item.name,
      extra: args,
    );
  }

  void onMoreTapped(Item item, Rect? rect) {
    HapticFeedback.lightImpact();

    if (item.dead || item.deleted) {
      return;
    }

    final isBlocked =
        context.read<BlocklistCubit>().state.blocklist.contains(item.by);

    showModalBottomSheet<MenuAction>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: MorePopupMenu(
            item: item,
            isBlocked: isBlocked,
            onLoginTapped: onLoginTapped,
          ),
        );
      },
    ).then((MenuAction? action) {
      if (action != null) {
        switch (action) {
          case MenuAction.upvote:
            break;
          case MenuAction.downvote:
            break;
          case MenuAction.fav:
            onFavTapped(item);
          case MenuAction.flag:
            onFlagTapped(item);
          case MenuAction.block:
            onBlockTapped(item, isBlocked: isBlocked);
          case MenuAction.cancel:
            break;
        }
      }
    });
  }

  void onFavTapped(Item item) {
    final favCubit = context.read<FavCubit>();
    final isFav = favCubit.state.favIds.contains(item.id);
    if (isFav) {
      favCubit.removeFav(item.id);
    } else {
      favCubit.addFav(item.id);
    }
  }

  void onFlagTapped(Item item) {
    final theme = Theme.of(context);
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: theme.scaffoldBackgroundColor,
          title: const Text(
            'Flag this comment?',
            style: TextStyle(color: AppColors.grey7),
          ),
          content: Text(
            'Flag this comment posted by ${item.by}?',
            style: theme.textTheme.bodyMedium!
                .copyWith(
                  color: AppColors.grey6,
                ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    ).then((bool? yesTapped) {
      final fToast = ToastUtils.of(context);
      if (yesTapped ?? false) {
        context.read<AuthBloc>().add(AuthEvent.flag(item: item));
        ToastUtils.showInfoToast(fToast, 'Comment flagged!');
      }
    });
  }

  void onBlockTapped(Item item, {required bool isBlocked}) {
    final theme = Theme.of(context);
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: theme.scaffoldBackgroundColor,
          title: Text(
            '${isBlocked ? 'Unblock' : 'Block'} this user?',
            style: const TextStyle(color: AppColors.grey7),
          ),
          content: Text(
            'Do you want to ${isBlocked ? 'unblock' : 'block'} ${item.by}'
            ' and ${isBlocked ? 'display' : 'hide'} '
            'comments posted by this user?',
            style: Theme.of(context).textTheme.bodyMedium!
                .copyWith(
                  color: AppColors.grey6,
                ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    ).then((bool? yesTapped) {
      final fToast = ToastUtils.of(context);
      if (yesTapped ?? false) {
        if (isBlocked) {
          context.read<BlocklistCubit>().removeFromBlocklist(item.by);
        } else {
          context.read<BlocklistCubit>().addToBlocklist(item.by);
        }
        ToastUtils.showInfoToast(
            fToast, 'User ${isBlocked ? 'unblocked' : 'blocked'}!',);
      }
    });
  }

  void onLoginTapped() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoginDialog();
      },
    );
  }
}
