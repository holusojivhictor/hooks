import 'package:flutter/widgets.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';

abstract class Constants {
  static const na = 'N/A';
  static const Duration kAnimationDuration = Duration(milliseconds: 200);
  static const Curve kCurve = Curves.easeInOut;

  /// Languages map
  static const languagesMap = {
    AppLanguageType.english: LanguageModel('en', 'US'),
  };

  static const String errorMessage = 'Something went wrong...';

  static const String hackerNewsLogoLink =
      'https://pbs.twimg.com/profile_images/469397708986269696/iUrYEOpJ_400x400.png';
  static const String guidelineLink = 'https://news.ycombinator.com/newsguidelines.html';
}

abstract class RegExpConstants {
  static const String linkSuffix = r'(\)|]|,|\*)(.)*$';
  static const String number = '[0-9]+';
}
