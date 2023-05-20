import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';

final RegExp _emphasisRegex = RegExp(
  r'\*(.*?)\*',
  multiLine: true,
);

class EmphasisLinkifier extends Linkifier {
  const EmphasisLinkifier();

  @override
  List<LinkifyElement> parse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  ) {
    final list = <LinkifyElement>[];

    for (final element in elements) {
      if (element is TextElement) {
        final match = _emphasisRegex.firstMatch(
          element.text.trimLeft(),
        );

        if (element.text == '* * *' ||
            match == null ||
            match.group(0) == null ||
            match.group(1) == null) {
          list.add(element);
        } else {
          final matchedText = match.group(1)!;
          final pos = (element.text.indexOf(matchedText) - 1).clamp(0, double.infinity);
          final splitTexts = element.text.split(match.group(0)!);

          var curPos = 0;
          var added = false;

          for (final text in splitTexts) {
            list.addAll(parse(<LinkifyElement>[TextElement(text)], options));

            curPos += text.length;

            if (!added && curPos >= pos) {
              added = true;
              list.add(EmphasisElement(matchedText));
            }
          }
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}

/// Represents an element wrapped around '*'.
@immutable
class EmphasisElement extends LinkifyElement {
  EmphasisElement(super.text);

  @override
  String toString() {
    return "EmphasisElement: '$text'";
  }

  @override
  bool operator ==(Object other) => equals(other);

  @override
  bool equals(dynamic other) => other is EmphasisElement && super.equals(other);

  @override
  int get hashCode => text.hashCode;
}
