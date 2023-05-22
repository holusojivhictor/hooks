import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';

part 'collapse_state.dart';

class CollapseCubit extends Cubit<CollapseState> {
  CollapseCubit(
    this._collapseCache, {
    required int commentId,
  })  : _commentId = commentId,
        super(const CollapseState.init());

  final CollapseCache _collapseCache;
  final int _commentId;

  late final StreamSubscription<Map<int, Set<int>>> _streamSubscription;

  void init() {
    _streamSubscription = _collapseCache.hiddenComments.listen(hiddenCommentsStreamListener);

    emit(
      state.copyWith(
        collapsedCount: _collapseCache.totalHidden(_commentId),
        collapsed: _collapseCache.isCollapsed(_commentId),
        hidden: _collapseCache.isHidden(_commentId),
      ),
    );
  }

  void collapse() {
    if (state.collapsed) {
      _collapseCache.uncollapse(_commentId);

      emit(state.copyWith(collapsed: false, collapsedCount: 0));
    } else {
      final collapsedCommentIds = _collapseCache.collapse(_commentId);

      emit(
        state.copyWith(
          collapsed: true,
          collapsedCount: state.collapsed ? 0 : collapsedCommentIds.length,
        ),
      );
    }
  }

  void hiddenCommentsStreamListener(Map<int, Set<int>> event) {
    var collapsedCount = 0;
    for (final key in event.keys) {
      if (key == _commentId && !isClosed) {
        collapsedCount = event[key]?.length ?? 0;
        break;
      }
    }

    for (final val in event.values) {
      if (val.contains(_commentId) && !isClosed) {
        emit(state.copyWith(hidden: true, collapsedCount: collapsedCount));
        return;
      }
    }

    if (!isClosed) {
      emit(state.copyWith(hidden: false, collapsedCount: collapsedCount));
    }
  }

  @override
  Future<void> close() async {
    await _streamSubscription.cancel();
    await super.close();
  }
}
