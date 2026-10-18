import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';

abstract class AuthRepository {
  /// Le jeton d'un compte FFSS. Lève une [AppException] si les identifiants
  /// sont refusés.
  Future<String> requestToken(String login, String password);

  /// Le compte du jeton enregistré. Lève une [AuthException] si le site
  /// répond par le compte anonyme : un jeton mort est servi ainsi en lecture.
  Future<Account> me();

  /// Les rôles du compte sur la compétition ; `public` sans session.
  Future<List<String>> competitionRoles(int competitionId);
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._http);

  final HttpClient _http;

  /// Les identifiants passent dans le corps d'un formulaire, jamais dans
  /// l'adresse, qui finit dans les journaux du serveur et des relais (comme
  /// `FfssApiClient.RequestTokenAsync` de V3).
  @override
  Future<String> requestToken(String login, String password) async {
    final body = await _http.post(
      ApiEndpoints.requestToken,
      form: {'login': login.trim(), 'password': password},
    );
    final token = body['token'];
    if (token is! String || token.isEmpty) {
      throw AuthException(body['message']?.toString() ?? 'réponse sans jeton');
    }
    return token;
  }

  @override
  Future<Account> me() async {
    final body = await _http.get(ApiEndpoints.me);
    final label = body['label'];
    final type = body['type'];
    if (label is! String ||
        label.trim().isEmpty ||
        _isAnonymous(label) ||
        (type is String && _isAnonymous(type))) {
      throw const AuthException('compte anonyme');
    }
    return Account(label: label.trim(), type: type is String ? type : null);
  }

  /// Le site répond « Utilisateur Anonyme » à un jeton qu'il ne reconnaît
  /// plus ; les autres mots sont ceux que V3 tient aussi pour anonymes.
  static bool _isAnonymous(String text) {
    final lower = text.trim().toLowerCase();
    return lower.contains('anonym') ||
        const {'public', 'guest', 'visiteur'}.contains(lower);
  }

  /// Avec une session, les rôles sont dans `data` ; sans session, le site
  /// les sert sans enveloppe.
  @override
  Future<List<String>> competitionRoles(int competitionId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.competitionMe, {
      'id': competitionId.toString(),
    });
    final body = await _http.get(path);
    final data = body['data'];
    final raw = data is Map<String, dynamic> ? data['roles'] : body['roles'];
    final roles = [
      for (final role in raw is List ? raw : const <Object?>[])
        if (role is String) role,
    ];
    return roles.isEmpty ? const ['public'] : roles;
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(httpClientProvider)),
);
