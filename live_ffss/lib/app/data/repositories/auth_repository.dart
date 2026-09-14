import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/user_mapper.dart';
import 'package:live_ffss/app/domain/models/session_probe.dart';
import 'package:live_ffss/app/domain/models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String login, required String password});
  Future<void> logout();
  Future<User?> restoreSession();
  Future<SessionProbe> probeSession();
  Stream<User?> get userStream;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
    required FlutterSecureStorage secureStorage,
    AppEnvironment environment = AppEnvironment.production,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage,
        _secureStorage = secureStorage,
        _userKey = '${environment.storagePrefix}user';

  final String _userKey;

  final AuthRemoteDataSource _dataSource;
  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _secureStorage;
  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();

  @override
  Stream<User?> get userStream => _userController.stream;

  @override
  Future<User> login({
    required String login,
    required String password,
  }) async {
    final tokenDto =
        await _dataSource.requestToken(login: login, password: password);
    await _tokenStorage.setToken(tokenDto.token);

    final userDto = await _dataSource.getCurrentUser();
    final user = userDto.toDomain(
      token: tokenDto.token,
      tokenExpiration: DateTime.parse(tokenDto.expiration),
    );

    await _secureStorage.write(
      key: _userKey,
      value: jsonEncode(user.toJson()),
    );
    _userController.add(user);
    return user;
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _secureStorage.delete(key: _userKey);
    _userController.add(null);
  }

  @override
  Future<User?> restoreSession() async {
    final raw = await _secureStorage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;

    final json = jsonDecode(raw) as Map<String, dynamic>;
    final user = User.fromJson(json);

    if (user.tokenExpiration.isBefore(DateTime.now().toUtc())) {
      // Token expired — clean up so we don't hand back a stale session.
      await _tokenStorage.clearToken();
      await _secureStorage.delete(key: _userKey);
      return null;
    }

    if (await _isStillSignedIn()) return user;
    await _tokenStorage.clearToken();
    await _secureStorage.delete(key: _userKey);
    return null;
  }

  /// Asks the server who we are, because the stored expiration date does not
  /// say: a token issued with `expiration: "2026-08-30"` was already dead hours
  /// later. FFSS never reports that on a read either — it serves an anonymous
  /// 200 — so the app would keep a session that ended and only find out when a
  /// write came back refused, after the operator had done the work.
  ///
  /// A real account is a licencie or an organisme; anything else is the
  /// anonymous identity. The cost of that reading is that a type FFSS may add
  /// later would force a needless sign-in until the mapper learns it — a
  /// nuisance, where the opposite default silently keeps dead sessions alive.
  ///
  /// Anything other than a clear "you are nobody" keeps the session: being
  /// offline proves nothing, and the timeout is there so a socket that never
  /// answers cannot hold up application start.
  @override
  Future<SessionProbe> probeSession() async {
    try {
      final me = await _dataSource
          .getCurrentUser()
          .timeout(const Duration(seconds: 4));
      final user = me.toDomain(token: '', tokenExpiration: DateTime.now());
      final signedIn =
          user.type == UserType.licensee || user.type == UserType.organisme;
      return SessionProbe(
        outcome: signedIn
            ? SessionProbeOutcome.signedIn
            : SessionProbeOutcome.anonymous,
        label: user.label,
        type: user.type,
      );
    } on AppException catch (e) {
      return SessionProbe(
        outcome: SessionProbeOutcome.unreachable,
        message: e.message,
      );
    } on TimeoutException catch (e) {
      return SessionProbe(
        outcome: SessionProbeOutcome.unreachable,
        message: e.message ?? 'Pas de réponse en 4 s',
      );
    }
  }

  /// Seul un « vous n'êtes personne » explicite met fin à la session — voir
  /// [probeSession].
  Future<bool> _isStillSignedIn() async =>
      (await probeSession()).outcome != SessionProbeOutcome.anonymous;
}
