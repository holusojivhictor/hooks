import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/extensions/extensions.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/routing/app_router.dart';
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
    bool useReader = true,
    bool useAppForHnLink = true,
  }) {
    if (useAppForHnLink && link.isStoryLink) {
      _onStoryLinkTapped(link);
      return;
    }

    WebUri rinseLink(String link) {
      final regex = RegExp(RegExpConstants.linkSuffix);
      if (!link.contains('en.wikipedia.org') && link.contains(regex)) {
        final match = regex.stringMatch(link) ?? '';
        return WebUri.uri(Uri.parse(link.replaceAll(match, '')));
      }

      return WebUri.uri(Uri.parse(link));
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
              settings: ChromeSafariBrowserSettings(
                entersReaderIfAvailable: useReader,
                preferredControlTintColor: AppColors.secondary,
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
          AppRouter.router.pushNamed(
            AppRoute.item.name,
            extra: ItemPageArgs(item: item),
          );
        }
      });
    } else {
      launch(link, useAppForHnLink: false);
    }
  }
}
