part of 'settings_bloc.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState.loading() = _LoadingState;

  const factory SettingsState.loaded({
    required AppThemeType currentTheme,
    required AppLanguageType currentLanguage,
    required String appVersion,
    required bool doubleBackToClose,
    required bool markReadStories,
    required bool complexStoryTile,
    required bool showMetadata,
    required bool showUrl,
    required AutoThemeModeType themeMode,
  }) = _LoadedState;
}
