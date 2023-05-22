import 'package:hooks/src/features/common/presentation/linkify/linkifiers/linkifiers.dart';
import 'package:linkify/linkify.dart';

class LinkifierUtils {
  static const LinkifyOptions linkifyOptions = LinkifyOptions(humanize: false);

  static List<LinkifyElement> linkify(String text) {
    const linkifiers = <Linkifier>[
      UrlLinkifier(),
      EmailLinkifier(),
      QuoteLinkifier(),
      EmphasisLinkifier(),
    ];
    var list = <LinkifyElement>[TextElement(text)];

    if (text.isEmpty) {
      return <LinkifyElement>[];
    }

    if (linkifiers.isEmpty) {
      return list;
    }

    for (final linkifier in linkifiers) {
      list = linkifier.parse(list, linkifyOptions);
    }

    return list;
  }
}
