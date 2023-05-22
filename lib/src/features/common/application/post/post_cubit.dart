import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit(this._postService) : super(const PostState.init());

  final PostService _postService;

  Future<void> post({required String text, required int to}) async {
    emit(state.copyWith(status: PostStatus.loading));
    final success = await _postService.comment(
      parentId: to,
      text: text,
    );

    if (success) {
      emit(state.copyWith(status: PostStatus.successful));
    } else {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<void> edit({required String text, required int id}) async {
    emit(state.copyWith(status: PostStatus.loading));
    final success = await _postService.edit(id: id, text: text);

    if (success) {
      emit(state.copyWith(status: PostStatus.successful));
    } else {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  void reset() {
    emit(state.copyWith(status: PostStatus.init));
  }
}
