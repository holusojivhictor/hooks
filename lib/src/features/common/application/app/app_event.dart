part of 'app_bloc.dart';

@freezed
class AppEvent with _$AppEvent {
  const factory AppEvent.init() = _Init;

  const factory AppEvent.themeChanged({
    required AppThemeType newValue,
  }) = _ThemeChanged;

  const factory AppEvent.themeModeChanged({
    required AutoThemeModeType newValue,
  }) = _ThemeModeChanged;
}
