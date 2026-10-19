import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
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

/// Le compte a droit à l'espace admin : admin du compte (`/me`), ou admin
/// de la compétition [competitionId] d'après ses rôles. Montre la carte
/// Admin et ouvre ses pages ; les fournisseurs de l'espace le vérifient
/// eux-mêmes ([requireAdmin]).
///
/// Le rôle du compte suffit sans réseau (il est gardé avec la session) : un
/// admin lancé hors ligne garde sa carte. Les rôles de la compétition ne sont
/// lus que pour un compte qui n'est pas admin, et Mon espace les lit déjà.
final adminAccessProvider = FutureProvider.autoDispose.family<bool, int?>((
  ref,
  competitionId,
) async {
  try {
    // Attendue : pendant la relecture de la session au lancement, l'admin
    // n'est pas encore connu, et « réservé » s'afficherait un instant.
    final account = await ref.watch(sessionProvider.future);
    if (account?.isAdmin ?? false) return true;
    if (competitionId == null || !ref.mounted) return false;
    final roles = await ref.watch(
      competitionRolesProvider(competitionId).future,
    );
    return roles.isAdmin;
  } on AppException {
    // Sans rôles établis, pas de droit : on ne le suppose jamais.
    return false;
  }
});

/// Refuse ([AdminOnlyException]) un compte sans droit à l'espace admin.
/// Suivi : une déconnexion ou un changement de compte relance l'appelant,
/// qui refuse alors à son tour.
Future<void> requireAdmin(Ref ref, int? competitionId) async {
  if (!await ref.watch(adminAccessProvider(competitionId).future)) {
    throw const AdminOnlyException();
  }
}
