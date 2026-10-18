import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';

abstract class AuthRepository {
  /// Le jeton d'un compte FFSS. Lève une [AppException] si les identifiants
  /// sont refusés.
  Future<String> requestToken(String login, String password);

  /// Le compte du jeton enregistré. Lève une [AuthException] si le site
  /// répond par le compte anonyme : un jeton mort est servi ainsi en lecture.
  Future<Account> me();

  /// Les rôles du compte sur la compétition ; `public` sans session.
  Future<CompetitionRoles> competitionRoles(int competitionId);
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
  Future<CompetitionRoles> competitionRoles(int competitionId) async {
    final path = ApiEndpoints.replacePath(ApiEndpoints.competitionMe, {
      'id': competitionId.toString(),
    });
    final body = await _http.get(path);
    final data = body['data'];
    final source = data is Map<String, dynamic> ? data : body;
    final raw = source['roles'];
    final roles = [
      for (final role in raw is List ? raw : const <Object?>[])
        if (role is String) role,
    ];
    return CompetitionRoles(
      roles: roles.isEmpty ? const ['public'] : roles,
      licenseeId: _readId(_asMap(source['licencie'])?['id']),
      official: _readOfficial(_asMap(source['officiel'])),
      refereeClubs: [
        for (final club in _asList(source['referent_sportif']))
          ?_readClub(_asMap(club)),
      ],
    );
  }
}

// Chaque objet se lit seul : un champ mal typé ne doit pas coûter les autres
// rôles, dont dépend la saisie.
Map<dynamic, dynamic>? _asMap(Object? raw) => raw is Map ? raw : null;

List<Object?> _asList(Object? raw) => raw is List ? raw : const <Object?>[];

int? _readId(Object? raw) =>
    raw is String ? int.tryParse(raw) : (raw is int ? raw : null);

OfficialRole? _readOfficial(Map<dynamic, dynamic>? json) {
  if (json == null) return null;
  final level = json['niveau'];
  final label = json['niveauLabel'];
  final principal = json['principal'];
  if (level is! String || principal is! bool) return null;
  return OfficialRole(
    level: level,
    levelLabel: label is String ? label : level,
    principal: principal,
  );
}

ClubRef? _readClub(Map<dynamic, dynamic>? json) {
  if (json == null) return null;
  final id = json['id'];
  final label = json['label'];
  if (id is! int || label is! String) return null;
  return ClubRef(id: id, label: label);
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(httpClientProvider)),
);
