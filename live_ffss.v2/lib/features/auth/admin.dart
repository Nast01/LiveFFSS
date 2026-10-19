import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/auth/session.dart';

/// Le compte connecté est admin (`/me` → `data.role == "admin"`) : c'est ce
/// qui montre les outils de l'espace admin et ce que leurs fournisseurs
/// vérifient.
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(sessionProvider).value?.isAdmin ?? false,
);

/// Vrai dès qu'un admin s'est connecté une fois sur ce téléphone, même
/// déconnecté depuis : le choix du serveur reste alors visible, pour pouvoir
/// revenir à l'autre sans compte.
class AdminSeenNotifier extends AsyncNotifier<bool> {
  /// Clé globale (`AppEnvironment.globalKeys`) : le drapeau vaut pour les
  /// deux serveurs. La session le pose à l'ouverture d'une session admin.
  static const storageKey = SessionNotifier.adminSeenKey;

  @override
  Future<bool> build() async {
    final store = ref.watch(globalStoreProvider);
    // Une session admin ouverte suffit, sans attendre de relire le drapeau ;
    // une déconnexion le relit sans jamais l'effacer.
    if (ref.watch(isAdminProvider)) return true;
    try {
      return await store.read(storageKey) == 'true';
    } on AppException {
      return false;
    }
  }
}

final adminSeenProvider = AsyncNotifierProvider<AdminSeenNotifier, bool>(
  AdminSeenNotifier.new,
);
