import 'package:equatable/equatable.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';

class ItemPageArgs extends Equatable {
  const ItemPageArgs({
    required this.item,
    this.onlyShowTargetComment = false,
    this.useCommentCache = false,
    this.targetComments,
  });

  final Item item;
  final bool onlyShowTargetComment;
  final List<Comment>? targetComments;
  final bool useCommentCache;

  @override
  List<Object?> get props => <Object?>[
    item,
    onlyShowTargetComment,
    targetComments,
    useCommentCache,
  ];
}
