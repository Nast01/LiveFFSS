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

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    final response = await _inner.get(uri, headers: headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final uri = _buildUri(path, query);
    final headers = await _buildHeaders();
    final response = await _inner.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
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

  String _trimSlashes(String s) {
    var out = s;
    while (out.startsWith('/')) {
      out = out.substring(1);
    }
    while (out.endsWith('/')) {
      out = out.substring(0, out.length - 1);
    }
    return out;
  }

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

    final dynamic body;
    try {
      body = jsonDecode(response.body);
    } on FormatException catch (e) {
      throw ApiException('Invalid JSON: ${e.message}', statusCode: status);
    }

    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response shape', statusCode: status);
    }

    return body;
  }
}
