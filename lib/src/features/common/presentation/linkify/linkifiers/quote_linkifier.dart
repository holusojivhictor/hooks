import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';

final RegExp _quoteRegex = RegExp(
  r'(?=^>)(.*?)(?=\n|$)',
  multiLine: true,
);

class QuoteLinkifier extends Linkifier {
  const QuoteLinkifier();

  @override
  List<LinkifyElement> parse(
    List<LinkifyElement> elements,
    LinkifyOptions options,
  ) {
    final list = <LinkifyElement>[];

    for (final element in elements) {
      if (element is TextElement) {
        final match = _quoteRegex.firstMatch(
          element.text.trimLeft(),
        );

        if (match == null) {
          list.add(element);
        } else {
          final matchedText = match.group(0)!;
          final pos = element.text.indexOf(matchedText);
          final splitTexts = element.text.split(matchedText);

          var curPos = 0;
          var added = false;

          for (final text in splitTexts) {
            list.addAll(parse(<TextElement>[TextElement(text)], options));
            curPos += text.length;
            if (!added && curPos >= pos) {
              added = true;
              list.add(QuoteElement(matchedText));
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

/// Represents an element that starts with '>'.
@immutable
class QuoteElement extends LinkifyElement {
  QuoteElement(super.text);

  @override
  String toString() {
    return "QuoteElement: '$text'";
  }

  @override
  bool operator ==(Object other) => equals(other);

  @override
  bool equals(dynamic other) => other is QuoteElement && super.equals(other);

  @override
  int get hashCode => text.hashCode;
}
