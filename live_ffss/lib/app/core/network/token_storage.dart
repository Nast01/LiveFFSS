import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

class TokenStorage {
  TokenStorage(
    this._storage, {
    AppEnvironment environment = AppEnvironment.production,
  }) : _key = '${environment.storagePrefix}token';

  final FlutterSecureStorage _storage;
  final String _key;

  Future<String?> getToken() => _storage.read(key: _key);

  Future<void> setToken(String token) =>
      _storage.write(key: _key, value: token);

  Future<void> clearToken() => _storage.delete(key: _key);
}
