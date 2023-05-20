import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/assets.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/job_avatar.dart';
import 'package:hooks/src/features/common/presentation/styles.dart';
import 'package:hooks/src/features/stories/presentation/widgets/tap_down_wrapper.dart';
import 'package:hooks/src/utils/link_utils.dart';

class LinkView extends StatelessWidget {
  LinkView({
    required this.metadata,
    required this.timeAgo,
    required this.url,
    required this.readableUrl,
    required this.title,
    required this.description,
    required this.onTap,
    required this.showMetadata,
    required this.isJob,
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
  final String timeAgo;
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
  final bool isJob;
  final bool showMetadata;
  final bool showUrl;

  static const double _bottomPadding = 6;

  static bool? isUsingSerifFont;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final layoutWidth = constraints.biggest.width;
        final layoutHeight = constraints.biggest.height;
        final fontFamily = Theme.of(context).primaryTextTheme.bodyMedium?.fontFamily;
        final titleStyle = titleTextStyle;
        final urlStyle = titleStyle.copyWith(
          color: AppColors.grey4,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: Font.clashDisplay.name,
        );
        final descriptionStyle = TextStyle(
          color: AppColors.grey4,
          fontFamily: Font.clashDisplay.name,
          fontSize: 14,
        );
        final metadataStyle = descriptionStyle.copyWith(
          fontSize: 12,
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
                  onTap: () {
                    if (url.isNotEmpty) {
                      LinkUtils.launch(url, useAppForHnLink: false);
                    } else {
                      onTap();
                    }
                  },
                  child: ClipRRect(
                    borderRadius: Styles.defaultCardBorderRadius,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: layoutHeight,
                          width: layoutHeight,
                          child: isIcon || (imageUri?.isEmpty ?? true) && imagePath != null
                              ? Image.asset(
                                  imagePath!,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: imageUri!,
                                  fit: BoxFit.cover,
                                  memCacheHeight: layoutHeight.toInt() * 4,
                                  errorWidget: (BuildContext context, _, __) {
                                    return Image.asset(
                                      Assets.hackerNewsLogoPath,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                        ),
                        if (isJob)
                          const Positioned(
                            right: 5,
                            bottom: 5,
                            child: JobAvatar(),
                          ),
                      ],
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: _bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: isUsingSerifFont! ? 2 : 4,
                          ),
                          Text(
                            title,
                            style: titleStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          if (showMetadata)
                            Text(
                              metadata,
                              textAlign: TextAlign.left,
                              style: metadataStyle,
                              overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          if (showMetadata)
                            const SizedBox(height: 2),
                          Text(
                            description,
                            textAlign: TextAlign.left,
                            style: descriptionStyle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 4,
                          ),
                        ],
                      ),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            readableUrl,
                            textAlign: TextAlign.left,
                            style: urlStyle,
                            overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 1,
                              left: 3,
                              right: 3,
                            ),
                            child: CircleAvatar(
                              radius: 2,
                              backgroundColor: AppColors.grey4,
                            ),
                          ),
                          Text(
                            timeAgo,
                            textAlign: TextAlign.left,
                            style: urlStyle,
                            overflow: bodyTextOverflow ?? TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
