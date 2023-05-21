import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/auth/application/auth_bloc.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'vote_state.dart';

class VoteCubit extends Cubit<VoteState> {
  VoteCubit(
    this._authService,
    this._settingsService,
    this._authBloc, {
    required Item item,
  }) : super(VoteState.init(item: item));

  final AuthService _authService;
  final SettingsService _settingsService;
  final AuthBloc _authBloc;
  static const int _karmaThreshold = 501;
}
