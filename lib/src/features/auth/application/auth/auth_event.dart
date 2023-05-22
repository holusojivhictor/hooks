part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.init() = _Init;

  const factory AuthEvent.login({
    required String username,
    required String password,
  }) = _Login;

  const factory AuthEvent.agreeToEULAChanged() = _AgreeToEULAChanged;

  const factory AuthEvent.flag({
    required Item item,
  }) = _Flag;

  const factory AuthEvent.logout() = _Logout;
}
