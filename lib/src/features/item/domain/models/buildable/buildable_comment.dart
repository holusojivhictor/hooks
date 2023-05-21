import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';
import 'package:linkify/linkify.dart';

class BuildableComment extends Comment with Buildable {
  BuildableComment({
    required super.id,
    required super.time,
    required super.parent,
    required super.score,
    required super.by,
    required super.text,
    required super.kids,
    required super.dead,
    required super.deleted,
    required super.hidden,
    required super.level,
    required this.elements,
  });

  BuildableComment.fromComment(
    Comment comment, {
    required this.elements,
  }) : super(
          id: comment.id,
          time: comment.time,
          parent: comment.parent,
          score: comment.score,
          by: comment.by,
          text: comment.text,
          kids: comment.kids,
          dead: comment.dead,
          deleted: comment.deleted,
          level: comment.level,
          hidden: comment.hidden,
        );

  @override
  final List<LinkifyElement> elements;
}
