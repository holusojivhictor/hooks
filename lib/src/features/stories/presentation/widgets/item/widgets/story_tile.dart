import 'package:flutter/material.dart';
import 'package:hooks/src/features/stories/domain/models/db/models.dart';

class StoryTile extends StatelessWidget {
  const StoryTile({
    required this.showMetadata,
    required this.showUrl,
    required this.hasRead,
    required this.story,
    required this.onTap,
    required this.simpleTileFontSize,
    super.key,
  });

  final bool showMetadata;
  final bool showUrl;
  final bool hasRead;
  final Story story;
  final VoidCallback onTap;
  final double simpleTileFontSize;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
