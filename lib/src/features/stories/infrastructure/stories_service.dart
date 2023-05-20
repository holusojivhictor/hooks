import 'package:flutter/foundation.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:tuple/tuple.dart';

class StoriesService {
  StoriesService({
    FirebaseClient? firebaseClient,
  }) : _firebaseClient = firebaseClient ?? FirebaseClient.anonymous();

  final FirebaseClient _firebaseClient;
  static const String _baseUrl = 'https://hacker-news.firebaseio.com/v0/';

  Future<Map<String, dynamic>?> _fetchItemJson(int id) async {
    return _firebaseClient
        .get('${_baseUrl}item/$id.json')
        .then((dynamic json) => _parseJson(json as Map<String, dynamic>?));
  }

  Future<Map<String, dynamic>?> _fetchRawItemJson(int id) async {
    return _firebaseClient
        .get('${_baseUrl}item/$id.json')
        .then((dynamic value) => value as Map<String, dynamic>?);
  }

  /// Fetch a [Item] based on its id.
  Future<Item?> fetchItem({required int id}) async {
    final item = await _fetchItemJson(id).then((Map<String, dynamic>? json) {
      if (json == null) return null;

      final type = json['type'] as String;
      if (type == 'story' || type == 'job' || type == 'poll') {
        final story = Story.fromJson(json);
        return story;
      } else if (type == 'comment') {
        final comment = Comment.fromJson(json);
        return comment;
      }
      return null;
    });

    return item;
  }

  /// Fetch a raw [Item] based on its id.
  /// The content of [Item] will not be parsed, use this function only if
  /// the format of content doesn't matter, otherwise, use [fetchItem].
  Future<Item?> fetchRawItem({required int id}) async {
    final item = await _fetchRawItemJson(id).then((dynamic value) {
      if (value == null) return null;

      final json = value as Map<String, dynamic>;

      final type = json['type'] as String;
      if (type == 'story' || type == 'job' || type == 'poll') {
        final story = Story.fromJson(json);
        return story;
      } else if (type == 'comment') {
        final comment = Comment.fromJson(json);
        return comment;
      }
      return null;
    });

    return item;
  }

  /// Fetch a [User] by its [id].
  /// Hacker News uses user's username as [id].
  Future<User?> fetchUser({required String id}) async {
    final user = await _firebaseClient.get('${_baseUrl}user/$id.json').then((dynamic val) {
      final json = val as Map<String, dynamic>?;
      if (json == null) return null;

      final user = User.fromJson(json);
      return user;
    });

    return user;
  }

  /// Fetch ids of stories of a certain [StoryType].
  Future<List<int>> fetchStoryIds({required StoryType type}) async {
    final ids = await _firebaseClient.get('$_baseUrl${type.path}.json').then((dynamic value) {
      final ids = (value as List<dynamic>).cast<int>();
      return ids;
    });

    return ids;
  }

  /// Fetch a [Story] based on its id.
  Future<Story?> fetchStory({required int id}) async {
    final story = await _fetchItemJson(id).then((Map<String, dynamic>? json) {
      if (json == null) return null;

      final story = Story.fromJson(json);
      return story;
    });

    return story;
  }

  /// Fetch a [Comment] based on its id.
  Future<Comment?> fetchComment({required int id}) async {
    final comment = await _fetchItemJson(id).then((Map<String, dynamic>? json) async {
      if (json == null) return null;

      final comment = Comment.fromJson(json);
      return comment;
    });

    return comment;
  }

  /// Fetch the parent [Story] of a [Comment].
  Future<Story?> fetchParentStory({required int id}) async {
    Item? item;

    do {
      item = await fetchItem(id: item?.parent ?? id);
      if (item == null) return null;
    } while (item is Comment);

    return item as Story;
  }

  /// Fetch the parent [Story] of a [Comment] as well as
  /// the list of [Comment] traversed in order to reach the parent.
  Future<Tuple2<Story, List<Comment>>?> fetchParentStoryWithComments({
    required int id,
  }) async {
    Item? item;
    final parentComments = <Comment>[];

    do {
      item = await fetchItem(id: item?.parent ?? id);
      if (item is Comment) {
        parentComments.add(item);
      }
      if (item == null) return null;
    } while (item is Comment);

    for (var i = 0; i < parentComments.length; i++) {
      parentComments[i] = parentComments[i].copyWith(level: parentComments.length - i - 1);
    }

    return Tuple2<Story, List<Comment>>(
      item as Story,
      parentComments.reversed.toList(),
    );
  }

  /// Fetch a list of [Comment] based on ids and return results
  /// using a stream.
  Stream<Comment> fetchCommentsStream({
    required List<int> ids,
    int level = 0,
    Comment? Function(int)? getFromCache,
  }) async* {
    for (final id in ids) {
      var comment = getFromCache?.call(id)?.copyWith(level: level);

      comment ??=
      await _fetchItemJson(id).then((Map<String, dynamic>? json) async {
        if (json == null) return null;

        final comment = Comment.fromJson(json, level: level);
        return comment;
      });

      if (comment != null) {
        yield comment;
      }
    }
    return;
  }

  /// Fetch a list of [Comment] based on ids recursively and
  /// return results using a stream.
  Stream<Comment> fetchAllCommentsRecursivelyStream({
    required List<int> ids,
    int level = 0,
    Comment? Function(int)? getFromCache,
  }) async* {
    for (final id in ids) {
      var comment = getFromCache?.call(id)?.copyWith(level: level);

      comment ??=
      await _fetchItemJson(id).then((Map<String, dynamic>? json) async {
        if (json == null) return null;

        final comment = Comment.fromJson(json, level: level);
        return comment;
      });

      if (comment != null) {
        yield comment;

        yield* fetchAllCommentsRecursivelyStream(
          ids: comment.kids,
          level: level + 1,
          getFromCache: getFromCache,
        );
      }
    }
    return;
  }

  /// Fetch a list of [Item] based on ids and return results
  /// using a stream.
  Stream<Item> fetchItemsStream({required List<int> ids}) async* {
    for (final id in ids) {
      final item = await _fetchItemJson(id).then((Map<String, dynamic>? json) async {
        if (json == null) return null;

        final type = json['type'] as String;
        if (type == 'story' || type == 'job') {
          final story = Story.fromJson(json);
          return story;
        } else if (type == 'comment') {
          final comment = Comment.fromJson(json);
          return comment;
        }
        return null;
      });

      if (item != null) {
        yield item;
      }
    }
  }

  /// Fetch a list of [Story] based on ids and return results
  /// using a stream.
  Stream<Story> fetchStoriesStream({required List<int> ids}) async* {
    for (final id in ids) {
      final story = await _fetchItemJson(id).then((Map<String, dynamic>? json) async {
        if (json == null) return null;
        final story = Story.fromJson(json);
        return story;
      });

      if (story != null) {
        yield story;
      }
    }
  }

  static Future<Map<String, dynamic>?> _parseJson(
    Map<String, dynamic>? json,
  ) async {
    if (json == null) return null;
    final text = json['text'] as String? ?? '';
    final parsedText = await compute<String, String>(
      HtmlUtils.parseHtml,
      text,
    );
    json['text'] = parsedText;
    return json;
  }
}
