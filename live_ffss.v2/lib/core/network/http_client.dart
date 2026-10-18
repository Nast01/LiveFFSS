import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';

class HttpClient {
  HttpClient({
    required AppConfig config,
    required TokenStorage tokenStorage,
    http.Client? inner,
    Duration requestTimeout = defaultRequestTimeout,
  }) : _config = config,
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
  /// `AuthException` always propagates to the caller. Wired by
  /// `SessionNotifier` (`features/auth/session.dart`), which closes the
  /// session and marks it expired.
  set onAuthFailure(Future<void> Function() handler) =>
      _onAuthFailure = handler;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(
    method: 'GET',
    path: path,
    query: query,
    send: (uri, headers) => _inner.get(uri, headers: headers),
  );

  /// [body] part en JSON ; [form] part en formulaire encodé, pour ce qui ne
  /// doit jamais apparaître dans l'adresse (un mot de passe : l'adresse finit
  /// dans les journaux du serveur et des relais). Les écritures FFSS, elles,
  /// prennent leurs paramètres dans [query] : un corps JSON y répond HTTP 500.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    Map<String, String>? form,
  }) {
    assert(body == null || form == null, 'body et form sont exclusifs');
    return _send(
      method: 'POST',
      path: path,
      query: query,
      body: body,
      contentType: form == null ? _jsonContentType : _formContentType,
      send: (uri, headers) => _inner.post(
        uri,
        headers: headers,
        body: form != null
            ? Uri(queryParameters: form).query
            : body == null
            ? null
            : jsonEncode(body),
      ),
    );
  }

  static const _jsonContentType = 'application/json; charset=UTF-8';
  static const _formContentType =
      'application/x-www-form-urlencoded; charset=UTF-8';

  /// Reads the token here rather than in [get] and [post] so a failing
  /// TokenStorage is caught by the same mapping as a failing request, and so
  /// the decoder can say whether the call went out authenticated.
  Future<Map<String, dynamic>> _send({
    required String method,
    required String path,
    required Future<http.Response> Function(
      Uri uri,
      Map<String, String> headers,
    )
    send,
    Map<String, dynamic>? query,
    Object? body,
    String contentType = _jsonContentType,
  }) async {
    try {
      final token = await _tokenStorage.getToken();
      final uri = _buildUri(path, query, token);
      // Arme le délai que le `catch` ci-dessous attrape : `http` n'en pose
      // aucun, donc une socket que le serveur laisse pendre ne revenait jamais
      // et l'écran appelant tournait en rond pour toujours.
      final response = await send(
        uri,
        _buildHeaders(token, contentType),
      ).timeout(_requestTimeout);
      return _decode(
        response,
        authenticated: token != null && token.isNotEmpty,
      );
    } on AppException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException(e.message);
    } on TimeoutException catch (e) {
      throw NetworkException(e.message ?? 'Request timed out');
    } on http.ClientException catch (e) {
      // Ce que le web lève à la place de SocketException, qui n'y existe pas.
      throw NetworkException(e.message);
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
  Map<String, String> _buildHeaders(String? token, String contentType) {
    final headers = {'Content-Type': contentType, 'Accept': 'application/json'};
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
        message ?? 'HTTP $status',
        statusCode: status,
        authenticated: authenticated,
        // Une erreur sans corps JSON vient d'un proxy, d'un portail ou d'une
        // panne, pas d'un refus formulé par FFSS.
        malformedResponse: !_isJsonObject(rawBody),
      );
    }

    final dynamic body;
    try {
      body = jsonDecode(rawBody);
    } on FormatException catch (e) {
      // Le portail captif d'un Wi-Fi sert sa page de connexion en 200.
      throw ApiException(
        'Invalid JSON: ${e.message}',
        statusCode: status,
        authenticated: authenticated,
        malformedResponse: true,
      );
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
      throw ApiException(
        'Unexpected response shape',
        statusCode: status,
        authenticated: authenticated,
        malformedResponse: true,
      );
    }

    // Un refus se dit `false` ou `"false"` selon la route (doc FFSS, §1), et
    // `"false"` est une chaine non vide — donc veridique en Dart. Un refus
    // formule ainsi passait pour un succes, et l'appelant lisait une reponse
    // vide comme un resultat.
    if (_isRefused(decoded['success'])) {
      throw ApiException(
        decoded['message']?.toString() ?? 'API returned success: false',
        statusCode: status,
        code: decoded['code']?.toString(),
        authenticated: authenticated,
      );
    }

    return decoded;
  }

  /// Seul un refus explicite compte : `true`, `"true"` ou un champ absent
  /// valent tous succes — l'enveloppe FFSS omet `success` sur une bonne partie
  /// de ses routes.
  static bool _isRefused(Object? success) =>
      success == false || success == 'false';

  void _notifyAuthFailure() {
    final cb = _onAuthFailure;
    if (cb == null) return;
    // Fire-and-forget; swallow errors so the AuthException always propagates.
    cb().catchError((Object _) {});
  }

  static bool _isJsonObject(String rawBody) {
    try {
      return jsonDecode(rawBody) is Map<String, dynamic>;
    } on FormatException {
      return false;
    }
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
