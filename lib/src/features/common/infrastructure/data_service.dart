import 'dart:io';

import 'package:hooks/src/features/stories/domain/models/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DataService {
  late Database _database;

  static const String _cachedCommentsKey = 'CachedComments';
  static const String _commentsKey = 'Comments';

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, 'hooks.db');
    final dbFactory = databaseFactoryIo;
    final db = await dbFactory.openDatabase(dbPath);
    _database = db;
  }

  Future<Map<String, Object?>> cacheComment(Comment comment) async {
    final store = intMapStoreFactory.store(_cachedCommentsKey);
    return store.record(comment.id).put(_database, comment.toJson());
  }

  Future<Comment?> getCachedComment({required int id}) async {
    final store = intMapStoreFactory.store(_cachedCommentsKey);
    final snapshot = await store.record(id).getSnapshot(_database);
    if (snapshot != null) {
      final comment = Comment.fromJson(snapshot.value);
      return comment;
    } else {
      return null;
    }
  }

  Future<int> deleteAllCachedComments() async {
    final store = intMapStoreFactory.store(_cachedCommentsKey);
    return store.delete(_database);
  }

  Future<Map<String, Object?>> saveComment(Comment comment) async {
    final store = intMapStoreFactory.store(_commentsKey);
    return store.record(comment.id).put(_database, comment.toJson());
  }

  Future<void> saveComments(List<Comment> comments) async {
    final store = intMapStoreFactory.store(_commentsKey);

    return _database.transaction((Transaction txn) async {
      for (final cmt in comments) {
        await store.record(cmt.id).put(txn, cmt.toJson());
      }
    });
  }

  Future<Comment?> getComment({required int id}) async {
    final store = intMapStoreFactory.store(_commentsKey);
    final snapshot = await store.record(id).getSnapshot(_database);
    if (snapshot != null) {
      final comment = Comment.fromJson(snapshot.value);
      return comment;
    } else {
      return null;
    }
  }

  Future<List<Comment>> getComments({required List<int> ids}) async {
    final store = intMapStoreFactory.store(_commentsKey);
    final comments = <Comment>[];

    await _database.transaction((Transaction txn) async {
      for (final id in ids) {
        final snapshot = await store.record(id).getSnapshot(txn);
        if (snapshot != null) {
          final comment = Comment.fromJson(snapshot.value);
          comments.add(comment);
        }
      }
    });

    return comments;
  }

  Future<FileSystemEntity> deleteAll() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final dbPath = join(dir.path, 'hooks.db');
    return File(dbPath).delete();
  }
}
