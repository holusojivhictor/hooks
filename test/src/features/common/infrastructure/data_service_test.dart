import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/item/domain/models/models.dart';

void main() {
  late final DataService dataService;

  const id = 1;

  final tComment = Comment(
    id: id,
    time: 0,
    score: 1,
    parent: 1,
    deleted: false,
    dead: false,
    hidden: false,
    by: 'by',
    text: 'text',
    kids: const <int>[],
    level: 1,
  );

  setUp(() {
    dataService = DataService();

    return Future(() async {
      await dataService.initForTests();
    });
  });

  tearDown(() {
    return Future(() async {
      await dataService.close();
    });
  });

  test('add one comment', () async {
    await dataService.cacheComment(tComment);

    final cached = await dataService.getCachedComment(id: id);
    expect(cached!.id, id);
  });
}
