import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/routing/app_router.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:linkify/linkify.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

part 'comments_state.dart';

class CommentsCubit extends Cubit<CommentsState> {
  CommentsCubit(
    this._storiesService,
    this._dataService,
    this._logger, this._commentCache, {
    required FilterCubit filterCubit,
    required CollapseCache collapseCache,
    required Item item,
    required FetchMode defaultFetchMode,
    required CommentsOrder defaultCommentsOrder,
  })  : _filterCubit = filterCubit,
        _collapseCache = collapseCache,
        super(
          CommentsState.init(
            item: item,
            fetchMode: defaultFetchMode,
            order: defaultCommentsOrder,
          ),
        );

  final StoriesService _storiesService;
  final DataService _dataService;
  final LoggingService _logger;
  final CommentCache _commentCache;
  final CollapseCache _collapseCache;
  final FilterCubit _filterCubit;

  StreamSubscription<Comment>? _streamSubscription;

  final Map<int, StreamSubscription<Comment>> _streamSubscriptions =
      <int, StreamSubscription<Comment>>{};

  @override
  void emit(CommentsState state) {
    if (!isClosed) {
      super.emit(state);
    }
  }

  Future<void> init({
    bool onlyShowTargetComment = false,
    bool useCommentCache = false,
    List<Comment>? targetAncestors,
  }) async {
    if (onlyShowTargetComment && (targetAncestors?.isNotEmpty ?? false)) {
      emit(
        state.copyWith(
          comments: targetAncestors,
          onlyShowTargetComment: true,
          status: CommentsStatus.allLoaded,
        ),
      );

      _streamSubscription = _storiesService
          .fetchAllCommentsRecursivelyStream(
            ids: targetAncestors!.last.kids,
            level: targetAncestors.last.level + 1,
          )
          .asyncMap(_toBuildableComment)
          .whereNotNull()
          .listen(_onCommentFetched)..onDone(_onDone);

      return;
    }

    emit(
      state.copyWith(
        status: CommentsStatus.loading,
        comments: <Comment>[],
        currentPage: 0,
      ),
    );

    final item = state.item;
    final updatedItem =
        await _storiesService.fetchItem(id: item.id).then(_toBuildable) ?? item;
    final kids = _sortKids(updatedItem.kids);

    emit(state.copyWith(item: updatedItem));

    late final Stream<Comment> commentStream;

    switch (state.fetchMode) {
      case FetchMode.lazy:
        commentStream = _storiesService.fetchCommentsStream(
          ids: kids,
          getFromCache: useCommentCache ? _commentCache.getComment : null,
        );
      case FetchMode.eager:
        commentStream = _storiesService.fetchAllCommentsRecursivelyStream(
          ids: kids,
          getFromCache: useCommentCache ? _commentCache.getComment : null,
        );
    }

    _streamSubscription = commentStream
        .asyncMap(_toBuildableComment)
        .whereNotNull()
        .listen(_onCommentFetched)..onDone(_onDone);
  }

  Future<void> refresh() async {
    emit(
      state.copyWith(
        status: CommentsStatus.loading,
      ),
    );

    _collapseCache.resetCollapsedComments();

    await _streamSubscription?.cancel();
    for (final id in _streamSubscriptions.keys) {
      await _streamSubscriptions[id]?.cancel();
    }
    _streamSubscriptions.clear();

    emit(
      state.copyWith(
        comments: <Comment>[],
        currentPage: 0,
      ),
    );

    final item = state.item;
    final updatedItem = await _storiesService.fetchItem(id: item.id) ?? item;
    final kids = _sortKids(updatedItem.kids);

    late final Stream<Comment> commentStream;
    if (state.fetchMode == FetchMode.lazy) {
      commentStream = _storiesService.fetchCommentsStream(
        ids: kids,
      );
    } else {
      commentStream = _storiesService.fetchAllCommentsRecursivelyStream(
        ids: kids,
      );
    }

    _streamSubscription = commentStream
        .asyncMap(_toBuildableComment)
        .whereNotNull()
        .listen(_onCommentFetched)..onDone(_onDone);

    emit(
      state.copyWith(
        item: updatedItem,
      ),
    );
  }

  void loadAll(Story story) {
    HapticFeedback.lightImpact();
    emit(
      state.copyWith(
        onlyShowTargetComment: false,
        item: story,
      ),
    );
    init();
  }

  void loadMore({
    Comment? comment,
    void Function(Comment)? onCommentFetched,
    VoidCallback? onDone,
  }) {
    if (comment == null && state.status == CommentsStatus.loading) return;

    switch (state.fetchMode) {
      case FetchMode.lazy:
        if (comment == null) return;
        if (_streamSubscriptions.containsKey(comment.id)) return;

        final level = comment.level + 1;
        var offset = 0;

        // ignore: cancel_subscriptions
        final StreamSubscription<Comment> streamSubscription = _storiesService
            .fetchCommentsStream(ids: comment.kids)
            .asyncMap(_toBuildableComment)
            .whereNotNull()
            .listen((Comment cmt) {
          _collapseCache.addKid(cmt.id, to: cmt.parent);
          _commentCache.cacheComment(cmt);
          _dataService.cacheComment(cmt);

          emit(
            state.copyWith(
              comments: <Comment>[...state.comments]..insert(
                  state.comments.indexOf(comment) + offset + 1,
                  cmt.copyWith(level: level),
                ),
            ),
          );
          offset++;
        })
          ..onDone(() {
            _streamSubscriptions[comment.id]?.cancel();
            _streamSubscriptions.remove(comment.id);
          })
          ..onError((dynamic error) {
            _logger.error(runtimeType, error.toString());
            _streamSubscriptions[comment.id]?.cancel();
            _streamSubscriptions.remove(comment.id);
          });

        _streamSubscriptions[comment.id] = streamSubscription;
      case FetchMode.eager:
        if (_streamSubscription != null) {
          emit(state.copyWith(status: CommentsStatus.loading));
          _streamSubscription
            ?..resume()
            ..onData(onCommentFetched);
        }
    }
  }

  Future<void> loadParentThread() async {
    unawaited(HapticFeedback.lightImpact());
    emit(state.copyWith(fetchParentStatus: CommentsStatus.loading));
    final parent = await _storiesService.fetchItem(id: state.item.parent);

    if (parent == null) {
      return;
    } else {
      await AppRouter.router.pushNamed(
        AppRoute.item.name,
        extra: ItemPageArgs(item: parent),
      );

      emit(
        state.copyWith(
          fetchParentStatus: CommentsStatus.loaded,
        ),
      );
    }
  }

  Future<void> loadRootThread() async {
    unawaited(HapticFeedback.lightImpact());
    emit(state.copyWith(fetchRootStatus: CommentsStatus.loading));
    final parent = await _storiesService
        .fetchParentStory(id: state.item.id)
        .then(_toBuildableStory);

    if (parent == null) {
      return;
    } else {
      await AppRouter.router.pushNamed(
        AppRoute.item.name,
        extra: ItemPageArgs(item: parent),
      );

      emit(
        state.copyWith(
          fetchRootStatus: CommentsStatus.loaded,
        ),
      );
    }
  }

  void onOrderChanged(CommentsOrder? order) {
    if (order == null) return;
    if (state.order == order) return;
    HapticFeedback.selectionClick();
    _streamSubscription?.cancel();
    for (final s in _streamSubscriptions.values) {
      s.cancel();
    }
    _streamSubscriptions.clear();
    emit(state.copyWith(order: order));
    init(useCommentCache: true);
  }

  void onFetchModeChanged(FetchMode? fetchMode) {
    if (fetchMode == null) return;
    if (state.fetchMode == fetchMode) return;
    _collapseCache.resetCollapsedComments();
    HapticFeedback.selectionClick();
    _streamSubscription?.cancel();
    for (final s in _streamSubscriptions.values) {
      s.cancel();
    }
    _streamSubscriptions.clear();
    emit(state.copyWith(fetchMode: fetchMode));
    init(useCommentCache: true);
  }

  void jump(
    ItemScrollController itemScrollController,
    ItemPositionsListener itemPositionsListener,
  ) {
    final totalComments = state.comments.length;
    final onScreenComments = itemPositionsListener.itemPositions.value
        .where((ItemPosition e) => e.index >= 1 && e.itemLeadingEdge < 0.7)
        .sorted((ItemPosition a, ItemPosition b) => a.index.compareTo(b.index))
        .map((ItemPosition e) => e.index <= state.comments.length
              ? state.comments.elementAt(e.index - 1)
              : null,
        ).whereNotNull().toList();

    final lastVisibleIndex = state.comments.indexOf(onScreenComments.last);
    final int startIndex = min(lastVisibleIndex + 1, totalComments);

    for (var i = startIndex; i < totalComments; i++) {
      final cmt = state.comments.elementAt(i);

      if (cmt.isRoot && (cmt.deleted || cmt.dead) == false) {
        itemScrollController.scrollTo(
          index: i + 1,
          alignment: 0.15,
          duration: const Duration(milliseconds: 400),
        );
        return;
      }
    }
  }

  void jumpUp(
    ItemScrollController itemScrollController,
    ItemPositionsListener itemPositionsListener,
  ) {
    final onScreenComments = itemPositionsListener.itemPositions.value
        .where((ItemPosition e) => e.index >= 1 && e.itemLeadingEdge > 0)
        .sorted((ItemPosition a, ItemPosition b) => a.index.compareTo(b.index))
        .map((ItemPosition e) => e.index <= state.comments.length
              ? state.comments.elementAt(e.index - 1)
              : null,
        ).whereNotNull().toList();

    final firstVisibleIndex = state.comments.indexOf(
      onScreenComments.firstOrNull ?? state.comments.last,
    );
    final int startIndex = max(0, firstVisibleIndex - 1);

    for (var i = startIndex; i >= 0; i--) {
      final cmt = state.comments.elementAt(i);

      if (cmt.isRoot && (cmt.deleted || cmt.dead) == false) {
        itemScrollController.scrollTo(
          index: i + 1,
          alignment: 0.15,
          duration: const Duration(milliseconds: 400),
        );
        return;
      }
    }
  }

  List<int> _sortKids(List<int> kids) {
    switch (state.order) {
      case CommentsOrder.natural:
        return kids;
      case CommentsOrder.newestFirst:
        return kids.sorted((int a, int b) => b.compareTo(a));
      case CommentsOrder.oldestFirst:
        return kids.sorted((int a, int b) => a.compareTo(b));
    }
  }

  void _onDone() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    emit(
      state.copyWith(
        status: CommentsStatus.allLoaded,
      ),
    );
  }

  void _onCommentFetched(BuildableComment? comment) {
    if (comment != null) {
      _collapseCache.addKid(comment.id, to: comment.parent);
      _commentCache.cacheComment(comment);
      _dataService.cacheComment(comment);

      final hidden = _filterCubit.state.keywords.any(
        (String keyword) => comment.text.toLowerCase().contains(keyword),
      );

      final updatedComments = <Comment>[
        ...state.comments,
        comment.copyWith(hidden: hidden),
      ];

      emit(state.copyWith(comments: updatedComments));
    }
  }

  static Future<Item?> _toBuildable(Item? item) async {
    if (item == null) return null;

    switch (item.runtimeType) {
      case Comment:
        return _toBuildableComment(item as Comment);
      case Story:
        return _toBuildableStory(item as Story);
    }

    return null;
  }

  static Future<BuildableComment?> _toBuildableComment(Comment? comment) async {
    if (comment == null) return null;

    final elements = await compute<String, List<LinkifyElement>>(
      LinkifierUtils.linkify,
      comment.text,
    );

    final buildableComment =
        BuildableComment.fromComment(comment, elements: elements);

    return buildableComment;
  }

  static Future<BuildableStory?> _toBuildableStory(Story? story) async {
    if (story == null) {
      return null;
    } else if (story.text.isEmpty) {
      return BuildableStory.fromTitleOnlyStory(story);
    }

    final elements = await compute<String, List<LinkifyElement>>(
      LinkifierUtils.linkify,
      story.text,
    );

    final buildableStory = BuildableStory.fromStory(story, elements: elements);

    return buildableStory;
  }

  @override
  Future<void> close() async {
    await _streamSubscription?.cancel();
    for (final s in _streamSubscriptions.values) {
      await s.cancel();
    }
    await super.close();
  }
}
