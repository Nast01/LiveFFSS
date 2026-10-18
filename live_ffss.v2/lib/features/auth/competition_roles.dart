import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/features/auth/session.dart';

/// Les rôles du compte connecté sur la compétition. Relus à chaque
/// changement de session : une connexion ou une expiration change ce que
/// l'officiel peut faire.
final competitionRolesProvider = FutureProvider.autoDispose
    .family<List<String>, int>((ref, competitionId) async {
      final auth = ref.watch(authRepositoryProvider);
      final account = await ref.watch(sessionProvider.future);
      // Sans session, le site répondrait `public` : inutile de le demander.
      if (account == null) return const ['public'];
      return auth.competitionRoles(competitionId);
    });

/// Faux pendant une lecture des rôles, ou si elle échoue : la saisie ne
/// s'ouvre que sur un droit établi pour la session en cours, pas sur celui de
/// la précédente.
final canEnterProvider = Provider.autoDispose.family<bool, int>((
  ref,
  competitionId,
) {
  final roles = ref.watch(competitionRolesProvider(competitionId));
  if (roles.isLoading || roles.hasError) return false;
  return canEnterResults(roles.value ?? const []);
});

/// Au rafraîchissement manuel, une lecture des rôles en échec (hors ligne au
/// lancement, Wi-Fi de piscine) est relue : sans quoi elle ne le serait
/// qu'au prochain changement de session. Rien n'est lu si personne ne les
/// suit.
void retryFailedRoles(Ref ref, int competitionId) {
  final provider = competitionRolesProvider(competitionId);
  if (ref.exists(provider) && ref.read(provider).hasError) {
    ref.invalidate(provider);
  }
}
