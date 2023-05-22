import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'app_bloc.freezed.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc(
    this._logger,
    this._settingsService,
    this._deviceInfoService,
  ) : super(const _AppLoadingState()) {
    on<_Init>(_onInit);
    on<_ThemeChanged>(_onThemeChanged);
    on<_ThemeModeChanged>(_onThemeModeChanged);
    on<_UseDarkAmoledChanged>(_onUseDarkAmoledChanged);
  }

  final LoggingService _logger;
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;

  AppState _loadedState(
    AppThemeType theme,
    AutoThemeModeType autoThemeMode,
    bool useDarkAmoled, {
    bool isInitialized = true,
  }) {
    return AppState.loaded(
      appTitle: _deviceInfoService.appName,
      initialized: isInitialized,
      theme: theme,
      autoThemeMode: autoThemeMode,
      useDarkAmoled: useDarkAmoled,
      firstInstall: _settingsService.isFirstInstall,
      versionChanged: _deviceInfoService.versionChanged,
    );
  }

  void _logInfo() {
    _logger.info(
        runtimeType,
        '_init: Is first install = ${_settingsService.isFirstInstall}'
        'Refreshing settings');
  }

  void _onInit(_Init event, Emitter<AppState> emit, {bool init = true}) {
    _logger.info(runtimeType, '_init: Initializing all...');

    final settings = _settingsService.appSettings;

    _logInfo();

    final state = _loadedState(
      settings.appTheme,
      settings.themeMode,
      settings.useDarkAmoled,
      isInitialized: init,
    );

    emit(state);
  }

  void _onThemeChanged(_ThemeChanged event, Emitter<AppState> emit) {
    _logInfo();

    emit(
      _loadedState(
        event.newValue,
        _settingsService.autoThemeMode,
        _settingsService.useDarkAmoled,
      ),
    );
  }

  void _onThemeModeChanged(_ThemeModeChanged event, Emitter<AppState> emit) {
    _logInfo();

    emit(
      _loadedState(
        _settingsService.appTheme,
        event.newValue,
        _settingsService.useDarkAmoled,
      ),
    );
  }

  void _onUseDarkAmoledChanged(
    _UseDarkAmoledChanged event,
    Emitter<AppState> emit,
  ) {
    _logInfo();

    emit(
      _loadedState(
        _settingsService.appTheme,
        _settingsService.autoThemeMode,
        event.newValue,
      ),
    );
  }
}
