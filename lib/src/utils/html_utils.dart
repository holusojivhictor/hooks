// ignore_for_file: type=lint

import 'package:html_unescape/html_unescape.dart';

class HtmlUtils {
  static String parseHtml(String text) {
    return HtmlUnescape()
        .convert(text)
        .replaceAll('<p>', '\n')
        .replaceAllMapped(
          RegExp(r'\<i\>(.*?)\<\/i\>'),
          (Match match) => '*${match[1]}*',
        )
        .replaceAllMapped(
          RegExp(r'\<pre\>\<code\>(.*?)\<\/code\>\<\/pre\>', dotAll: true),
          (Match match) => match[1]?.trimRight() ?? '',
        )
        .replaceAllMapped(
          RegExp(r'\<a href=\"(.*?)\".*?\>.*?\<\/a\>'),
          (Match match) => match[1] ?? '',
        )
        .replaceAll('\n', '\n\n');
  }
}
