import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

part 'auth_bloc.freezed.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authService,
    this._settingsService,
    this._storiesService,
    this._dataService,
  ) : super(const AuthState.init()) {
    on<_Init>(_onInit);
    on<_Login>(_onLogin);
    on<_AgreeToEULAChanged>(_onAgreeToEULAChanged);
    on<_Flag>(_onFlag);
    on<_Logout>(_onLogout);
    add(const AuthEvent.init());
  }

  final AuthService _authService;
  final SettingsService _settingsService;
  final StoriesService _storiesService;
  final DataService _dataService;

  Future<void> _onInit(_Init event, Emitter<AuthState> emit) async {
    await _authService.loggedIn.then((bool loggedIn) async {
      if (loggedIn) {
        final username = await _authService.username;
        var user = await _storiesService.fetchUser(id: username!);

        user ??= User.emptyWithId(username);

        emit(
          state.copyWith(
            isLoggedIn: true,
            user: user,
            status: AuthStatus.loaded,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoggedIn: false,
            status: AuthStatus.loaded,
          ),
        );
      }
    });
  }

  void _onAgreeToEULAChanged(
    _AgreeToEULAChanged event,
    Emitter<AuthState> emit,
  ) {
    emit(state.copyWith(agreedToEULA: !state.agreedToEULA));
  }

  Future<void> _onFlag(_Flag event, Emitter<AuthState> emit) async {
    if (state.isLoggedIn) {
      final flagged = event.item.dead;
      await _authService.flag(id: event.item.id, flag: !flagged);
    }
  }

  Future<void> _onLogin(_Login event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final success = await _authService.login(
      username: event.username,
      password: event.password,
    );

    if (success) {
      final user = await _storiesService.fetchUser(id: event.username);
      emit(
        state.copyWith(
          user: user ?? User.emptyWithId(event.username),
          isLoggedIn: true,
          status: AuthStatus.loaded,
        ),
      );
    } else {
      emit(state.copyWith(status: AuthStatus.failure));
    }
  }

  Future<void> _onLogout(_Logout event, Emitter<AuthState> emit) async {
    emit(
      state.copyWith(
        user: const User.empty(),
        isLoggedIn: false,
        agreedToEULA: false,
      ),
    );

    await _authService.logout();
    _settingsService.updateUnreadCommentsIds(<int>[]);
    await _dataService.deleteAll();
  }
}
