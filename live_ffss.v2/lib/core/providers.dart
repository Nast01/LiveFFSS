import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:live_ffss_v2/core/config/app_config.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
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
/// la première requête part déjà vers lui. Illisible : [defaultEnvironment],
/// un stockage en panne ne doit pas empêcher l'app de s'ouvrir.
Future<AppEnvironment> readLaunchEnvironment(LocalStore store) async {
  try {
    return AppEnvironment.fromName(
          await store.read(AppEnvironment.environmentKey),
        ) ??
        defaultEnvironment;
  } on AppException {
    return defaultEnvironment;
  }
}

/// Le stockage des clés globales (`AppEnvironment.globalKeys`), qui ne
/// dépend pas du serveur : c'est là que s'écrit le serveur choisi, que
/// [localStoreProvider] attend pour se construire.
final globalStoreProvider = Provider<LocalStore>(
  (ref) =>
      SecureLocalStore(ref.watch(secureStorageProvider), defaultEnvironment),
);

/// Remplacé dans `main.dart` par [readLaunchEnvironment].
final launchEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => defaultEnvironment,
);

/// Le serveur courant. Le changer reconstruit tout ce qui en dépend :
/// stockage (préfixé par serveur), jeton, client HTTP, puis la session et les
/// données qu'ils servent.
class AppConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() =>
      AppConfig.forEnvironment(ref.watch(launchEnvironmentProvider));

  /// Enregistré pour le prochain lancement. Un stockage en panne n'empêche
  /// pas de changer ; ce lancement-là reviendra alors au serveur d'avant.
  Future<void> switchTo(AppEnvironment environment) async {
    if (environment == state.environment) return;
    try {
      await ref
          .read(globalStoreProvider)
          .write(AppEnvironment.environmentKey, environment.name);
    } on AppException {
      // Changé pour cette exécution seulement.
    }
    if (!ref.mounted) return;
    state = AppConfig.forEnvironment(environment);
  }
}

final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(
  AppConfigNotifier.new,
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
