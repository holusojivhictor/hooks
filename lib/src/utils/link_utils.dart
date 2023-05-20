import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks/src/app.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/extensions/string_extensions.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkUtils {
  static final ChromeSafariBrowser _browser = ChromeSafariBrowser();

  static void launchInExternalBrowser(
    String link,
  ) {
    final uri = Uri.parse(link);
    launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  static void launch(
    String link, {
    bool useReader = false,
    bool useAppForHnLink = true,
  }) {
    if (useAppForHnLink && link.isStoryLink) {
      _onStoryLinkTapped(link);
      return;
    }

    Uri rinseLink(String link) {
      final regex = RegExp(RegExpConstants.linkSuffix);
      if (!link.contains('en.wikipedia.org') && link.contains(regex)) {
        final match = regex.stringMatch(link) ?? '';
        return Uri.parse(link.replaceAll(match, ''));
      }

      return Uri.parse(link);
    }

    final uri = rinseLink(link);
    canLaunchUrl(uri).then((bool val) {
      if (val) {
        if (link.contains('http')) {
          if (Platform.isAndroid) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            _browser.open(
              url: uri,
              options: ChromeSafariBrowserClassOptions(
                ios: IOSSafariOptions(
                  entersReaderIfAvailable: useReader,
                  preferredControlTintColor: AppColors.secondary,
                ),
              ),
            ).onError((_, __) => launchUrl(uri));
          }
        } else {
          launchUrl(uri);
        }
      }
    });
  }

  static Future<void> _onStoryLinkTapped(String link) async {
    final id = link.itemId;
    if (id != null) {
      await getIt<StoriesService>().fetchItem(id: id).then((Item? item) {
        if (item != null) {
          HooksApp.navigatorKey.currentContext!.goNamed('/item');
        }
      });
    } else {
      launch(link, useAppForHnLink: false);
    }
  }
}
