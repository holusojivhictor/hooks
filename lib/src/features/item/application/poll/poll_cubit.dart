import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

part 'poll_state.dart';

class PollCubit extends Cubit<PollState> {
  PollCubit(
    this._storiesService, {
    required Story story,
  })  : _story = story,
        super(PollState.init());

  final StoriesService _storiesService;
  final Story _story;

  Future<void> init({
    bool refresh = false,
  }) async {
    if (refresh) {
      emit(PollState.init());
    }

    emit(state.copyWith(status: PollStatus.loading));

    var pollOptionsIds = _story.parts;

    if (pollOptionsIds.isEmpty || refresh) {
      final updatedStory = await _storiesService.fetchStory(id: _story.id);

      if (updatedStory != null) {
        pollOptionsIds = updatedStory.parts;
      }
    }

    if (pollOptionsIds.isEmpty) {
      emit(state.copyWith(status: PollStatus.loaded));
      return;
    }

    if (pollOptionsIds.isNotEmpty) {
      final pollOptions = (await _storiesService
          .fetchPollOptionsStream(ids: pollOptionsIds)
          .toSet())
          .toList();

      final totalVotes = pollOptions.map((PollOption e) => e.score)
          .reduce((int value, int element) => value + element);

      for (final pollOption in pollOptions) {
        final ratio = _calculateRatio(totalVotes, pollOption.score);
        final updatedOption = pollOption.copyWith(ratio: ratio);

        emit(
          state.copyWith(
            totalVotes: totalVotes,
            pollOptions: <PollOption>[...state.pollOptions, updatedOption]
              ..sort((PollOption left, PollOption right) => right.score.compareTo(left.score)),
          ),
        );
      }

      emit(state.copyWith(status: PollStatus.loaded));
    }
  }

  void refresh() => init(refresh: true);

  double _calculateRatio(int totalVotes, int votes) =>
      totalVotes == 0 ? 0 : votes / totalVotes;
}
