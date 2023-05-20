import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks/src/extensions/context_extension.dart';
import 'package:hooks/src/features/common/domain/constants.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/features/stories/presentation/widgets/link_preview/link_preview.dart';
import 'package:shimmer/shimmer.dart';

class StoryTile extends StatelessWidget {
  const StoryTile({
    required this.showWebPreview,
    required this.showMetadata,
    required this.showUrl,
    required this.hasRead,
    required this.story,
    required this.onTap,
    this.simpleTileFontSize = 16,
    super.key,
  });

  final bool showWebPreview;
  final bool showMetadata;
  final bool showUrl;
  final bool hasRead;
  final Story story;
  final VoidCallback onTap;
  final double simpleTileFontSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (story.hidden) return const SizedBox.shrink();
    if (showWebPreview) {
      final height = context.storyTileHeight;
      return Semantics(
        label: story.screenReaderLabel,
        excludeSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: LinkPreview(
            link: story.url,
            story: story,
            onTap: onTap,
            placeholderWidget: _LinkPreviewPlaceholder(height: height),
            errorImage: Constants.hackerNewsLogoLink,
            backgroundColor: Colors.transparent,
            borderRadius: 0,
            removeElevation: true,
            bodyMaxLines: context.storyTileMaxLines,
            errorTitle: story.title,
            showMetadata: showMetadata,
            showUrl: showUrl,
            titleStyle: hasRead
                ? textTheme.bodyMedium!.copyWith(color: AppColors.grey5)
                : textTheme.bodyMedium!,
          ),
        ),
      );
    } else {
      return Semantics(
        label: story.screenReaderLabel,
        excludeSemantics: true,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: story.title,
                              style: hasRead
                                  ? textTheme.bodyMedium!.copyWith(
                                      color: AppColors.grey5,
                                      fontSize: simpleTileFontSize,)
                                  : textTheme.bodyMedium!.copyWith(fontSize: simpleTileFontSize),
                            ),
                            if (showUrl && story.url.isNotEmpty)
                              TextSpan(
                                text: ' (${story.readableUrl})',
                                style: textTheme.bodyMedium!.copyWith(
                                  color: AppColors.grey5,
                                  fontSize: simpleTileFontSize - 4,
                                ),
                              )
                          ],
                        ),
                        textScaleFactor: MediaQuery.of(context).textScaleFactor,
                      ),
                    )
                  ],
                ),
                if (showMetadata)
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          story.metadata,
                          style: textTheme.bodyMedium!.copyWith(
                            color: AppColors.grey4,
                            fontSize: simpleTileFontSize - 2,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _LinkPreviewPlaceholder extends StatelessWidget {
  const _LinkPreviewPlaceholder({
    required this.height,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: SizedBox(
        height: height,
        child: Shimmer.fromColors(
          baseColor: AppColors.primary,
          highlightColor: AppColors.secondary,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  right: 5,
                  bottom: 5,
                  top: 5,
                ),
                child: Container(
                  height: height,
                  width: height,
                  color: AppColors.white,
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 4,
                    top: 6,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        height: 14,
                        color: AppColors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                      ),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: AppColors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: AppColors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      Container(
                        width: double.infinity,
                        height: 10,
                        color: AppColors.white,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 3),
                      ),
                      Container(
                        width: 40,
                        height: 10,
                        color: AppColors.white,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
