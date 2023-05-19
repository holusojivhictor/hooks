import 'package:flutter/widgets.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';

const na = 'N/A';
const Duration kAnimationDuration = Duration(milliseconds: 200);
const Curve kCurve = Curves.easeInOut;

/// Languages map
const languagesMap = {
  AppLanguageType.english: LanguageModel('en', 'US'),
};

const String guidelineLink = 'https://news.ycombinator.com/newsguidelines.html';
