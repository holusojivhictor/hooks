part of 'stories_bloc.dart';

@freezed
class StoriesEvent with _$StoriesEvent {
  const factory StoriesEvent.init() = _Init;

  const factory StoriesEvent.storiesLoaded({
    required StoryType type,
  }) = _StoriesLoaded;

  const factory StoriesEvent.refresh({
    required StoryType type,
  }) = _Refresh;

  const factory StoriesEvent.loadMore({
    required StoryType type,
  }) = _LoadMore;

  const factory StoriesEvent.pageSizeChanged({
    required int pageSize,
  }) = _PageSizeChanged;

  const factory StoriesEvent.storyLoaded({
    required Story story,
    required StoryType type,
  }) = _StoryLoaded;

  const factory StoriesEvent.storyRead({
    required Story story,
  }) = _StoryRead;

  const factory StoriesEvent.clearAllReadStories() = _ClearAllReadStories;
}
