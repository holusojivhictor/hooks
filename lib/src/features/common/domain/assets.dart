import 'package:hooks/src/features/common/domain/enums/enums.dart';

class Assets {
  const Assets._();

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
