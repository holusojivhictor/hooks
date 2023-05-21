import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';

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
              FadeIn(),
          ],
        );
      },
    );
  }
}
