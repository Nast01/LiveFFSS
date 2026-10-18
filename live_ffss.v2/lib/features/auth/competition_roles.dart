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

/// Faux tant que les rôles ne sont pas lus, ou si leur lecture échoue : la
/// saisie ne s'ouvre que sur un droit établi.
final canEnterProvider = Provider.autoDispose.family<bool, int>(
  (ref, competitionId) => canEnterResults(
    ref.watch(competitionRolesProvider(competitionId)).value ?? const [],
  ),
);
