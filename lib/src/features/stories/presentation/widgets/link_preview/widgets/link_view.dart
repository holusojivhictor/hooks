import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/assets.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/tap_down_wrapper.dart';

class LinkView extends StatelessWidget {
  LinkView({
    required this.metadata,
    required this.url,
    required this.readableUrl,
    required this.title,
    required this.description,
    required this.onTap,
    required this.showMetadata,
    required bool showUrl,
    required this.bodyMaxLines,
    required this.titleTextStyle,
    super.key,
    this.imageUri,
    this.imagePath,
    this.showMultiMedia = true,
    this.bodyTextOverflow,
    this.isIcon = false,
    this.bgColor,
    this.radius = 0,
  })  : showUrl = showUrl && url.isNotEmpty,
        assert(
          !showMultiMedia || (showMultiMedia && (imageUri != null || imagePath != null)),
          'imageUri or imagePath cannot be null when showMultiMedia is true',
        );

  final String metadata;
  final String url;
  final String readableUrl;
  final String title;
  final String description;
  final String? imageUri;
  final String? imagePath;
  final VoidCallback onTap;
  final TextStyle titleTextStyle;
  final bool showMultiMedia;
  final TextOverflow? bodyTextOverflow;
  final int bodyMaxLines;
  final bool isIcon;
  final double radius;
  final Color? bgColor;
  final bool showMetadata;
  final bool showUrl;

  static const double _bottomPadding = 6;
  static late TextStyle _urlStyle;
  static late TextStyle _metadataStyle;
  static late TextStyle _descriptionStyle;

  static final Map<MaxLineComputationParams, int> _computationCache =
      <MaxLineComputationParams, int>{};

  static int getDescriptionMaxLines(
    MaxLineComputationParams params,
    TextStyle titleStyle,
  ) {
    if (_computationCache.containsKey(params)) {
      return _computationCache[params]!;
    }

    _urlStyle = titleStyle.copyWith(
      color: AppColors.grey4,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      fontFamily: params.fontFamily,
    );
    _descriptionStyle = TextStyle(
      color: AppColors.grey4,
      fontFamily: params.fontFamily,
      fontSize: 14,
    );
    _metadataStyle = _descriptionStyle.copyWith(
      fontSize: 12,
      fontFamily: params.fontFamily,
    );

    final urlHeight = (TextPainter(
      text: TextSpan(
        text: '(url)',
        style: _urlStyle,
      ),
      maxLines: 1,
      textScaleFactor: params.textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout())
        .size
        .height;
    final metadataHeight = (TextPainter(
      text: TextSpan(
        text: '123metadata',
        style: _metadataStyle,
      ),
      maxLines: 1,
      textScaleFactor: params.textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout())
        .size
        .height;
    final descriptionHeight = (TextPainter(
      text: TextSpan(
        text: 'DESCRIPTION',
        style: _descriptionStyle,
      ),
      maxLines: 1,
      textScaleFactor: params.textScaleFactor,
      textDirection: TextDirection.ltr,
    )..layout())
        .size
        .height;

    final allPaddings = params.fontFamily == Font.clashDisplay.name ? 2.0 : 4.0;

    final height = <double>[
      params.titleHeight,
      if (params.showUrl) urlHeight,
      if (params.showMetadata) metadataHeight,
      allPaddings,
      _bottomPadding,
    ].reduce((double a, double b) => a + b);

    final descriptionAllowedHeight = params.layoutHeight - height;

    final int maxLines = max(1, (descriptionAllowedHeight / descriptionHeight).floor());

    _computationCache[params] = maxLines;

    return maxLines;
  }

  static bool? isUsingSerifFont;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final layoutWidth = constraints.biggest.width;
        final layoutHeight = constraints.biggest.height;
        final bodyWidth = layoutWidth - layoutHeight - 8;
        final fontFamily = Theme.of(context).primaryTextTheme.bodyMedium?.fontFamily;
        final textScaleFactor = MediaQuery.of(context).textScaleFactor;
        final titleStyle = titleTextStyle;
        final titleHeight = (TextPainter(
          text: TextSpan(
            text: title,
            style: titleStyle,
          ),
          maxLines: 2,
          textScaleFactor: textScaleFactor,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: bodyWidth))
            .size
            .height;
        final descriptionMaxLines = getDescriptionMaxLines(
          MaxLineComputationParams(
            fontFamily ?? Font.clashDisplay.name,
            bodyWidth,
            layoutHeight,
            titleHeight,
            textScaleFactor,
            showUrl,
            showMetadata,
          ),
          titleStyle,
        );

        isUsingSerifFont ??= Font.fromString(fontFamily).isSerif;

        return Row(
          children: <Widget>[
            if (showMultiMedia)
              Padding(
                padding: const EdgeInsets.only(
                  right: 8,
                  top: 5,
                  bottom: 5,
                ),
                child: TapDownWrapper(
                  onTap: () {},
                  child: SizedBox(
                    height: layoutHeight,
                    width: layoutHeight,
                    child: (imageUri?.isEmpty ?? true) && imagePath != null
                        ? Image.asset(
                            imagePath!,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUri!,
                            fit: isIcon ? BoxFit.scaleDown : BoxFit.fitWidth,
                            memCacheHeight: layoutHeight.toInt() * 4,
                            errorWidget: (BuildContext context, _, __) {
                              return Image.asset(
                                Assets.hackerNewsLogoPath,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                  ),
                ),
              )
            else
              const SizedBox(width: 5),
            TapDownWrapper(
              onTap: onTap,
              child: SizedBox(
                height: layoutHeight,
                width: layoutWidth - layoutHeight - 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: isUsingSerifFont! ? 2 : 4,
                    ),
                    Text(
                      title,
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    if (showUrl)
                      Text(
                        '($readableUrl)',
                        textAlign: TextAlign.left,
                        style: _urlStyle,
                        overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    if (showMetadata)
                      Text(
                        metadata,
                        textAlign: TextAlign.left,
                        style: _metadataStyle,
                        overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    Text(
                      description,
                      textAlign: TextAlign.left,
                      style: _descriptionStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: descriptionMaxLines,
                    ),
                    const SizedBox(
                      height: _bottomPadding,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
