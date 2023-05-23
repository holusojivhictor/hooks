import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../mocks.dart';

void main() {
  const defaultAppName = 'Hooks';
  const defaultFetchMode = FetchMode.eager;
  const defaultOrder = CommentsOrder.natural;
  const defaultLang = AppLanguageType.english;
  const defaultThemeMode = AutoThemeModeType.off;
  const defaultTheme = AppThemeType.dark;

  final defaultAppSettings = AppSettings(
    appTheme: defaultTheme,
    appLanguage: defaultLang,
    fetchMode: defaultFetchMode,
    commentsOrder: defaultOrder,
    themeMode: defaultThemeMode,
    isFirstInstall: true,
    doubleBackToClose: true,
    useDarkAmoled: false,
    markReadStories: true,
    complexStoryTile: true,
    tapAnywhereToCollapse: true,
    showMetadata: true,
    showUrl: true,
  );

  AppBloc appBloc({
    String appName = defaultAppName,
    AppSettings? appSettings,
    bool versionChanged = false,
  }) {
    final settings = appSettings ?? defaultAppSettings;
    final logger = MockLoggingService();

    final settingsService = MockSettingsService();
    when(() => settingsService.language).thenReturn(settings.appLanguage);
    when(() => settingsService.autoThemeMode).thenReturn(settings.themeMode);
    when(() => settingsService.appTheme).thenReturn(settings.appTheme);
    when(() => settingsService.useDarkAmoled).thenReturn(settings.useDarkAmoled);
    when(() => settingsService.isFirstInstall).thenReturn(settings.isFirstInstall);
    when(() =>settingsService.appSettings).thenReturn(settings);

    final deviceInfoService = MockDeviceInfoService();
    when(() => deviceInfoService.appName).thenReturn(appName);
    when(() => deviceInfoService.versionChanged).thenReturn(versionChanged);

    return AppBloc(
      logger,
      settingsService,
      deviceInfoService,
    );
  }

  test('Initial state', () {
    expect(appBloc().state, const AppState.loading());
  });

  group('Init', () {
    blocTest<AppBloc, AppState>(
      'emits init state',
      build: appBloc,
      act: (bloc) => bloc.add(const AppEvent.init()),
      expect: () => <AppState>[
        AppState.loaded(
          appTitle: defaultAppName,
          theme: defaultTheme,
          autoThemeMode: defaultThemeMode,
          useDarkAmoled: false,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );
  });

  group('Theme changed', () {
    blocTest<AppBloc, AppState>(
      'updates the theme mode in AppState',
      build: appBloc,
      act: (bloc) => bloc
        ..add(const AppEvent.init())
        ..add(const AppEvent.themeModeChanged(newValue: AutoThemeModeType.on)),
      skip: 1,
      expect: () => <AppState>[
        AppState.loaded(
          appTitle: defaultAppName,
          theme: defaultAppSettings.appTheme,
          autoThemeMode: AutoThemeModeType.on,
          useDarkAmoled: false,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'updates the theme in AppState',
      build: appBloc,
      act: (bloc) => bloc
        ..add(const AppEvent.init())
        ..add(const AppEvent.themeChanged(newValue: AppThemeType.light)),
      skip: 1,
      expect: () => <AppState>[
        AppState.loaded(
          appTitle: defaultAppName,
          theme: AppThemeType.light,
          autoThemeMode: defaultThemeMode,
          useDarkAmoled: false,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'updates useDarkAmoled in AppState',
      build: appBloc,
      act: (bloc) => bloc
        ..add(const AppEvent.init())
        ..add(const AppEvent.useDarkAmoledChanged(newValue: true)),
      skip: 1,
      expect: () => <AppState>[
        AppState.loaded(
          appTitle: defaultAppName,
          theme: defaultTheme,
          autoThemeMode: defaultThemeMode,
          useDarkAmoled: true,
          initialized: true,
          firstInstall: defaultAppSettings.isFirstInstall,
          versionChanged: false,
        ),
      ],
    );
  });
}
