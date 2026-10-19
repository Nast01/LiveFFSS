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

/// Tant que personne n'a choisi, l'application parle à la recette
/// (`site.ffss.io`), là où FFSSCompetition V3 publie ses compétitions de test
/// (demande du 2026-10-17). Repasser à la production avant toute diffusion.
const defaultEnvironment = AppEnvironment.development;

/// Le serveur enregistré (clé globale `api_environment`), lu avant `runApp` :
/// la première requête part déjà vers lui. Illisible : [defaultEnvironment].
Future<AppEnvironment> readLaunchEnvironment(GlobalStore store) async {
  try {
    return AppEnvironment.fromName(
          await store.read(AppEnvironment.environmentKey),
        ) ??
        defaultEnvironment;
  } catch (_) {
    // Toute erreur, pas seulement une `AppException` : avant `runApp`, rien
    // ne l'attraperait, et l'app ne s'ouvrirait pas.
    return defaultEnvironment;
  }
}

/// Les clés globales : le serveur choisi, le drapeau « un admin s'est
/// connecté ici ».
final globalStoreProvider = Provider<GlobalStore>(
  (ref) => GlobalStore.secure(ref.watch(secureStorageProvider)),
);

/// Le serveur de cette app : fixé par la racine (`AppContainerHost`) pour
/// toute la vie de son conteneur. Changer de serveur, c'est un conteneur neuf.
final launchEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => defaultEnvironment,
);

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.forEnvironment(ref.watch(launchEnvironmentProvider)),
);

/// Relance l'app sur un autre serveur ; fourni par la racine
/// (`AppContainerHost`).
final serverRestartProvider = Provider<void Function(AppEnvironment)>(
  (ref) => throw StateError("pas de racine pour changer de serveur"),
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
