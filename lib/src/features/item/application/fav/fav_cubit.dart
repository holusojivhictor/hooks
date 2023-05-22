import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/auth/application/bloc.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

part 'fav_state.dart';

class FavCubit extends Cubit<FavState> {
  FavCubit(
    this._authService,
    this._settingsService,
    this._storiesService,
    this._authBloc,
  ) : super(FavState.init()) {
    init();
  }

  final AuthService _authService;
  final SettingsService _settingsService;
  final StoriesService _storiesService;
  final AuthBloc _authBloc;
  static const int _pageSize = 20;
  String? _username;

  void init() {
    _authBloc.stream.listen((AuthState authState) {
      if (authState.username != _username) {
        final favIds = _settingsService.favList(of: authState.username);
        emit(
          state.copyWith(
            favIds: favIds,
            favItems: <Item>[],
            currentPage: 0,
          ),
        );

        _storiesService
            .fetchItemsStream(
              ids: favIds.sublist(0, _pageSize.clamp(0, favIds.length)),
            )
            .listen(_onItemLoaded)
            .onDone(() {
          emit(
            state.copyWith(
              status: FavStatus.loaded,
            ),
          );
        });

        _username = authState.username;
      }
    });
  }

  Future<void> addFav(int id) async {
    final username = _authBloc.state.username;

    _settingsService.addFav(username: username, id: id);

    emit(
      state.copyWith(
        favIds: List<int>.from(state.favIds)..add(id),
      ),
    );

    final item = await _storiesService.fetchItem(id: id);

    if (item == null) return;

    emit(
      state.copyWith(
        favItems: List<Item>.from(state.favItems)..insert(0, item),
      ),
    );

    if (_authBloc.state.isLoggedIn) {
      await _authService.favorite(id: id, favorite: true);
    }
  }

  Future<void> removeFav(int id) async {
    final username = _authBloc.state.username;

    _settingsService.removeFav(username: username, id: id);

    emit(
      state.copyWith(
        favIds: List<int>.from(state.favIds)..remove(id),
        favItems: List<Item>.from(state.favItems)
          ..removeWhere((Item e) => e.id == id),
      ),
    );

    if (_authBloc.state.isLoggedIn) {
      await _authService.favorite(id: id, favorite: false);
    }
  }

  void loadMore() {
    emit(state.copyWith(status: FavStatus.loading));
    final currentPage = state.currentPage;
    final len = state.favIds.length;
    emit(state.copyWith(currentPage: currentPage + 1));
    final lower = _pageSize * (currentPage + 1);
    var upper = _pageSize + lower;

    if (len > lower) {
      if (len < upper) {
        upper = len;
      }

      _storiesService
          .fetchItemsStream(
            ids: state.favIds.sublist(
              lower,
              upper,
            ),
          )
          .listen(_onItemLoaded)
          .onDone(() {
        emit(state.copyWith(status: FavStatus.loaded));
      });
    } else {
      emit(state.copyWith(status: FavStatus.loaded));
    }
  }

  void refresh() {
    final username = _authBloc.state.username;

    emit(
      state.copyWith(
        status: FavStatus.loading,
        currentPage: 0,
        favItems: <Item>[],
        favIds: <int>[],
      ),
    );

    final favIds = _settingsService.favList(of: username);
    emit(state.copyWith(favIds: favIds));

    _storiesService
        .fetchItemsStream(
          ids: favIds.sublist(0, _pageSize.clamp(0, favIds.length)),
        )
        .listen(_onItemLoaded)
        .onDone(() {
      emit(state.copyWith(status: FavStatus.loaded));
    });
  }

  void removeAll() {
    _settingsService
      ..clearAllFavs(username: '')
      ..clearAllFavs(username: _authBloc.state.username);
    emit(FavState.init());
  }

  void _onItemLoaded(Item item) {
    emit(
      state.copyWith(
        favItems: List<Item>.from(state.favItems)..add(item),
      ),
    );
  }
}
