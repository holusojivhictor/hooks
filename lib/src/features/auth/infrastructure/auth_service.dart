import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

class AuthService extends PostableService {
  AuthService(this._logger, this._settingsService);

  final SettingsService _settingsService;
  final LoggingService _logger;

  Future<bool> get loggedIn async => _settingsService.loggedIn;

  Future<String?> get username async => _settingsService.username;

  Future<String?> get password async => _settingsService.password;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.https(authority, 'login');
    final PostDataMixin data = LoginPostData(
      acct: username,
      pw: password,
      goto: 'news',
    );

    final success = await performDefaultPost(uri, data);

    if (success) {
      try {
        await _settingsService.setAuth(
          username: username,
          password: password,
        );
      } catch (_) {
        _logger.error(runtimeType, 'unknown');
        return false;
      }
    }

    return success;
  }

  Future<bool> hasLoggedIn() => _settingsService.loggedIn;

  Future<void> logout() async {
    await _settingsService.removeAuth();
  }

  Future<bool> flag({
    required int id,
    required bool flag,
  }) async {
    final uri = Uri.https(authority, 'flag');
    final username = await _settingsService.username;
    final password = await _settingsService.password;
    final PostDataMixin data = FlagPostData(
      acct: username!,
      pw: password!,
      id: id,
      un: flag ? null : 't',
    );

    return performDefaultPost(uri, data);
  }

  Future<bool> favorite({
    required int id,
    required bool favorite,
  }) async {
    final uri = Uri.https(authority, 'fave');
    final username = await _settingsService.username;
    final password = await _settingsService.password;
    final PostDataMixin data = FavoritePostData(
      acct: username!,
      pw: password!,
      id: id,
      un: favorite ? null : 't',
    );

    return performDefaultPost(uri, data);
  }

  Future<bool> upvote({
    required int id,
    required bool upvote,
  }) async {
    final uri = Uri.https(authority, 'vote');
    final username = await _settingsService.username;
    final password = await _settingsService.password;
    final PostDataMixin data = VotePostData(
      acct: username!,
      pw: password!,
      id: id,
      how: upvote ? 'up' : 'un',
    );

    return performDefaultPost(uri, data);
  }

  Future<bool> downvote({
    required int id,
    required bool downvote,
  }) async {
    final uri = Uri.https(authority, 'vote');
    final username = await _settingsService.username;
    final password = await _settingsService.password;
    final PostDataMixin data = VotePostData(
      acct: username!,
      pw: password!,
      id: id,
      how: downvote ? 'down' : 'un',
    );

    return performDefaultPost(uri, data);
  }
}
