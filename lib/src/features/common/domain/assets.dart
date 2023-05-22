import 'package:hooks/src/features/common/domain/enums/enums.dart';

class Assets {
  const Assets._();

  static const String _imagePath = 'assets/images';
  static const String _gifsPath = 'assets/gifs';
  static const String hackerNewsLogoPath = '$_imagePath/hacker_news_logo.png';
  static const String loading = '$_gifsPath/loading.gif';

  static AppThemeType translateThemeTypeBool({required bool value}) {
    switch (value) {
      case false:
        return AppThemeType.light;
      case true:
        return AppThemeType.dark;
      default:
        throw Exception('Unknown error occurred');
    }
  }
}
