import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/network/token_storage.dart';
import 'package:live_ffss/app/data/datasources/auth_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/user_mapper.dart';
import 'package:live_ffss/app/domain/models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String login, required String password});
  Future<void> logout();
  Future<User?> restoreSession();
  Stream<User?> get userStream;
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required TokenStorage tokenStorage,
    required FlutterSecureStorage secureStorage,
  })  : _dataSource = dataSource,
        _tokenStorage = tokenStorage,
        _secureStorage = secureStorage;

  static const _userKey = 'user';

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

    return user;
  }
}
