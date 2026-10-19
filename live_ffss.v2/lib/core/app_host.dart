import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/core/providers.dart';

/// Le conteneur de l'app, un par serveur. Changer de serveur en crée un
/// neuf et jette l'ancien : session, file d'envoi, caches et routeur
/// repartent de zéro, sans rien garder de l'autre serveur (pas même une
/// valeur précédente pendant leur premier chargement). Un travail en cours
/// dans l'ancien voit `ref.mounted` faux ; une requête déjà partie finit sur
/// son serveur, avec son jeton, et son résultat est écarté.
class AppContainerHost extends ChangeNotifier {
  AppContainerHost({
    required AppEnvironment environment,
    List<Override> overrides = const [],
    void Function(ProviderContainer old)? disposeOld,
  }) : _overrides = overrides,
       _disposeOld = disposeOld ?? _disposeNow {
    _container = _create(environment);
  }

  final List<Override> _overrides;
  final void Function(ProviderContainer old) _disposeOld;
  late ProviderContainer _container;

  /// Le journal réseau couvre toute la vie de l'app, changements de serveur
  /// compris : il vit ici, hors des conteneurs.
  final NetworkLogStore networkLog = NetworkLogStore();

  ProviderContainer get container => _container;

  static void _disposeNow(ProviderContainer old) => old.dispose();

  ProviderContainer _create(AppEnvironment environment) => ProviderContainer(
    overrides: [
      ..._overrides,
      networkLogStoreProvider.overrideWithValue(networkLog),
      launchEnvironmentProvider.overrideWithValue(environment),
      serverRestartProvider.overrideWithValue(restartOn),
    ],
    retry: noRetry,
  );

  void restartOn(AppEnvironment environment) {
    final old = _container;
    _container = _create(environment);
    notifyListeners();
    _disposeOld(old);
  }

  @override
  void dispose() {
    _container.dispose();
    networkLog.dispose();
    super.dispose();
  }
}
