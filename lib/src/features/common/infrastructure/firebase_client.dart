import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';

class FirebaseClient {
  FirebaseClient(
    this.credential, {
    Client? client,
  }) : _client = client ?? Client();

  FirebaseClient.anonymous({
    Client? client,
  })  : credential = null,
        _client = client ?? Client();

  final String? credential;
  final Client _client;

  Future<dynamic> get(dynamic uri) => send('GET', uri);

  Future<dynamic> put(dynamic uri, dynamic json) => send('PUT', uri, json: json);

  Future<dynamic> post(dynamic uri, dynamic json) => send('POST', uri, json: json);

  Future<dynamic> patch(dynamic uri, dynamic json) => send('PATCH', uri, json: json);

  Future<void> delete(dynamic uri) => send('DELETE', uri);

  Future<Object?> send(String method, dynamic url, {dynamic json}) async {
    final uri = url is String ? Uri.parse(url) : url as Uri;

    final request = Request(method, uri);
    if (credential != null) {
      request.headers['Authorization'] = 'Bearer $credential';
    }

    if (json != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(json);
    }

    final streamedResponse = await _client.send(request);
    final response = await Response.fromStream(streamedResponse);

    Object? bodyJson;
    try {
      bodyJson = jsonDecode(response.body);
    } on FormatException {
      final contentType = response.headers['content-type'];
      if (contentType != null && !contentType.contains('application/json')) {
        throw Exception(
          "Returned value was not JSON. Did the uri end with '.json'?",
        );
      }
      rethrow;
    }

    if (response.statusCode != 200) {
      if (bodyJson is Map) {
        final dynamic error = bodyJson['error'];
        if (error != null) {
          throw FirebaseClientException(response.statusCode, error.toString());
        }
      }

      throw FirebaseClientException(response.statusCode, bodyJson.toString());
    }

    return bodyJson;
  }

  void close() => _client.close();
}

class FirebaseClientException implements Exception {
  FirebaseClientException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => '$message ($statusCode)';
}
