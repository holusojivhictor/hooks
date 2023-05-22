import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/linkify/linkify.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/utils/utils.dart';

class MorePopupMenu extends StatelessWidget {
  const MorePopupMenu({
    required this.item,
    required this.isBlocked,
    required this.onLoginTapped,
    super.key,
  });

  final Item item;
  final bool isBlocked;
  final VoidCallback onLoginTapped;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VoteCubit>(
      create: (context) {
        final authService = getIt<AuthService>();
        final settingsService = getIt<SettingsService>();
        return VoteCubit(
          authService,
          settingsService,
          context.read<AuthBloc>(),
          item: item,
        );
      },
      child: BlocConsumer<VoteCubit, VoteState>(
        listenWhen: (previous, current) {
          return previous.status != current.status;
        },
        listener: (BuildContext context, VoteState voteState) {
          final fToast = ToastUtils.of(context);
          if (voteState.status == VoteStatus.submitted) {
            ToastUtils.showInfoToast(fToast, 'Vote submitted successfully.');
          } else if (voteState.status == VoteStatus.canceled) {
            ToastUtils.showInfoToast(fToast, 'Vote canceled.');
          } else if (voteState.status == VoteStatus.failure) {
            ToastUtils.showErrorToast(fToast, Constants.errorMessage);
          } else if (voteState.status ==
              VoteStatus.failureKarmaBelowThreshold) {
            ToastUtils.showErrorToast(
              fToast,
              "You can't downvote due to low karma",
            );
          } else if (voteState.status == VoteStatus.failureNotLoggedIn) {
            ToastUtils.showInfoToast(
              fToast,
              'Not logged in, no voting! Tap to login.',
              action: onLoginTapped,
            );
          } else if (voteState.status == VoteStatus.failureBeHumble) {
            ToastUtils.showInfoToast(fToast, 'No voting on your own post!');
          }

          Navigator.pop(context, MenuAction.upvote);
        },
        builder: (BuildContext context, VoteState voteState) {
          final upvoted = voteState.vote == Vote.up;
          final downvoted = voteState.vote == Vote.down;
          return ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BlocProvider<UserCubit>(
                    create: (context) {
                      final storiesService = getIt<StoriesService>();
                      return UserCubit(storiesService)..init(userId: item.by);
                    },
                    child: BlocBuilder<UserCubit, UserState>(
                      builder: (BuildContext context, UserState state) {
                        return Semantics(
                          excludeSemantics: state.status == UserStatus.loading,
                          child: ListTile(
                            leading: const Icon(
                              Icons.account_circle,
                            ),
                            title: Text(item.by),
                            subtitle: Text(
                              state.user.description,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog<void>(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  semanticLabel:
                                      '''About ${state.user.id}. ${state.user.about}''',
                                  title: Text('About ${state.user.id}',
                                  ),
                                  content: state.user.about.isEmpty
                                      ? const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'empty',
                                              style: TextStyle(
                                                color: AppColors.grey4,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SelectableLinkify(
                                          text: HtmlUtils.parseHtml(
                                            state.user.about,
                                          ),
                                          linkStyle: const TextStyle(
                                            color: AppColors.primary,
                                          ),
                                          onOpen: (LinkableElement link) =>
                                              LinkUtils.launch(link.url),
                                          semanticsLabel: state.user.about,
                                        ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Okay',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.expand_less,
                      color: upvoted ? AppColors.primary : null,
                    ),
                    title: Text(
                      upvoted ? 'Upvoted' : 'Upvote',
                      style: upvoted
                          ? const TextStyle(color: AppColors.primary)
                          : null,
                    ),
                    subtitle:
                        item is Story ? Text(item.score.toString()) : null,
                    onTap: context.read<VoteCubit>().upvote,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.expand_more,
                      color: downvoted ? AppColors.primary : null,
                    ),
                    title: Text(
                      downvoted ? 'Downvoted' : 'Downvote',
                      style: downvoted
                          ? const TextStyle(color: AppColors.primary)
                          : null,
                    ),
                    onTap: context.read<VoteCubit>().downvote,
                  ),
                  BlocBuilder<FavCubit, FavState>(
                    builder: (BuildContext context, FavState state) {
                      final isFav = state.favIds.contains(item.id);
                      return ListTile(
                        leading: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? AppColors.primary : null,
                        ),
                        title: Text(
                          isFav ? 'Unfavorite' : 'Favorite',
                        ),
                        onTap: () => Navigator.pop(
                          context,
                          MenuAction.fav,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.local_police),
                    title: const Text(
                      'Flag',
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      MenuAction.flag,
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      isBlocked ? Icons.visibility : Icons.visibility_off,
                    ),
                    title: Text(
                      isBlocked ? 'Unblock' : 'Block',
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      MenuAction.block,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.close),
                    title: const Text(
                      'Cancel',
                    ),
                    onTap: () => Navigator.pop(
                      context,
                      MenuAction.cancel,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
