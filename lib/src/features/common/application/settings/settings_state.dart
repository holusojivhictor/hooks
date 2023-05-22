part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = _LoadingState;

  const factory SettingsState.loaded({
    required AppThemeType currentTheme,
    required AppLanguageType currentLanguage,
    required FetchMode fetchMode,
    required CommentsOrder commentsOrder,
    required String appVersion,
    required bool doubleBackToClose,
    required bool useDarkAmoled,
    required bool markReadStories,
    required bool complexStoryTile,
    required bool tapAnywhereToCollapse,
    required bool showMetadata,
    required bool showUrl,
    required AutoThemeModeType themeMode,
  }) = _LoadedState;
}
