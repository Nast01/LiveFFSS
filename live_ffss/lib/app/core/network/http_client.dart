import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/http_log.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';

class HttpClient {
  HttpClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    http.Client? inner,
    Duration requestTimeout = defaultRequestTimeout,
  })  : _config = config,
        _tokenStorage = tokenStorage,
        _inner = inner ?? http.Client(),
        _requestTimeout = requestTimeout;

  /// Delai au-dela duquel une requete FFSS est declaree perdue.
  static const Duration defaultRequestTimeout = Duration(seconds: 30);

  final AppConfig _config;
  final TokenStorage _tokenStorage;
  final http.Client _inner;
  final Duration _requestTimeout;

  Future<void> Function()? _onAuthFailure;

  /// Fired when the session is over — a 401, or the 403 "Invalid token" FFSS
  /// actually uses (see [_decode]).
  /// The handler runs fire-and-forget; errors inside it are swallowed so the
  /// `AuthException` always propagates to the caller. Wired in
  /// `InitialBinding` to logout + navigate to the login screen.
  set onAuthFailure(Future<void> Function() handler) =>
      _onAuthFailure = handler;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) =>
      _send(
        method: 'GET',
        path: path,
        query: query,
        send: (uri, headers) => _inner.get(uri, headers: headers),
      );

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) =>
      _send(
        method: 'POST',
        path: path,
        query: query,
        body: body,
        send: (uri, headers) => _inner.post(
          uri,
          headers: headers,
          body: body == null ? null : jsonEncode(body),
        ),
      );

  /// Reads the token here rather than in [get] and [post] so a failing
  /// TokenStorage is caught by the same mapping as a failing request, and so
  /// the decoder can say whether the call went out authenticated.
  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    required Future<http.Response> Function(
            Uri uri, Map<String, String> headers)
        send,
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final started = DateTime.now();
    Uri? uri;
    try {
      final token = await _tokenStorage.getToken();
      uri = _buildUri(path, query, token);
      // Arme le delai que le `catch` ci-dessous attrape. Sans lui ce `catch`
      // etait inatteignable : `http` n'en pose aucun, donc une socket que le
      // serveur laisse pendre ne revenait jamais et l'ecran appelant tournait
      // en rond pour toujours, sans erreur a afficher.
      final response =
          await send(uri, _buildHeaders(token)).timeout(_requestTimeout);
      _record(started, method, uri, body, response: response);
      return _decode(response,
          authenticated: token != null && token.isNotEmpty);
    } on AppException {
      // Déjà journalisée : l'entrée écrite juste avant `_decode` porte le
      // statut et le corps qui expliquent le refus. La ré-enregistrer ici en
      // ferait un doublon.
      rethrow;
    } on SocketException catch (e) {
      _record(started, method, uri, body, error: e.message);
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      final message = e.message ?? 'Request timed out';
      _record(started, method, uri, body, error: message);
      throw NetworkException(message);
    } catch (e) {
      _record(started, method, uri, body, error: e.toString());
      throw UnknownException(e.toString());
    }
  }

  /// Le corps est décodé en UTF-8 comme dans [_decode] : un journal qui
  /// afficherait des accents mangés ne servirait justement pas à diagnostiquer
  /// le bug d'encodage qu'il est là pour montrer.
  ///
  /// Sort avant tout travail quand le journal est éteint — c'est ce qui rend
  /// son coût nul par défaut.
  void _record(
    DateTime started,
    String method,
    Uri? uri,
    Object? requestBody, {
    http.Response? response,
    String? error,
  }) {
    if (!httpLog.enabled) return;
    // Appelé depuis le `catch` générique de `_send` : une exception levée ici
    // (ex. `jsonEncode` sur un corps non sérialisable) sortirait de tout
    // `try`, et le journal ferait échouer une requête par ailleurs valide.
    // Le journal de debug ne doit structurellement jamais pouvoir faire ça.
    try {
      httpLog.record(HttpLogEntry(
        at: started,
        method: method,
        url: uri?.toString() ?? '(URI non construite)',
        durationMs: DateTime.now().difference(started).inMilliseconds,
        statusCode: response?.statusCode,
        requestBody: HttpLog.truncate(
          requestBody == null ? null : jsonEncode(requestBody),
        ),
        responseBody: response == null
            ? null
            : HttpLog.truncate(
                utf8.decode(response.bodyBytes, allowMalformed: true),
              ),
        error: error,
      ));
    } catch (_) {}
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

    // FFSS never answers 401. A write carrying a dead token comes back as
    // `403 {"error":"Forbiden","message":"Invalid token"}`, while a read with
    // that same dead token is served anonymously as a 200 — so nothing else in
    // the app can tell that the session is over, and the operator keeps a token
    // they believe good while every write fails as if the server were at fault.
    //
    // Matched on the wording rather than on the status alone: a 403 is also how
    // a genuine refusal arrives, and signing someone out because one action was
    // denied would be worse than reporting the denial.
    final message = _extractMessage(rawBody);
    if (status == 403 &&
        (message?.toLowerCase().contains('invalid token') ?? false)) {
      _notifyAuthFailure();
      throw AuthException(message!);
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

    // Every FFSS delete endpoint answers with a bare `true` rather than the
    // usual envelope — checked in production on créneau, partie and réunion
    // deletes, each `HTTP 201` with a body of exactly `true`. Rejecting that
    // shape made a deletion that had genuinely succeeded look like a failure:
    // the item stayed on screen, an error was shown, and only a refresh
    // revealed the server had dropped it all along.
    //
    // Normalised rather than returned outright, so a bare `false` still falls
    // through to the refusal check below instead of passing for a success.
    final decoded = body is bool ? <String, dynamic>{'success': body} : body;

    if (decoded is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape',
          statusCode: status, authenticated: authenticated);
    }

    if (decoded['success'] == false) {
      throw ApiException(
        decoded['message']?.toString() ?? 'API returned success: false',
        statusCode: status,
        code: decoded['code']?.toString(),
        authenticated: authenticated,
      );
    }

    return decoded;
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
