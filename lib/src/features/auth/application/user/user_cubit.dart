import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit(this._storiesService) : super(const UserState.init());

  final StoriesService _storiesService;

  void init({required String userId}) {
    emit(state.copyWith(status: UserStatus.loading));
    _storiesService.fetchUser(id: userId).then((User? user) {
      emit(
        state.copyWith(
          user: user ?? User.emptyWithId(userId),
          status: UserStatus.loaded,
        ),
      );
    }).onError((_, __) {
      emit(state.copyWith(status: UserStatus.failure));
      return;
    });
  }
}
