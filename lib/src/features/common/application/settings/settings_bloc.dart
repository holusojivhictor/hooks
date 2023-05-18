import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'settings_bloc.freezed.dart';
part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
      this._settingsService,
      this._deviceInfoService,
      this._appBloc,) : super(const SettingsState.loading()) {
    on<_Init>(_mapInitToState);
    on<_ThemeChanged>(_mapThemeChangedToState);
    on<_LanguageChanged>(_mapLanguageChangedToState);
    on<_DoubleBackToCloseChanged>(_mapDoubleBackToCloseToState);
    on<_AutoThemeModeTypeChanged>(_mapAutoThemeModeChangedToState);
  }
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final AppBloc _appBloc;

  _LoadedState get currentState => state as _LoadedState;

  Future<void> _mapInitToState(_Init event, Emitter<SettingsState> emit) async {
    final settings = _settingsService.appSettings;

    emit(SettingsState.loaded(
      currentTheme: settings.appTheme,
      currentLanguage: settings.appLanguage,
      appVersion: _deviceInfoService.version,
      doubleBackToClose: settings.doubleBackToClose,
      themeMode: settings.themeMode,
    ),);
  }

  void _mapThemeChangedToState(_ThemeChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.appTheme) {
      return emit(currentState);
    }
    _settingsService.appTheme = event.newValue;
    _appBloc.add(AppEvent.themeChanged(newValue: event.newValue));
    emit(currentState.copyWith.call(currentTheme: event.newValue));
  }

  void _mapLanguageChangedToState(_LanguageChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.language) {
      return emit(currentState);
    }
    _settingsService.language = event.newValue;
    emit(currentState.copyWith.call(currentLanguage: event.newValue));
  }

  void _mapDoubleBackToCloseToState(_DoubleBackToCloseChanged event, Emitter<SettingsState> emit) {
    _settingsService.doubleBackToClose = event.newValue;
    emit(currentState.copyWith.call(doubleBackToClose: event.newValue));
  }

  void _mapAutoThemeModeChangedToState(_AutoThemeModeTypeChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.autoThemeMode) {
      return emit(currentState);
    }
    _settingsService.autoThemeMode = event.newValue;
    _appBloc.add(AppEvent.themeModeChanged(newValue: event.newValue));
    emit(currentState.copyWith.call(themeMode: event.newValue));
  }

  bool get doubleBackToClose => _settingsService.doubleBackToClose;
}
