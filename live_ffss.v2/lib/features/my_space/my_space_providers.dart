import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/officials_repository.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/results/athlete_providers.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/shell/active_competition.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

part 'my_space_providers.freezed.dart';

/// Un espace du compte connecté sur la compétition active.
@freezed
sealed class MySpaceCard with _$MySpaceCard {
  const factory MySpaceCard.athlete(Participant participant) = AthleteSpaceCard;
  const factory MySpaceCard.club(ClubRef club) = ClubSpaceCard;

  /// [role] nul : le site donne le rôle `officiel` sans son détail ; la
  /// saisie reste ouverte, la carte aussi.
  const factory MySpaceCard.official(OfficialRole? role) = OfficialSpaceCard;
  const factory MySpaceCard.admin() = AdminSpaceCard;
}

/// Une carte par rôle détenu : Athlète seulement si le licencié est engagé
/// (il n'aurait ni planning ni résultat), une carte par club référent.
List<MySpaceCard> mySpaceCards(
  CompetitionRoles roles,
  List<Participant> participants,
) {
  final athlete = participantOfLicensee(participants, roles.licenseeId);
  return [
    if (athlete != null) MySpaceCard.athlete(athlete),
    for (final club in roles.refereeClubs) MySpaceCard.club(club),
    if (roles.isOfficial || roles.official != null)
      MySpaceCard.official(roles.official),
    if (roles.isAdmin) const MySpaceCard.admin(),
  ];
}

/// Les espaces du compte sur la compétition. Suit les rôles, donc la session :
/// un changement de compte recalcule les cartes.
final mySpaceCardsProvider = FutureProvider.autoDispose
    .family<List<MySpaceCard>, int>((ref, competitionId) async {
      final roles = await ref.watch(
        competitionRolesProvider(competitionId).future,
      );
      if (!ref.mounted) return const [];
      // Sans licencié, pas de carte Athlète : les participants (3,6 Mo) ne
      // sont pas lus pour rien.
      if (roles.licenseeId == null) return mySpaceCards(roles, const []);
      ref.read(participantsKeeperProvider(competitionId).notifier).keep();
      final participants = await ref.watch(
        participantsProvider(competitionId).future,
      );
      if (!ref.mounted) return const [];
      return mySpaceCards(roles, participants);
    });

/// « Réessayer » des cartes : les lectures en amont gardent leur erreur tant
/// qu'on ne les relance pas. La page passe le conteneur de son
/// `ProviderScope`.
void retryMySpaceCards(ProviderContainer container, int competitionId) {
  final roles = competitionRolesProvider(competitionId);
  if (container.read(roles).hasError) container.invalidate(roles);
  final participants = participantsProvider(competitionId);
  if (container.read(participants).hasError) {
    container.invalidate(participants);
  }
  container.invalidate(mySpaceCardsProvider(competitionId));
}

typedef CompetitionClub = ({int id, String label, int athletes});

/// Les infos de la compétition : ce que l'accueil a lu, plus ses nombres.
@freezed
abstract class CompetitionInfo with _$CompetitionInfo {
  const factory CompetitionInfo({
    required CompetitionSummary competition,
    required int athletes,

    /// Par libellé ; chacun ouvre l'espace de son club.
    required List<CompetitionClub> clubs,

    /// Les épreuves eau plate.
    required int events,
  }) = _CompetitionInfo;
}

final competitionInfoProvider = FutureProvider.autoDispose
    .family<CompetitionInfo, int>((ref, competitionId) async {
      ref.read(participantsKeeperProvider(competitionId).notifier).keep();
      // Lues ensemble ; celles qu'on n'attend pas encore ne doivent pas
      // remonter leur échec comme non traité.
      final participantsRead = ref.watch(
        participantsProvider(competitionId).future,
      )..ignore();
      final eventsRead = ref.watch(eventsProvider(competitionId).future)
        ..ignore();
      // Lue sans être suivie : la liste de l'accueil, relue, ne doit pas
      // refaire les comptes.
      final current = ref.read(currentCompetitionProvider);
      final competitionRead = current?.id == competitionId
          ? Future.value(current)
          : ref.watch(competitionByIdProvider(competitionId).future);
      // `ref` ne sert plus après les attentes : rien à vérifier.
      final competition = await competitionRead;
      if (competition == null) {
        throw NotFoundException('competition $competitionId');
      }
      final participants = await participantsRead;
      final events = await eventsRead;
      return CompetitionInfo(
        competition: competition,
        athletes: participants.length,
        clubs: competitionClubs(participants),
        events: events.length,
      );
    });

/// « Réessayer » des infos ; voir [retryMySpaceCards].
void retryCompetitionInfo(ProviderContainer container, int competitionId) {
  final participants = participantsProvider(competitionId);
  if (container.read(participants).hasError) {
    container.invalidate(participants);
  }
  if (container.read(eventsProvider(competitionId)).hasError) {
    // `refresh` porte son échec dans l'état, qu'il n'y a pas à attendre.
    unawaited(container.read(eventsProvider(competitionId).notifier).refresh());
  }
  final byId = competitionByIdProvider(competitionId);
  if (container.exists(byId) && container.read(byId).hasError) {
    container.invalidate(byId);
  }
  container.invalidate(competitionInfoProvider(competitionId));
}

typedef OfficialGroup = ({String? label, List<CompetitionOfficial> officials});

/// Les officiels de la compétition, groupés. Visibles de tout le monde : le
/// site les sert sans jeton.
final officialsProvider = FutureProvider.autoDispose
    .family<List<OfficialGroup>, int>(
      (ref, competitionId) async => groupOfficials(
        await ref.read(officialsRepositoryProvider).getOfficials(competitionId),
      ),
    );
