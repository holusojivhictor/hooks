import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'blocklist_state.dart';

class BlocklistCubit extends Cubit<BlocklistState> {
  BlocklistCubit(this._settingsService) : super(BlocklistState.init());

  final SettingsService _settingsService;

  void init() {
    final blocklist = _settingsService.blocklist;
    emit(state.copyWith(blocklist: blocklist));
  }

  void addToBlocklist(String username) {
    final updated = List<String>.from(state.blocklist)..add(username);
    emit(state.copyWith(blocklist: updated));
    _settingsService.updateBlocklist(updated);
  }

  void removeFromBlocklist(String username) {
    final updated = List<String>.from(state.blocklist)..remove(username);
    emit(state.copyWith(blocklist: updated));
    _settingsService.updateBlocklist(updated);
  }
}
