import 'package:collection/collection.dart' show IterableExtension;
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/logging_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this._logger, {
    FlutterSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final String _usernameKey = 'Username';
  final String _passwordKey = 'Password';
  final String _appThemeKey = 'AppTheme';
  final String _appLanguageKey = 'AppLanguage';
  final String _fetchModeKey = 'FetchMode';
  final String _commentsOrderKey = 'CommentsOrder';
  final String _isFirstInstallKey = 'FirstInstall';
  final String _doubleBackToCloseKey = 'DoubleBackToClose';
  final String _autoThemeModeKey = 'AutoThemeMode';
  final String _markReadStoriesKey = 'MarkReadStories';
  final String _complexStoryTileKey = 'ComplexStoryTile';
  final String _showMetadataKey = 'ShowMetadata';
  final String _showUrlKey = 'ShowUrl';
  final String _filterKeywordsKey = 'FilterKeywords';
  final String _unreadCommentsIdsKey = 'UnreadCommentsIds';

  bool _initialized = false;

  late SharedPreferences _prefs;
  final LoggingService _logger;
  final FlutterSecureStorage _secureStorage;

  AppThemeType get appTheme => AppThemeType.values[_prefs.getInt(_appThemeKey)!];

  set appTheme(AppThemeType theme) => _prefs.setInt(_appThemeKey, theme.index);

  AppLanguageType get language => AppLanguageType.values[_prefs.getInt(_appLanguageKey)!];

  set language(AppLanguageType lang) => _prefs.setInt(_appLanguageKey, lang.index);

  FetchMode get fetchMode => FetchMode.values[_prefs.getInt(_fetchModeKey)!];

  set fetchMode(FetchMode lang) => _prefs.setInt(_fetchModeKey, lang.index);

  CommentsOrder get commentsOrder => CommentsOrder.values[_prefs.getInt(_commentsOrderKey)!];

  set commentsOrder(CommentsOrder lang) => _prefs.setInt(_commentsOrderKey, lang.index);

  bool get isFirstInstall => _prefs.getBool(_isFirstInstallKey)!;

  set isFirstInstall(bool itIs) => _prefs.setBool(_isFirstInstallKey, itIs);

  bool get doubleBackToClose => _prefs.getBool(_doubleBackToCloseKey)!;

  set doubleBackToClose(bool value) => _prefs.setBool(_doubleBackToCloseKey, value);

  bool get markReadStories => _prefs.getBool(_markReadStoriesKey)!;

  set markReadStories(bool value) => _prefs.setBool(_markReadStoriesKey, value);

  bool get complexStoryTile => _prefs.getBool(_complexStoryTileKey)!;

  set complexStoryTile(bool value) => _prefs.setBool(_complexStoryTileKey, value);

  bool get showMetadata => _prefs.getBool(_showMetadataKey)!;

  set showMetadata(bool value) => _prefs.setBool(_showMetadataKey, value);

  bool get showUrl => _prefs.getBool(_showUrlKey)!;

  set showUrl(bool value) => _prefs.setBool(_showUrlKey, value);

  AutoThemeModeType get autoThemeMode => AutoThemeModeType.values[_prefs.getInt(_autoThemeModeKey)!];

  set autoThemeMode(AutoThemeModeType themeMode) => _prefs.setInt(_autoThemeModeKey, themeMode.index);

  Future<bool> get loggedIn async => await username != null;

  Future<String?> get username async => _secureStorage.read(key: _usernameKey);

  Future<String?> get password async => _secureStorage.read(key: _passwordKey);

  AppSettings get appSettings => AppSettings(
    appTheme: appTheme,
    appLanguage: language,
    fetchMode: fetchMode,
    commentsOrder: commentsOrder,
    useDarkMode: false,
    isFirstInstall: isFirstInstall,
    doubleBackToClose: doubleBackToClose,
    markReadStories: markReadStories,
    complexStoryTile: complexStoryTile,
    showMetadata: showMetadata,
    showUrl: showUrl,
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

    if (_prefs.get(_fetchModeKey) == null) {
      _logger.info(runtimeType, 'Default comments fetch mode set to eager');
      fetchMode = FetchMode.eager;
    }

    if (_prefs.get(_commentsOrderKey) == null) {
      _logger.info(runtimeType, 'Default comments order set to natural');
      commentsOrder = CommentsOrder.natural;
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

    if (_prefs.get(_showMetadataKey) == null) {
      _logger.info(runtimeType, 'Show metadata will be set to its default (true)');
      showMetadata = true;
    }

    if (_prefs.get(_showUrlKey) == null) {
      _logger.info(runtimeType, 'Show url will be set to its default (true)');
      showUrl = true;
    }

    if (_prefs.get(_autoThemeModeKey) == null) {
      _logger.info(runtimeType, 'Auto theme mode set to false as default');
      autoThemeMode = AutoThemeModeType.off;
    }

    _initialized = true;
    _logger.info(runtimeType, 'Settings were initialized successfully');
  }

  /// Handle auth
  Future<void> setAuth({
    required String username,
    required String password,
  }) async {
    const androidOptions = AndroidOptions(resetOnError: true);
    try {
      await _secureStorage.write(
        key: _usernameKey,
        value: username,
        aOptions: androidOptions,
      );
      await _secureStorage.write(
        key: _passwordKey,
        value: password,
        aOptions: androidOptions,
      );
    } catch (_) {
      try {
        await _secureStorage.deleteAll(
          aOptions: androidOptions,
        );
      } catch (_) {
        _logger.error(runtimeType, 'unknown');
      }

      rethrow;
    }
  }

  Future<void> removeAuth() async {
    await _secureStorage.delete(key: _usernameKey);
    await _secureStorage.delete(key: _passwordKey);
  }

  bool hasRead(int storyId) {
    final key = _getHasReadKey(storyId);
    final val = _prefs.getBool(key);

    if (val == null) return false;

    return true;
  }

  /// Update filter keywords
  List<String> get filterKeywords => _prefs.getStringList(_filterKeywordsKey) ?? <String>[];

  void updateFilterKeywords(List<String> keywords) => _prefs.setStringList(_filterKeywordsKey, keywords);

  /// Update read stories
  void updateHasRead(int storyId) => _prefs.setBool(_getHasReadKey(storyId), true);

  void clearAllReadStories() {
    final allKeys = _prefs.getKeys().where((String e) => e.contains('hasRead'));
    for (final key in allKeys) {
      _prefs.remove(key);
    }
  }

  /// Update unread comments ids
  List<int> get unreadCommentsIds => _prefs.getStringList(_unreadCommentsIdsKey)?.map(int.parse).toList() ?? <int>[];

  void updateUnreadCommentsIds(List<int> ids) {
    _prefs.setStringList(_unreadCommentsIdsKey, ids.map((int e) => e.toString()).toList());
  }

  /// Handle voting
  bool? vote({required int submittedTo, required String from}) {
    final key = _getVoteKey(from, submittedTo);
    final vote = _prefs.getBool(key);
    return vote;
  }

  void addVote({
    required String username,
    required int id,
    required bool vote,
  }) {
    final key = _getVoteKey(username, id);
    _prefs.setBool(key, vote);
  }

  void removeVote({
    required String username,
    required int id,
  }) {
    final key = _getVoteKey(username, id);
    _prefs.remove(key);
  }

  String _getVoteKey(String username, int id) => 'vote_$username-$id';

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
      _logger.error(runtimeType, '_getDefaultLangToUse: Unknown error occurred', ex: e, trace: s);
      return AppLanguageType.english;
    }
  }

  static String _getHasReadKey(int storyId) => 'hasRead_$storyId';
}
