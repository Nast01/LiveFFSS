import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/core/network/token_storage.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

/// Pour le moment, l'application parle à la recette (`site.ffss.io`), là où
/// FFSSCompetition V3 publie ses compétitions de test (demande du
/// 2026-10-17). Le choix de l'environnement dans l'app arrive au lot 4.
final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.forEnvironment(AppEnvironment.development),
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
