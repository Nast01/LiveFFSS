import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_ffss_v2/core/network/network_log.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/features/auth/admin.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/my_space/official_space_providers.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

/// Les DQ et forfaits publiés de tous les clubs : ceux de l'espace officiel
/// (classements lus 6 au plus en vol, à la demande), que la page filtre par
/// club et par épreuve. Rien n'est lu pour un compte sans droit.
final adminDecisionsProvider = FutureProvider.autoDispose
    .family<OfficialDecisions, int>((ref, competitionId) async {
      await requireAdmin(ref, competitionId);
      if (!ref.mounted) return _noDecisions;
      return ref.watch(officialDecisionsProvider(competitionId).future);
    });

const _noDecisions = (
  events: <EventDecisions>[],
  unreadEvents: 0,
  entries: <int, ({CompetitionEvent event, EventResult result})>{},
);

/// Rafraîchissement et « Réessayer » des DQ et forfaits de l'espace admin.
Future<void> refreshAdminDecisions(
  ProviderContainer container,
  int competitionId,
) async {
  final roles = competitionRolesProvider(competitionId);
  if (container.exists(roles) && container.read(roles).hasError) {
    container.invalidate(roles);
  }
  await refreshOfficialDecisions(container, competitionId);
}

/// Les clubs engagés, pour ouvrir l'espace de n'importe lequel. Tirés des
/// participants (3,6 Mo), lus une fois et gardés comme pour la recherche.
/// Rien n'est lu d'une compétition côtière, comme pour les DQ et forfaits :
/// l'espace d'un club n'y montre rien.
final adminClubsProvider = FutureProvider.autoDispose
    .family<List<CompetitionClub>, int>((ref, competitionId) async {
      await requireAdmin(ref, competitionId);
      if (!ref.mounted) return const [];
      final competition = await ref.watch(
        spaceCompetitionProvider(competitionId).future,
      );
      if (!ref.mounted || isCoastalOnly(competition)) return const [];
      ref.read(participantsKeeperProvider(competitionId).notifier).keep();
      return competitionClubs(
        await ref.watch(participantsProvider(competitionId).future),
      );
    });

/// Le journal réseau, pour l'espace admin : refusé à un compte sans droit
/// sur la compétition [competitionId] (nulle : l'admin du compte seul),
/// comme les autres outils, plutôt que de compter sur la page cachée.
final adminNetworkLogProvider = FutureProvider.autoDispose
    .family<List<NetworkLogEntry>, int?>((ref, competitionId) async {
      await requireAdmin(ref, competitionId);
      if (!ref.mounted) return const [];
      return ref.watch(networkLogProvider);
    });

/// « Réessayer » des clubs : les participants et la compétition ne sont
/// relus que s'ils ont échoué.
void retryAdminClubs(ProviderContainer container, int competitionId) {
  final participants = participantsProvider(competitionId);
  if (container.exists(participants) && container.read(participants).hasError) {
    container.invalidate(participants);
  }
  final competition = spaceCompetitionProvider(competitionId);
  if (container.exists(competition) && container.read(competition).hasError) {
    container.invalidate(competition);
  }
  final roles = competitionRolesProvider(competitionId);
  if (container.exists(roles) && container.read(roles).hasError) {
    container.invalidate(roles);
  }
  container.invalidate(adminClubsProvider(competitionId));
}
