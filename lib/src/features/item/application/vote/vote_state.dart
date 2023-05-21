part of 'vote_cubit.dart';

enum Vote {
  up,
  down,
}

enum VoteStatus {
  initial,
  canceled,
  submitted,
  failureBeHumble,
  failureNotLoggedIn,
  failureKarmaBelowThreshold,
  failure,
}

class VoteState extends Equatable {
  const VoteState({
    required this.vote,
    required this.item,
    required this.status,
  });

  const VoteState.init({required this.item})
      : vote = null,
        status = VoteStatus.initial;

  final Vote? vote;

  final Item item;

  final VoteStatus status;

  VoteState copyWith({
    Vote? vote,
    Item? item,
    VoteStatus? status,
  }) {
    return VoteState(
      vote: vote ?? this.vote,
      item: item ?? this.item,
      status: status ?? this.status,
    );
  }

  VoteState copyWithVoteRemoved({
    Item? item,
    VoteStatus? status,
  }) {
    return VoteState(
      vote: null,
      item: item ?? this.item,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    vote,
    item,
    status,
  ];
}
