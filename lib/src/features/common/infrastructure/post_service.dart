import 'dart:io';

import 'package:hooks/src/features/common/domain/models/models.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/utils/utils.dart';

class PostService extends PostableService {
  PostService(this._settingsService, {super.dio});

  final SettingsService _settingsService;

  Future<bool> comment({
    required int parentId,
    required String text,
  }) async {
    final username = await _settingsService.username;
    final password = await _settingsService.password;
    final uri = Uri.https(authority, 'comment');

    if (username == null || password == null) {
      return false;
    }

    final PostDataMixin data = CommentPostData(
      acct: username,
      pw: password,
      parent: parentId,
      text: text,
    );

    return performDefaultPost(
      uri,
      data,
      validateLocation: (String? location) => location == '/',
    );
  }

  Future<bool> submit({
    required String title,
    String? url,
    String? text,
  }) async {
    final username = await _settingsService.username;
    final password = await _settingsService.password;

    if (username == null || password == null) {
      return false;
    }

    final formResponse = await getFormResponse(
      username: username,
      password: password,
      path: 'submitlink',
    );
    final formValues = HtmlUtils.getHiddenFormValues(formResponse.data);

    if (formValues == null || formValues.isEmpty) {
      return false;
    }

    final cookie = formResponse.headers.value(HttpHeaders.setCookieHeader);

    final uri = Uri.https(authority, 'r');
    final PostDataMixin data = SubmitPostData(
      fnid: formValues['fnid']!,
      fnop: formValues['fnop']!,
      title: title,
      url: url,
      text: text,
    );

    return performDefaultPost(
      uri,
      data,
      cookie: cookie,
      validateLocation: (String? location) => location == '/newest',
    );
  }

  Future<bool> edit({
    required int id,
    String? text,
  }) async {
    final username = await _settingsService.username;
    final password = await _settingsService.password;

    if (username == null || password == null) {
      return false;
    }

    final formResponse = await getFormResponse(
      username: username,
      password: password,
      id: id,
      path: 'edit',
    );
    final formValues = HtmlUtils.getHiddenFormValues(formResponse.data);

    if (formValues == null || formValues.isEmpty) {
      return false;
    }

    final cookie = formResponse.headers.value(HttpHeaders.setCookieHeader);

    final uri = Uri.https(authority, 'xedit');
    final PostDataMixin data = EditPostData(
      hmac: formValues['hmac']!,
      id: id,
      text: text,
    );

    return performDefaultPost(
      uri,
      data,
      cookie: cookie,
    );
  }
}
