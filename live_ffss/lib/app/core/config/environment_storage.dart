import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

/// Le choix d'endpoint, persisté sous une clé globale — voir
/// [AppEnvironment.environmentKey].
class EnvironmentStorage {
  EnvironmentStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<AppEnvironment?> read() async => AppEnvironment.fromName(
        await _storage.read(key: AppEnvironment.environmentKey),
      );

  Future<void> save(AppEnvironment environment) => _storage.write(
        key: AppEnvironment.environmentKey,
        value: environment.name,
      );
}
