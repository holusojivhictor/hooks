import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

part 'stories_bloc.freezed.dart';
part 'stories_event.dart';
part 'stories_state.dart';

class StoriesBloc extends Bloc<StoriesEvent, StoriesState> {
  StoriesBloc(
    this._storiesService,
    this._settingsService,
    this._filterCubit,
  ) : super(const StoriesState.init()) {
    on<_Init>(_onInit);
    on<_Refresh>(_onRefresh);
    on<_LoadMore>(_onLoadMore);
    on<_StoryLoaded>(_onStoryLoaded);
    on<_StoriesLoaded>(_onStoriesLoaded);
    on<_PageSizeChanged>(_onPageSizeChanged);
    on<_StoryRead>(_onStoryRead);
    on<_ClearAllReadStories>(_onClearAllReadStories);
  }

  final StoriesService _storiesService;
  final SettingsService _settingsService;
  final FilterCubit _filterCubit;
  static const int _smallPageSize = 10;

  Future<void> _onInit(_Init event, Emitter<StoriesState> emit) async {
    emit(const StoriesState.init().copyWith(
      currentPageSize: _smallPageSize,
    ),);
    for (final type in StoryType.values) {
      await _loadStories(type: type, emit: emit);
    }
  }

  Future<void> _loadStories({
    required StoryType type,
    required Emitter<StoriesState> emit,
  }) async {
    final ids = await _storiesService.fetchStoryIds(type: type);
    emit(
      state
          .copyWithStoryIdsUpdated(type: type, to: ids)
          .copyWithCurrentPageUpdated(type: type, to: 0),
    );
    _storiesService
        .fetchStoriesStream(ids: ids.sublist(0, state.currentPageSize))
        .listen((Story story) => add(StoriesEvent.storyLoaded(story: story, type: type)))
        .onDone(() => add(StoriesEvent.storiesLoaded(type: type)));
  }

  Future<void> _onRefresh(_Refresh event, Emitter<StoriesState> emit) async {
    emit(state.copyWithStatusUpdated(type: event.type, to: StoriesStatus.loading));

    emit(state.copyWithRefreshed(type: event.type));
    await _loadStories(type: event.type, emit: emit);
  }

  void _onLoadMore(_LoadMore event, Emitter<StoriesState> emit) {
    emit(state.copyWithStatusUpdated(type: event.type, to: StoriesStatus.loading));

    final currentPage = state.currentPageByType[event.type]!;
    final len = state.storyIdsByType[event.type]!.length;
    emit(state.copyWithCurrentPageUpdated(type: event.type, to: currentPage + 1));

    final currentPageSize = state.currentPageSize;
    final lower = currentPageSize * (currentPage + 1);
    var upper = currentPageSize + lower;

    if (len > lower) {
      if (len < upper) {
        upper = len;
      }

      _storiesService
          .fetchStoriesStream(ids: state.storyIdsByType[event.type]!.sublist(lower, upper))
          .listen((Story story) => add(StoriesEvent.storyLoaded(story: story, type: event.type)))
          .onDone(() => add(StoriesEvent.storiesLoaded(type: event.type)));
    } else {
      emit(state.copyWithStatusUpdated(type: event.type, to: StoriesStatus.loaded));
    }
  }

  void _onStoryLoaded(_StoryLoaded event, Emitter<StoriesState> emit) {
    final hasRead = _settingsService.hasRead(event.story.id);
    final hidden = _filterCubit.state.keywords.any(
      (String keyword) =>
          event.story.title.toLowerCase().contains(keyword) ||
          event.story.text.toLowerCase().contains(keyword),
    );
    emit(
      state.copyWithStoryAdded(
        type: event.type,
        story: event.story.copyWith(hidden: hidden),
        hasRead: hasRead,
      ),
    );
  }

  void _onStoriesLoaded(_StoriesLoaded event, Emitter<StoriesState> emit) {
    emit(state.copyWithStatusUpdated(type: event.type, to: StoriesStatus.loaded));
  }

  void _onPageSizeChanged(_PageSizeChanged event, Emitter<StoriesState> emit) {
    add(const StoriesEvent.init());
  }

  void _onStoryRead(_StoryRead event, Emitter<StoriesState> emit) {
    _settingsService.updateHasRead(event.story.id);

    emit(state.copyWith(
      readStoriesIds: <int>{...state.readStoriesIds, event.story.id},
    ),);
  }

  void _onClearAllReadStories(_ClearAllReadStories event, Emitter<StoriesState> emit) {
    _settingsService.clearAllReadStories();

    emit(state.copyWith(readStoriesIds: <int>{},));
  }

  bool hasRead(Story story) => state.readStoriesIds.contains(story.id);
}
