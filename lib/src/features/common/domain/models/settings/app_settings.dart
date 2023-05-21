import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

@freezed
class AppSettings with _$AppSettings {
  factory AppSettings({
    required AppThemeType appTheme,
    required AppLanguageType appLanguage,
    required FetchMode fetchMode,
    required CommentsOrder commentsOrder,
    required bool useDarkMode,
    required bool isFirstInstall,
    required bool doubleBackToClose,
    required bool markReadStories,
    required bool complexStoryTile,
    required bool tapAnywhereToCollapse,
    required bool showMetadata,
    required bool showUrl,
    required AutoThemeModeType themeMode,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}
