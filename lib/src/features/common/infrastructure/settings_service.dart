import 'package:collection/collection.dart' show IterableExtension;
import 'package:devicelocale/devicelocale.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this._logger);

  final _appThemeKey = 'AppTheme';
  final _appLanguageKey = 'AppLanguage';
  final _isFirstInstallKey = 'FirstInstall';
  final _doubleBackToCloseKey = 'DoubleBackToClose';
  final _autoThemeModeKey = 'AutoThemeMode';
  final _markReadStoriesKey = 'MarkReadStories';
  final _complexStoryTileKey = 'ComplexStoryTile';
  final _filterKeywordsKey = 'FilterKeywords';

  bool _initialized = false;

  late SharedPreferences _prefs;
  final LoggingService _logger;

  AppThemeType get appTheme => AppThemeType.values[_prefs.getInt(_appThemeKey)!];

  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)!];

  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  bool get isFirstInstall => _prefs.getBool(_isFirstInstallKey)!;

  set isFirstInstall(bool itIs) => _prefs.setBool(_isFirstInstallKey, itIs);

  bool get doubleBackToClose => _prefs.getBool(_doubleBackToCloseKey)!;

  set doubleBackToClose(bool value) => _prefs.setBool(_doubleBackToCloseKey, value);

  bool get markReadStories => _prefs.getBool(_markReadStoriesKey)!;

  set markReadStories(bool value) => _prefs.setBool(_markReadStoriesKey, value);

  bool get complexStoryTile => _prefs.getBool(_complexStoryTileKey)!;

  set complexStoryTile(bool value) => _prefs.setBool(_complexStoryTileKey, value);

  AutoThemeModeType get autoThemeMode => AutoThemeModeType.values[_prefs.getInt(_autoThemeModeKey)!];

  set autoThemeMode(AutoThemeModeType themeMode) => _prefs.setInt(_autoThemeModeKey, themeMode.index);

  AppSettings get appSettings => AppSettings(
    appTheme: appTheme,
    appLanguage: language,
    useDarkMode: false,
    isFirstInstall: isFirstInstall,
    doubleBackToClose: doubleBackToClose,
    markReadStories: markReadStories,
    complexStoryTile: complexStoryTile,
    themeMode: autoThemeMode,
  );

  Future<void> init() async {
    if (_initialized) {
      _logger.info(runtimeType, 'Settings are already initialized!');
      return;
    }

    _logger.info(runtimeType, 'Initializing settings...Getting shared preferences instance...');

    _prefs = await SharedPreferences.getInstance();

    if (_prefs.get(_isFirstInstallKey) == null) {
      _logger.info(runtimeType, 'This is the first install of the app');
      isFirstInstall = true;
    } else {
      isFirstInstall = false;
    }

    if (_prefs.get(_appThemeKey) == null) {
      _logger.info(runtimeType, 'Setting light as the default theme');
      appTheme = AppThemeType.light;
    }

    if (_prefs.get(_appLanguageKey) == null) {
      language = await _getDefaultLangToUse();
    }

    if (_prefs.get(_doubleBackToCloseKey) == null) {
      _logger.info(runtimeType, 'Double back to close will be set to its default (true)');
      doubleBackToClose = true;
    }

    if (_prefs.get(_markReadStoriesKey) == null) {
      _logger.info(runtimeType, 'Mark read stories will be set to its default (true)');
      markReadStories = true;
    }

    if (_prefs.get(_complexStoryTileKey) == null) {
      _logger.info(runtimeType, 'Complex story tile will be set to its default (true)');
      complexStoryTile = true;
    }

    if (_prefs.get(_autoThemeModeKey) == null) {
      _logger.info(runtimeType, 'Auto theme mode set to false as default');
      autoThemeMode = AutoThemeModeType.off;
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }

  bool hasRead(int storyId) {
    final key = _getHasReadKey(storyId);
    final val = _prefs.getBool(key);

    if (val == null) return false;

    return true;
  }

  List<String> get filterKeywords => _prefs.getStringList(_filterKeywordsKey) ?? <String>[];

  void updateFilterKeywords(List<String> keywords) => _prefs.setStringList(_filterKeywordsKey, keywords);

  void updateHasRead(int storyId) => _prefs.setBool(_getHasReadKey(storyId), true);

  void clearAllReadStories() {
    final allKeys = _prefs.getKeys().where((String e) => e.contains('hasRead'));
    for (final key in allKeys) {
      _prefs.remove(key);
    }
  }

  Future<AppLanguageType> _getDefaultLangToUse() async {
    try {
      _logger.info(runtimeType, '_getDefaultLangToUse: Trying to retrieve device lang...');
      final deviceLocale = await Devicelocale.currentAsLocale;
      if (deviceLocale == null) {
        _logger.warning(
          runtimeType,
          "_getDefaultLangToUse: Couldn't retrieve the device locale, defaulting to english",
        );
        return AppLanguageType.english;
      }

      final appLang = Constants.languagesMap.entries.firstWhereOrNull((val) => val.value.code == deviceLocale.languageCode);
      if (appLang == null) {
        _logger.info(
          runtimeType,
          "_getDefaultLangToUse: Couldn't find an appropriate app language for = ${deviceLocale.languageCode}_${deviceLocale.countryCode}, defaulting to english",
        );
        return AppLanguageType.english;
      }

      _logger.info(
        runtimeType,
        '_getDefaultLangToUse: Found an appropriate language to use for = ${deviceLocale.languageCode}_${deviceLocale.countryCode}, that is = ${appLang.key}',
      );
      return appLang.key;
    } catch (e, s) {
      _logger.error(runtimeType, '_getDefaultLangToUse: Unknown error occurred', e, s);
      return AppLanguageType.english;
    }
  }

  static String _getHasReadKey(int storyId) => 'hasRead_$storyId';
}
