import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  final storiesService = MockStoriesService();

  const created = 0;
  const delay = 1;
  const karma = 2;
  const about = 'about';
  const id = 'id';

  const tUser = User(
    about: about,
    created: created,
    delay: delay,
    id: id,
    karma: karma,
  );

  test('Initial state is UserState.init', () {
    final userCubit = UserCubit(storiesService);
    expect(userCubit.state, const UserState.init());
  });

  group('UserCubit', () {
    blocTest<UserCubit, UserState>(
      'initialize with user',
      setUp: () {
        when(
          () => storiesService.fetchUser(id: id),
        ).thenAnswer((_) async => tUser);
      },
      build: () => UserCubit(storiesService),
      act: (cubit) => cubit.init(userId: id),
      skip: 1,
      expect: () => <UserState>[
        const UserState.init().copyWith(
          user: tUser,
          status: UserStatus.loaded,
        ),
      ],
      verify: (_) {
        verify(() => storiesService.fetchUser(id: id));
      },
    );

    blocTest<UserCubit, UserState>(
      'initialize with no user',
      setUp: () {
        when(
          () => storiesService.fetchUser(id: id),
        ).thenAnswer((_) async => null);
      },
      build: () => UserCubit(storiesService),
      act: (cubit) => cubit.init(userId: id),
      skip: 1,
      expect: () => <UserState>[
        const UserState.init().copyWith(
          user: const User.emptyWithId(id),
          status: UserStatus.loaded,
        ),
      ],
    );

    blocTest<UserCubit, UserState>(
      'initialize fails',
      setUp: () {
        when(
          () => storiesService.fetchUser(id: id),
        ).thenAnswer((_) async => Exception('oops') as User?);
      },
      build: () => UserCubit(storiesService),
      act: (cubit) => cubit.init(userId: id),
      skip: 1,
      expect: () => <UserState>[
        const UserState.init().copyWith(
          status: UserStatus.failure,
        ),
      ],
    );
  });
}
