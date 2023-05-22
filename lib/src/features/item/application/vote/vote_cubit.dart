import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/auth/application/auth/auth_bloc.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'vote_state.dart';

class VoteCubit extends Cubit<VoteState> {
  VoteCubit(
    this._authService,
    this._settingsService,
    this._authBloc, {
    required Item item,
  }) : super(VoteState.init(item: item));

  final AuthService _authService;
  final SettingsService _settingsService;
  final AuthBloc _authBloc;
  static const int _karmaThreshold = 501;

  void init() {
    final vote = _settingsService.vote(
      submittedTo: state.item.id,
      from: _authBloc.state.username,
    );

    final parsedVote = vote == null ? null : vote ? Vote.up : Vote.down;

    emit(state.copyWith(vote: parsedVote));
  }

  Future<void> upvote() async {
    if (!_authBloc.state.isLoggedIn) {
      emit(state.copyWith(status: VoteStatus.failureNotLoggedIn));
      return;
    }

    if (state.item.by == _authBloc.state.username) {
      emit(state.copyWith(status: VoteStatus.failureBeHumble));
      return;
    }

    if (state.vote == null || state.vote == Vote.down) {
      final success = await _authService.upvote(
        id: state.item.id,
        upvote: true,
      );

      if (success) {
        emit(state.copyWith(vote: Vote.up, status: VoteStatus.submitted));

        _settingsService.addVote(
          username: _authBloc.state.username,
          id: state.item.id,
          vote: true,
        );
      } else {
        emit(state.copyWith(status: VoteStatus.failure));
      }
    } else {
      await _authService.upvote(id: state.item.id, upvote: false);
      _settingsService.removeVote(
        username: _authBloc.state.username,
        id: state.item.id,
      );

      emit(state.copyWithVoteRemoved(status: VoteStatus.canceled));
    }
  }

  Future<void> downvote() async {
    if (!_authBloc.state.isLoggedIn) {
      emit(state.copyWith(status: VoteStatus.failureNotLoggedIn));
      return;
    }

    if (state.item.by == _authBloc.state.username) {
      emit(state.copyWith(status: VoteStatus.failureBeHumble));
      return;
    }

    if (_authBloc.state.user.karma >= _karmaThreshold) {
      if (state.vote == null || state.vote == Vote.up) {
        final success = await _authService.downvote(id: state.item.id, downvote: true);

        if (success) {
          _settingsService.addVote(
            username: _authBloc.state.username,
            id: state.item.id,
            vote: false,
          );

          emit(state.copyWith(vote: Vote.down, status: VoteStatus.submitted));
        }
      } else {
        await _authService.downvote(id: state.item.id, downvote: false);
        _settingsService.removeVote(
          username: _authBloc.state.username,
          id: state.item.id,
        );

        emit(state.copyWithVoteRemoved(status: VoteStatus.canceled));
      }
    } else {
      emit(state.copyWith(status: VoteStatus.failureKarmaBelowThreshold));
    }
  }
}
