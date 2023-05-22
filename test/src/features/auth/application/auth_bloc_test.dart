import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  final authService = MockAuthService();
  final settingsService = MockSettingsService();
  final storiesService = MockStoriesService();
  final dataService = MockDataService();

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

  group(
    'AuthBloc',
    () {
      setUp(() {
        when(() => authService.loggedIn).thenAnswer((_) async => false);
      });

      test(
        'initial state is AuthState.init',
        () {
          expect(
            AuthBloc(
              authService,
              settingsService,
              storiesService,
              dataService,
            ).state,
            const AuthState.init(),
          );
        },
      );
    },
  );

  group('AuthStarted', () {
    const username = 'username';
    const password = 'password';
    setUp(() {
      when(() => authService.username)
          .thenAnswer((_) => Future<String?>.value(username));
      when(() => authService.password).thenAnswer((_) async => password);
      when(() => storiesService.fetchUser(id: username))
          .thenAnswer((_) async => tUser);
      when(() => authService.loggedIn).thenAnswer((_) async => false);
    });

    blocTest<AuthBloc, AuthState>(
      'initialize',
      build: () {
        return AuthBloc(
          authService,
          settingsService,
          storiesService,
          dataService,
        );
      },
      expect: () => <AuthState>[
        const AuthState.init().copyWith(
          status: AuthStatus.loaded,
        ),
      ],
      verify: (_) {
        verify(() => authService.loggedIn).called(2);
        verifyNever(() => authService.username);
        verifyNever(() => storiesService.fetchUser(id: username));
      },
    );

    blocTest<AuthBloc, AuthState>(
      'sign in',
      build: () {
        when(
          () => authService.login(
            username: username,
            password: password,
          ),
        ).thenAnswer((_) async => true);
        return AuthBloc(
          authService,
          settingsService,
          storiesService,
          dataService,
        );
      },
      act: (bloc) => bloc
        ..add(
          const AuthEvent.agreeToEULAChanged(),
        )
        ..add(
          const AuthEvent.login(
            username: username,
            password: password,
          ),
        ),
      expect: () => <AuthState>[
        const AuthState(
          user: User.empty(),
          isLoggedIn: false,
          status: AuthStatus.loaded,
          agreedToEULA: false,
        ),
        const AuthState(
          user: User.empty(),
          isLoggedIn: false,
          status: AuthStatus.loaded,
          agreedToEULA: true,
        ),
        const AuthState(
          user: User.empty(),
          isLoggedIn: false,
          status: AuthStatus.loading,
          agreedToEULA: true,
        ),
        const AuthState(
          user: tUser,
          isLoggedIn: true,
          status: AuthStatus.loaded,
          agreedToEULA: true,
        ),
      ],
      verify: (_) {
        verify(
          () => authService.login(
            username: username,
            password: password,
          ),
        ).called(1);
        verify(() => storiesService.fetchUser(id: username)).called(1);
      },
    );
  });
}
