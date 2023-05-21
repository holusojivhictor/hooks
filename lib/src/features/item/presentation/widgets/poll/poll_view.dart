import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/auth/application/auth_bloc.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/utils/utils.dart';

class PollView extends StatefulWidget {
  const PollView({super.key});

  @override
  State<PollView> createState() => _PollViewState();
}

class _PollViewState extends State<PollView> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BlocBuilder<PollCubit, PollState>(
      builder: (context, state) {
        return Column(
          children: <Widget>[
            const SizedBox(height: 24),
            if (state.status == PollStatus.loading) ...<Widget>[
              const LinearProgressIndicator(),
              const SizedBox(
                height: 24,
              ),
            ] else ...<Widget>[
              Row(
                children: <Widget>[
                  const SizedBox(width: 24),
                  Text(
                    'Total votes: ${state.totalVotes}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            for (final PollOption option in state.pollOptions)
              FadeIn(
                child: BlocProvider<VoteCubit>(
                  create: (context) {
                    final authService = getIt<AuthService>();
                    final settingsService = getIt<SettingsService>();
                    return VoteCubit(
                      authService,
                      settingsService,
                      context.read<AuthBloc>(),
                      item: option,
                    );
                  },
                  child: BlocConsumer<VoteCubit, VoteState>(
                    listenWhen: (previous, current) {
                      return previous.status != current.status;
                    },
                    listener: voteListener,
                    builder: (context, voteState) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 12,
                          right: 24,
                          bottom: 4,
                        ),
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                context.read<VoteCubit>().upvote();
                              },
                              icon: Icon(
                                Icons.arrow_drop_up,
                                color: voteState.vote == Vote.up ? AppColors.primary : AppColors.grey4,
                                size: 36,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    option.text,
                                  ),
                                  Text(
                                    '''${option.score} vote${option.score > 1 ? 's' : ''}''',
                                    style: textTheme.bodySmall!.copyWith(
                                      color: AppColors.grey4,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: option.ratio,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void voteListener(BuildContext context, VoteState state) {
    final fToast = ToastUtils.of(context)
      ..removeQueuedCustomToasts();

    if (state.status == VoteStatus.submitted) {
      ToastUtils.showInfoToast(fToast, 'Vote submitted successfully.');
    } else if (state.status == VoteStatus.canceled) {
      ToastUtils.showInfoToast(fToast, 'Vote canceled.');
    } else if (state.status == VoteStatus.failure) {
      ToastUtils.showErrorToast(fToast, Constants.errorMessage);
    } else if (state.status == VoteStatus.failureKarmaBelowThreshold) {
      ToastUtils.showInfoToast(fToast, "You can't downvote due to low karma.");
    } else if (state.status == VoteStatus.failureNotLoggedIn) {
      // TODO(morpheus): Add login dialog
      ToastUtils.showInfoToast(
        fToast,
        'Not logged in, no voting! Tap this to login.',
        action: () {},
      );
    } else if (state.status == VoteStatus.failureBeHumble) {
      ToastUtils.showInfoToast(fToast, 'No voting on your own post!');
    }
  }
}
