import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';

class HttpClient {
  HttpClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    http.Client? inner,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _inner = inner ?? http.Client();

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final http.Client _inner;

  Future<void> Function()? _onAuthFailure;

  /// Fired when the server returns 401 (session expired / token invalid).
  /// The handler runs fire-and-forget; errors inside it are swallowed so the
  /// `AuthException` always propagates to the caller. Wired in
  /// `InitialBinding` to logout + navigate to the login screen.
  set onAuthFailure(Future<void> Function() handler) =>
      _onAuthFailure = handler;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(() async {
        final uri = _buildUri(path, query);
        final headers = await _buildHeaders();
        return _inner.get(uri, headers: headers);
      });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) =>
      _send(() async {
        final uri = _buildUri(path, query);
        final headers = await _buildHeaders();
        return _inner.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        );
      });

  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();
      return _decode(response);
    } on AppException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(e.message ?? 'Request timed out');
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final base = _trimSlashes(_config.baseUrl);
    final version = _trimSlashes(_config.apiVersion);
    final cleanPath = _trimSlashes(path);
    final fullPath = '$base/$version/$cleanPath';

    final filtered = <String, String>{};
    query?.forEach((key, value) {
      if (value != null) filtered[key] = value.toString();
    });

    final uri = Uri.parse(fullPath);
    return filtered.isEmpty ? uri : uri.replace(queryParameters: filtered);
  }

  String _trimSlashes(String s) => s.replaceAll(RegExp(r'^/+|/+$'), '');

  Future<Map<String, String>> _buildHeaders() async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final status = response.statusCode;

    if (status == 401) {
      _notifyAuthFailure();
      throw AuthException(_extractMessage(response.body) ?? 'Unauthorized');
    }

    if (status >= 400) {
      throw ApiException(
        _extractMessage(response.body) ?? 'HTTP $status',
        statusCode: status,
      );
    }

    final dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON: ${e.message}', statusCode: status);
    }

    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape', statusCode: status);
    }

    if (body['success'] == false) {
      throw ApiException(
        body['message']?.toString() ?? 'API returned success: false',
        statusCode: status,
        code: body['code']?.toString(),
      );
    }

    return body;
  }

  void _notifyAuthFailure() {
    final cb = _onAuthFailure;
    if (cb == null) return;
    // Fire-and-forget; swallow errors so the AuthException always propagates.
    cb().catchError((Object _) {});
  }

  String? _extractMessage(String rawBody) {
    try {
      final dynamic decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'];
        if (msg is String) return msg;
      }
    } on FormatException {
      // Body wasn't JSON. Fall through.
    }
    return null;
  }
}
