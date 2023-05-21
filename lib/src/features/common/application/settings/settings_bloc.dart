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
    this._appBloc,
  ) : super(const SettingsState.loading()) {
    on<_Init>(_onInit);
    on<_ThemeChanged>(_onThemeChanged);
    on<_LanguageChanged>(_onLanguageChanged);
    on<_FetchModeChanged>(_onFetchModeChanged);
    on<_CommentsOrderChanged>(_onCommentsOrderChanged);
    on<_DoubleBackToCloseChanged>(_onDoubleBackToCloseChanged);
    on<_MarkReadStoriesChanged>(_onMarkReadStoriesChanged);
    on<_ComplexStoryTileChanged>(_onComplexStoryTileChanged);
    on<_ShowMetadataChanged>(_onShowMetadataChanged);
    on<_ShowUrlChanged>(_onShowUrlChanged);
    on<_AutoThemeModeTypeChanged>(_onAutoThemeModeTypeChanged);
  }
  final SettingsService _settingsService;
  final DeviceInfoService _deviceInfoService;
  final AppBloc _appBloc;

  _LoadedState get currentState => state as _LoadedState;

  Future<void> _onInit(_Init event, Emitter<SettingsState> emit) async {
    final settings = _settingsService.appSettings;

    emit(
      SettingsState.loaded(
        currentTheme: settings.appTheme,
        currentLanguage: settings.appLanguage,
        fetchMode: settings.fetchMode,
        commentsOrder: settings.commentsOrder,
        appVersion: _deviceInfoService.version,
        doubleBackToClose: settings.doubleBackToClose,
        markReadStories: settings.markReadStories,
        complexStoryTile: settings.complexStoryTile,
        showMetadata: settings.showMetadata,
        showUrl: settings.showUrl,
        themeMode: settings.themeMode,
      ),
    );
  }

  void _onThemeChanged(_ThemeChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.appTheme) {
      return emit(currentState);
    }
    _settingsService.appTheme = event.newValue;
    _appBloc.add(AppEvent.themeChanged(newValue: event.newValue));
    emit(currentState.copyWith.call(currentTheme: event.newValue));
  }

  void _onLanguageChanged(_LanguageChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.language) {
      return emit(currentState);
    }
    _settingsService.language = event.newValue;
    emit(currentState.copyWith.call(currentLanguage: event.newValue));
  }

  void _onFetchModeChanged(_FetchModeChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.fetchMode) {
      return emit(currentState);
    }
    _settingsService.fetchMode = event.newValue;
    emit(currentState.copyWith.call(fetchMode: event.newValue));
  }

  void _onCommentsOrderChanged(_CommentsOrderChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.commentsOrder) {
      return emit(currentState);
    }
    _settingsService.commentsOrder = event.newValue;
    emit(currentState.copyWith.call(commentsOrder: event.newValue));
  }

  void _onDoubleBackToCloseChanged(_DoubleBackToCloseChanged event, Emitter<SettingsState> emit) {
    _settingsService.doubleBackToClose = event.newValue;
    emit(currentState.copyWith.call(doubleBackToClose: event.newValue));
  }

  void _onMarkReadStoriesChanged(_MarkReadStoriesChanged event, Emitter<SettingsState> emit) {
    _settingsService.markReadStories = event.newValue;
    emit(currentState.copyWith.call(markReadStories: event.newValue));
  }

  void _onComplexStoryTileChanged(_ComplexStoryTileChanged event, Emitter<SettingsState> emit) {
    _settingsService.complexStoryTile = event.newValue;
    emit(currentState.copyWith.call(complexStoryTile: event.newValue));
  }

  void _onShowMetadataChanged(_ShowMetadataChanged event, Emitter<SettingsState> emit) {
    _settingsService.showMetadata = event.newValue;
    emit(currentState.copyWith.call(showMetadata: event.newValue));
  }

  void _onShowUrlChanged(_ShowUrlChanged event, Emitter<SettingsState> emit) {
    _settingsService.showUrl = event.newValue;
    emit(currentState.copyWith.call(showUrl: event.newValue));
  }

  void _onAutoThemeModeTypeChanged(_AutoThemeModeTypeChanged event, Emitter<SettingsState> emit) {
    if (event.newValue == _settingsService.autoThemeMode) {
      return emit(currentState);
    }
    _settingsService.autoThemeMode = event.newValue;
    _appBloc.add(AppEvent.themeModeChanged(newValue: event.newValue));
    emit(currentState.copyWith.call(themeMode: event.newValue));
  }

  bool get doubleBackToClose => _settingsService.doubleBackToClose;

  FetchMode get fetchMode => _settingsService.fetchMode;

  CommentsOrder get order => _settingsService.commentsOrder;
}
