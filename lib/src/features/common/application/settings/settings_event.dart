part of 'settings_bloc.dart';

@freezed
class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.init() = _Init;

  const factory SettingsEvent.themeChanged({
    required AppThemeType newValue,
  }) = _ThemeChanged;

  const factory SettingsEvent.languageChanged({
    required AppLanguageType newValue,
  }) = _LanguageChanged;

  const factory SettingsEvent.fetchModeChanged({
    required FetchMode newValue,
  }) = _FetchModeChanged;

  const factory SettingsEvent.commentsOrderChanged({
    required CommentsOrder newValue,
  }) = _CommentsOrderChanged;

  const factory SettingsEvent.doubleBackToCloseChanged({
    required bool newValue,
  }) = _DoubleBackToCloseChanged;

  const factory SettingsEvent.markReadStoriesChanged({
    required bool newValue,
  }) = _MarkReadStoriesChanged;

  const factory SettingsEvent.complexStoryTileChanged({
    required bool newValue,
  }) = _ComplexStoryTileChanged;

  const factory SettingsEvent.showMetadataChanged({
    required bool newValue,
  }) = _ShowMetadataChanged;

  const factory SettingsEvent.showUrlChanged({
    required bool newValue,
  }) = _ShowUrlChanged;

  const factory SettingsEvent.autoThemeModeTypeChanged({
    required AutoThemeModeType newValue,
  }) = _AutoThemeModeTypeChanged;
}
