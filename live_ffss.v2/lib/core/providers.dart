import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final appConfigProvider = Provider<AppConfig>(
  (ref) => const AppConfig.production(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(
    ref.watch(secureStorageProvider),
    environment: ref.watch(appConfigProvider).environment,
  ),
);

final httpClientProvider = Provider<HttpClient>(
  (ref) => HttpClient(
    config: ref.watch(appConfigProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

final localStoreProvider = Provider<LocalStore>(
  (ref) => SecureLocalStore(
    ref.watch(secureStorageProvider),
    ref.watch(appConfigProvider).environment,
  ),
);

/// L'heure courante, remplaçable dans les tests : le découpage de l'accueil
/// et « Jour 1/3 » en dépendent.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Riverpod 3 relance par défaut un fournisseur en échec pendant près de
/// 40 s : hors ligne, le rafraîchissement tournerait d'autant avant de
/// signaler l'échec. Le rafraîchissement manuel et la minuterie de 30 s
/// tiennent lieu de nouvelle tentative.
Duration? noRetry(int retryCount, Object error) => null;
