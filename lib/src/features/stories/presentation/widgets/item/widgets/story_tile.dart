import 'package:flutter/material.dart';
import 'package:hooks/src/extensions/context_extension.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';

class StoryTile extends StatelessWidget {
  const StoryTile({
    required this.showWebPreview,
    required this.showMetadata,
    required this.showUrl,
    required this.hasRead,
    required this.story,
    required this.onTap,
    required this.simpleTileFontSize,
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
    if (story.hidden) return const SizedBox.shrink();
    if (showWebPreview) {
      final height = context.storyTileHeight;
      return Semantics(
        label: story.screenReaderLabel,
        excludeSemantics: true,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: ,
        ),
      );
    }
    return const Placeholder();
  }
}
