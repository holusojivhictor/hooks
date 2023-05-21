import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';

part 'time_machine_state.dart';

class TimeMachineCubit extends Cubit<TimeMachineState> {
  TimeMachineCubit({
    DataService? dataService,
    CommentCache? commentCache,
  })  : _dataService = dataService ?? getIt<DataService>(),
        _commentCache = commentCache ?? getIt<CommentCache>(),
        super(TimeMachineState.init());

  final DataService _dataService;
  final CommentCache _commentCache;

  Future<void> activateTimeMachine(Comment comment) async {
    emit(state.copyWith(ancestors: <Comment>[]));

    final ancestors = <Comment>[];
    var parent = _commentCache.getComment(comment.parent);
    parent ??= await _dataService.getCachedComment(id: comment.parent);

    while (parent != null) {
      ancestors.insert(0, parent);

      final parentId = parent.parent;
      parent = _commentCache.getComment(parentId);
      parent ??= await _dataService.getCachedComment(id: parentId);
    }

    emit(state.copyWith(ancestors: ancestors));
  }
}
