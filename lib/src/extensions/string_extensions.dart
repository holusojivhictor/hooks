import 'package:hooks/src/features/common/domain/constants.dart';

extension StringExtensions on String {
  int? get itemId {
    final regex = RegExp(RegExpConstants.number);
    final exception = RegExp(RegExpConstants.linkSuffix);
    final match = regex.stringMatch(replaceAll(exception, '')) ?? '';
    return int.tryParse(match);
  }

  bool get isStoryLink => contains('news.ycombinator.com/item');

  String removeAllEmojis() {
    final regex = RegExp(
      r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
    );
    return replaceAllMapped(regex, (_) => '');
  }
}

extension OptionalStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty || this!.trim().isEmpty;
  bool get isNotNullNorEmpty => !isNullOrEmpty;

  bool get isNullOrEmptyOrHasNull => this == null || this!.isEmpty || this!.contains('null');
  bool get isNotNullNorEmptyNorHasNull => !isNullOrEmptyOrHasNull;
}
