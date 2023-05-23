import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/models/data/item/item.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../../helpers.dart';
import '../../../../../mocks.dart';

void main() {
  initHydratedStorage();

  final draftCache = MockDraftCache();

  test('Initial state is EditState.init', () {
    final editCubit = EditCubit(draftCache);
    expect(editCubit.state, const EditState.init());
  });

  group('EditCubit', () {
    blocTest<EditCubit, EditState>(
      'reply tapped',
      setUp: () {
        when(
          () => draftCache.getDraft(replyingTo: tItem.id),
        ).thenAnswer((_) => 'random');
      },
      build: () => EditCubit(draftCache),
      act: (cubit) => cubit.onReplyTapped(tItem),
      expect: () => <EditState>[
        const EditState(
          replyingTo: tItem,
          text: 'random',
        ),
      ],
    );

    blocTest<EditCubit, EditState>(
      'reply submitted',
      setUp: () {
        when(
          () => draftCache.removeDraft(replyingTo: tItem.id),
        ).thenAnswer((_) {});
      },
      build: () => EditCubit(draftCache),
      act: (cubit) => cubit
        ..onReplyTapped(tItem)
        ..onReplySubmittedSuccessfully(),
      skip: 1,
      expect: () => <EditState>[
        const EditState.init(),
      ],
    );
  });
}

const tItem = Item(
  id: 1,
  score: 1,
  descendants: 0,
  time: 0,
  by: 'by',
  title: 'title',
  url: 'url',
  kids: <int>[],
  parts: <int>[],
  dead: false,
  deleted: false,
  hidden: false,
  parent: 0,
  text: 'text',
  type: 'story',
);
