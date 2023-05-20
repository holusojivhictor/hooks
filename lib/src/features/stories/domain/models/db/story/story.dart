import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';

class Story extends Item {
  const Story({
    required super.id,
    required super.time,
    required super.score,
    required super.descendants,
    required super.hidden,
    required super.by,
    required super.text,
    required super.url,
    required super.title,
    required super.type,
    required super.kids,
    required super.parts,
  }) : super(dead: false, deleted: false, parent: 0);

  Story.empty() : super.empty();

  Story.placeholder()
      : super(
          id: 0,
          score: 0,
          descendants: 0,
          time: 1171872000,
          by: 'Y Combinator',
          title: 'Hacker News Guidelines',
          url: Constants.guidelineLink,
          kids: <int>[],
          dead: false,
          parts: <int>[],
          deleted: false,
          parent: 0,
          text: '',
          type: '',
          hidden: false,
        );

  Story.fromJson(super.json) : super.fromJson();

  Story copyWith({bool? hidden}) {
    return Story(
      descendants: descendants,
      id: id,
      score: score,
      time: time,
      by: by,
      title: title,
      type: type,
      url: url,
      text: text,
      kids: kids,
      parts: parts,
      hidden: hidden ?? this.hidden,
    );
  }

  String get metadata =>
      '''$score point${score > 1 ? 's' : ''} by $by $timeAgo | $descendants comment${descendants > 1 ? 's' : ''}''';

  String get screenReaderLabel =>
      '''$title, at $readableUrl, by $by $timeAgo. This story has $score point${score > 1 ? 's' : ''} and $descendants comment${descendants > 1 ? 's' : ''}''';

  String get simpleMetadata =>
      '''$score point${score > 1 ? 's' : ''} $descendants comment${descendants > 1 ? 's' : ''} $timeAgo''';

  String get readableUrl {
    final url = Uri.parse(this.url);
    final authority = url.authority.replaceFirst('www.', '');
    return authority;
  }

  @override
  String toString() => 'Story $id';
}
