import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

part 'filter_state.dart';

class FilterCubit extends Cubit<FilterState> {
  FilterCubit(this._settingsService) : super(FilterState.init()) {
    init();
  }

  final SettingsService _settingsService;

  void init() {
    final keywords = _settingsService.filterKeywords;
    emit(state.copyWith(keywords: keywords.toSet()));
  }

  void addKeyword(String keyword) {
    final updated = Set<String>.from(state.keywords)..add(keyword);
    emit(state.copyWith(keywords: updated));
    _settingsService.updateFilterKeywords(updated.toList(growable: false));
  }

  void removeKeyword(String keyword) {
    final updated = Set<String>.from(state.keywords)..remove(keyword);
    emit(state.copyWith(keywords: updated));
    _settingsService.updateFilterKeywords(updated.toList(growable: false));
  }
}
