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
      _send((token) => _inner.get(
            _buildUri(path, query, token),
            headers: _buildHeaders(token),
          ));

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) =>
      _send((token) => _inner.post(
            _buildUri(path, query, token),
            headers: _buildHeaders(token),
            body: body == null ? null : jsonEncode(body),
          ));

  /// Reads the token here rather than in [get] and [post] so a failing
  /// TokenStorage is caught by the same mapping as a failing request, and so
  /// the decoder can say whether the call went out authenticated.
  Future<Map<String, dynamic>> _send(
      Future<http.Response> Function(String? token) request) async {
    try {
      final token = await _tokenStorage.getToken();
      final response = await request(token);
      return _decode(response,
          authenticated: token != null && token.isNotEmpty);
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

  /// FFSS authenticates on the `token` query parameter its documentation lists
  /// on every endpoint — and *only* on that. `GET /me` carrying nothing but the
  /// Bearer header answers "Utilisateur Anonyme", word for word what it answers
  /// with no credentials at all, so a request without this parameter is an
  /// anonymous request. Reads still return their public data, which is why the
  /// app looked fine until a write asked for a real identity and got back
  /// "Invalid Token".
  ///
  /// A token in a URL does end up in server logs and proxies. The API leaves no
  /// alternative.
  Uri _buildUri(String path, Map<String, dynamic>? query, String? token) {
    final base = _trimSlashes(_config.baseUrl);
    final version = _trimSlashes(_config.apiVersion);
    final cleanPath = _trimSlashes(path);
    final fullPath = '$base/$version/$cleanPath';

    // Values are stringified, except Iterables which are kept as such so that
    // Uri emits one repeated key per entry — FFSS expects PHP array notation
    // (`categories[]=10&categories[]=24`), and a flattened list would arrive
    // as the literal "[10, 24]".
    final filtered = <String, dynamic>{};
    if (token != null && token.isNotEmpty) filtered['token'] = token;
    query?.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable) {
        final entries = value.map((v) => v.toString()).toList();
        if (entries.isNotEmpty) filtered[key] = entries;
      } else {
        filtered[key] = value.toString();
      }
    });

    final uri = Uri.parse(fullPath);
    return filtered.isEmpty ? uri : uri.replace(queryParameters: filtered);
  }

  String _trimSlashes(String s) => s.replaceAll(RegExp(r'^/+|/+$'), '');

  /// The Bearer header is kept beside the query parameter even though FFSS
  /// ignores it on `/me`: it costs nothing, and only that one endpoint has been
  /// checked. The query parameter is what actually authenticates.
  Map<String, String> _buildHeaders(String? token) {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _decode(
    http.Response response, {
    required bool authenticated,
  }) {
    final status = response.statusCode;

    // Decode bytes as UTF-8 ourselves. `response.body` uses the charset from
    // the response Content-Type header, and FFSS omits it — so `http` falls
    // back to latin-1 and mangles accented characters (é → Ã©).
    final rawBody = utf8.decode(response.bodyBytes, allowMalformed: true);

    if (status == 401) {
      _notifyAuthFailure();
      throw AuthException(_extractMessage(rawBody) ?? 'Unauthorized');
    }

    if (status >= 400) {
      throw ApiException(
        _extractMessage(rawBody) ?? 'HTTP $status',
        statusCode: status,
        authenticated: authenticated,
      );
    }

    final dynamic body;
    try {
      body = jsonDecode(rawBody);
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON: ${e.message}',
          statusCode: status, authenticated: authenticated);
    }

    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape',
          statusCode: status, authenticated: authenticated);
    }

    if (body['success'] == false) {
      throw ApiException(
        body['message']?.toString() ?? 'API returned success: false',
        statusCode: status,
        code: body['code']?.toString(),
        authenticated: authenticated,
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
