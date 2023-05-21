import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:linkify/linkify.dart';

class BuildableStory extends Story with Buildable {
  const BuildableStory({
    required super.id,
    required super.time,
    required super.score,
    required super.by,
    required super.text,
    required super.kids,
    required super.descendants,
    required super.title,
    required super.type,
    required super.url,
    required super.parts,
    required super.hidden,
    required this.elements,
  });

  BuildableStory.fromStory(
    Story story, {
    required this.elements,
  }) : super(
          id: story.id,
          time: story.time,
          score: story.score,
          by: story.by,
          text: story.text,
          kids: story.kids,
          descendants: story.descendants,
          title: story.title,
          type: story.type,
          url: story.url,
          parts: story.parts,
          hidden: story.hidden,
        );

  BuildableStory.fromTitleOnlyStory(Story story)
      : this.fromStory(
          story,
          elements: const <LinkifyElement>[],
        );

  @override
  final List<LinkifyElement> elements;
}
