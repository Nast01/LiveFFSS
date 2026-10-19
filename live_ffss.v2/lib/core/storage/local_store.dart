import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';

/// Les préférences de l'appareil (favoris, compétition active). Une interface
/// pour que les tests des fournisseurs tournent sur une simple Map, sans
/// simuler le stockage sécurisé.
abstract interface class LocalStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// Cloisonne les clés par environnement selon la règle de
/// [AppEnvironment.owner] : préfixe vide en production, `dev_` en
/// développement, aucun préfixe pour une clé globale.
class SecureLocalStore implements LocalStore {
  SecureLocalStore(this._storage, this._environment);

  final FlutterSecureStorage _storage;
  final AppEnvironment _environment;

  String _scoped(String key) => AppEnvironment.globalKeys.contains(key)
      ? key
      : '${_environment.storagePrefix}$key';

  @override
  Future<String?> read(String key) =>
      _guard(() => _storage.read(key: _scoped(key)));

  @override
  Future<void> write(String key, String value) =>
      _guard(() => _storage.write(key: _scoped(key), value: value));

  @override
  Future<void> delete(String key) =>
      _guard(() => _storage.delete(key: _scoped(key)));

  /// La plateforme lève des `PlatformException`, que les appelants n'attrapent
  /// pas : traduites en [AppException], la seule qu'ils attrapent.
  static Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on PlatformException catch (e) {
      throw StorageException(e.message ?? e.code);
    }
  }
}

/// Les clés globales seules (`AppEnvironment.globalKeys`) : lisibles sans
/// savoir sur quel serveur l'app tourne, avant même de le savoir (le serveur
/// choisi en est une). Une clé propre à un serveur n'a rien à y faire.
class GlobalStore implements LocalStore {
  GlobalStore(this._inner);

  /// Le préfixe ne compte pas : une clé globale n'en porte jamais.
  GlobalStore.secure(FlutterSecureStorage storage)
    : this(SecureLocalStore(storage, AppEnvironment.production));

  final LocalStore _inner;

  static void _check(String key) {
    assert(
      AppEnvironment.globalKeys.contains(key),
      "$key n'est pas une clé globale",
    );
  }

  @override
  Future<String?> read(String key) {
    _check(key);
    return _inner.read(key);
  }

  @override
  Future<void> write(String key, String value) {
    _check(key);
    return _inner.write(key, value);
  }

  @override
  Future<void> delete(String key) {
    _check(key);
    return _inner.delete(key);
  }
}
