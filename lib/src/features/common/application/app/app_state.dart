part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.loading() = _AppLoadingState;

  const factory AppState.loaded({
    required String appTitle,
    required AppThemeType theme,
    required AutoThemeModeType autoThemeMode,
    required bool initialized,
    required bool firstInstall,
    required bool versionChanged,
  }) = _AppLoadedState;

  const AppState._();
}
