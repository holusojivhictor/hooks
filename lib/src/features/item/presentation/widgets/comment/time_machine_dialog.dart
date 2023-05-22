import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/item/application/bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/item/presentation/widgets/comment/comment_tile.dart';

class TimeMachineDialog extends StatelessWidget {
  const TimeMachineDialog({
    required this.comment,
    required this.size,
    required this.widthFactor,
    super.key,
  });

  final Comment comment;
  final Size size;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TimeMachineCubit>.value(
      value: TimeMachineCubit()..activateTimeMachine(comment),
      child: BlocBuilder<TimeMachineCubit, TimeMachineState>(
        builder: (context, state) {
          return Center(
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: SizedBox(
                height: size.height * 0.8,
                width: size.width * widthFactor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 8),
                          const Text('Ancestors:'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Expanded(
                        child: ListView(
                          children: <Widget>[
                            for (final Comment c in state.ancestors) ...<Widget>[
                              CommentTile(
                                comment: c,
                                actionable: false,
                                fetchMode: FetchMode.eager,
                              ),
                              const Divider(height: 0),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
