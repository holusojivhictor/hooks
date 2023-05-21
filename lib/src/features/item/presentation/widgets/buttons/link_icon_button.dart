import 'package:flutter/material.dart';
import 'package:hooks/src/utils/utils.dart';

class LinkIconButton extends StatelessWidget {
  const LinkIconButton({
    required this.storyId,
    super.key,
  });

  final int storyId;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Open this story in browser',
      icon: const Icon(Icons.stream),
      onPressed: () => LinkUtils.launch(
        'https://news.ycombinator.com/item?id=$storyId',
        useAppForHnLink: false,
      ),
    );
  }
}
