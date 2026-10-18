import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/data/repositories/officials_repository.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/officials.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/follows/follows_providers.dart';
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

/// Les cartes du compte, et si la carte Athlète manque faute d'avoir pu lire
/// les participants.
@freezed
abstract class MySpaceCards with _$MySpaceCards {
  const factory MySpaceCards({
    required List<MySpaceCard> cards,

    /// Le compte a un licencié, mais les participants n'ont pu être lus : on
    /// ne sait pas s'il est engagé. La page propose « Réessayer » pour cette
    /// carte seule.
    @Default(false) bool athleteUnknown,
  }) = _MySpaceCards;
}

/// Les espaces du compte sur la compétition. Suit les rôles, donc la session :
/// un changement de compte recalcule les cartes.
final mySpaceCardsProvider = FutureProvider.autoDispose
    .family<MySpaceCards, int>((ref, competitionId) async {
      final roles = await ref.watch(
        competitionRolesProvider(competitionId).future,
      );
      if (!ref.mounted) return const MySpaceCards(cards: []);
      // Sans licencié, pas de carte Athlète : les participants (3,6 Mo) ne
      // sont pas lus pour rien.
      if (roles.licenseeId == null) {
        return MySpaceCards(cards: mySpaceCards(roles, const []));
      }
      ref.read(participantsKeeperProvider(competitionId).notifier).keep();
      try {
        final participants = await ref.watch(
          participantsProvider(competitionId).future,
        );
        return MySpaceCards(cards: mySpaceCards(roles, participants));
      } on AppException {
        // Les participants ne décident que de la carte Athlète : les autres
        // restent ouvertes.
        return MySpaceCards(
          cards: mySpaceCards(roles, const []),
          athleteUnknown: true,
        );
      }
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

/// La prochaine course de chaque athlète suivi, par id de participant, tirée
/// du programme et des épreuves que lisent déjà les résultats : ni les
/// classements ni les participants ne sont relus. Un suivi sans épreuves
/// (enregistré avant qu'on les garde) n'y est pas.
final followedRacesProvider = FutureProvider.autoDispose
    .family<Map<int, FollowedRace?>, int>((ref, competitionId) async {
      // Lues ensemble ; celles qu'on n'attend pas encore ne doivent pas
      // remonter leur échec comme non traité.
      final followsRead = ref.watch(followsProvider(competitionId).future);
      final eventsRead = ref.watch(eventsProvider(competitionId).future)
        ..ignore();
      final programmeRead = ref.watch(
        resultsProgrammeProvider(competitionId).future,
      )..ignore();
      // `ref` ne sert plus après les attentes : rien à vérifier.
      final follows = await followsRead;
      final events = await eventsRead;
      final programme = await programmeRead;
      return {
        for (final athlete in follows.athletes)
          if (athlete.eventIds.isNotEmpty)
            athlete.participantId: followedNextRace(athlete, events, programme),
      };
    });

typedef ClubKey = ({int competitionId, int clubId});

/// Un club de la compétition : son libellé et ses athlètes engagés.
@freezed
abstract class ClubInfo with _$ClubInfo {
  const factory ClubInfo({
    required int id,

    /// Celui de ses participants ; vide pour un club sans engagé.
    required String label,

    /// Par nom puis prénom (`clubAthletes`).
    required List<Participant> athletes,
  }) = _ClubInfo;
}

/// Ouvert à tout le monde (décision du 2026-10-18) : on suit le club d'un
/// proche sans compte.
final clubProvider = FutureProvider.autoDispose.family<ClubInfo, ClubKey>((
  ref,
  key,
) async {
  ref.read(participantsKeeperProvider(key.competitionId).notifier).keep();
  final participants = await ref.watch(
    participantsProvider(key.competitionId).future,
  );
  final athletes = clubAthletes(participants, key.clubId);
  return ClubInfo(
    id: key.clubId,
    label: athletes.firstOrNull?.club ?? '',
    athletes: athletes,
  );
});

/// Une course d'un club : un engagement et ceux de ses athlètes qui le
/// courent, plusieurs pour un relais.
@freezed
abstract class ClubRace with _$ClubRace {
  const factory ClubRace({
    required List<Participant> athletes,
    required AthleteRace race,
  }) = _ClubRace;
}

@freezed
abstract class ClubSchedule with _$ClubSchedule {
  const factory ClubSchedule({
    /// À courir d'abord, puis courues (voir [clubRaces]).
    required List<ClubRace> races,

    /// Athlètes dont la fiche n'a pu être lue : leurs courses manquent, ce
    /// que la page dit.
    @Default(0) int failedAthletes,
  }) = _ClubSchedule;
}

/// Le planning et les résultats d'un club, tirés des fiches de ses athlètes
/// (lot 5). Lu à l'ouverture de son espace et par [refreshClubSchedule],
/// sans minuterie. Une fiche en échec n'emporte pas les autres.
///
/// Chaque fiche lit les classements de ses épreuves d'un coup : six fiches
/// en vol feraient des dizaines de lectures à la fois. Les classements des
/// épreuves du club sont donc lus d'abord, 6 au plus en vol
/// ([maxConcurrentSeries]) ; les fiches, lues ensuite 6 à la fois, les
/// trouvent prêts.
///
/// Épreuves, classements et fiches sont lus sans être suivis, le temps du
/// calcul : suivis, le rafraîchissement des Épreuves de l'onglet Résultats
/// (qui relit la source de tous les classements) les relirait tous d'un
/// coup, sans plafond. Le planning ne change donc que par son propre
/// rafraîchissement. Les participants restent suivis par [clubProvider] :
/// 3,6 Mo à ne pas relire.
final clubScheduleProvider = FutureProvider.autoDispose
    .family<ClubSchedule, ClubKey>((ref, key) async {
      final competitionId = key.competitionId;
      ref.watch(_clubRefreshProvider(key));
      final refreshing = ref.read(_clubRefreshProvider(key).notifier).take();
      final subscriptions = <ProviderSubscription<Object?>>[];
      Future<T> readOnce<T>(ProviderListenable<Future<T>> provider) {
        final subscription = ref.listen(provider, (_, _) {});
        subscriptions.add(subscription);
        return subscription.read();
      }

      try {
        // Lues ensemble ; celle qu'on n'attend pas encore ne doit pas
        // remonter son échec comme non traité.
        final clubRead = ref.watch(clubProvider(key).future);
        final eventsRead = readOnce(eventsProvider(competitionId).future)
          ..ignore();
        final club = await clubRead;
        final events = await eventsRead;
        if (!ref.mounted) return const ClubSchedule(races: []);

        // Les épreuves côtières n'ont pas de classement : la fiche les écarte.
        final flatWater = {for (final event in events) event.id};
        final eventIds = {
          for (final athlete in club.athletes)
            for (final entry in athlete.entries)
              if (flatWater.contains(entry.eventId)) entry.eventId,
        };
        await _inPool(eventIds, () => ref.mounted, (eventId) async {
          final ranking = eventRankingProvider((
            competitionId: competitionId,
            eventId: eventId,
          ));
          // Invalidé juste avant sa lecture, pas tous d'avance : un
          // classement que l'onglet Résultats écoute se relirait aussitôt,
          // hors du plafond.
          if (refreshing) ref.invalidate(ranking);
          try {
            await readOnce(ranking.future);
          } on AppException {
            // La fiche trouvera l'échec et dira l'épreuve illisible.
          }
        });
        if (!ref.mounted) return const ClubSchedule(races: []);

        final cards = <int, List<AthleteRace>>{};
        var failed = 0;
        await _inPool(club.athletes, () => ref.mounted, (athlete) async {
          final card = athleteCardProvider((
            competitionId: competitionId,
            participantId: athlete.id,
          ));
          // Une fiche restée en échec (une autre page la suit) se relit.
          if (refreshing) ref.invalidate(card);
          try {
            cards[athlete.id] = await readOnce(card.future);
          } on AppException {
            failed++;
          }
        });
        if (!ref.mounted) return const ClubSchedule(races: []);
        return ClubSchedule(
          races: clubRaces(club.athletes, cards, events),
          failedAthletes: failed,
        );
      } finally {
        for (final subscription in subscriptions) {
          subscription.close();
        }
      }
    });

/// Le signal de [refreshClubSchedule] : la prochaine lecture du planning
/// relit ses classements, chacun juste avant sa lecture.
final _clubRefreshProvider = NotifierProvider.autoDispose
    .family<_ClubRefresh, int, ClubKey>(_ClubRefresh.new);

class _ClubRefresh extends Notifier<int> {
  _ClubRefresh(this.key);

  final ClubKey key;

  // Dans un champ : une lecture du planning sans rafraîchissement demandé
  // (club relu) ne doit pas relire les classements.
  int _taken = 0;

  @override
  int build() => 0;

  void request() => state++;

  /// Vrai une fois par rafraîchissement demandé.
  bool take() {
    final pending = state > _taken;
    _taken = state;
    return pending;
  }
}

/// [task] sur chaque élément, [maxConcurrentSeries] au plus en vol. Les
/// travailleurs tirent dans le même itérateur : `moveNext` + `current` sans
/// `await` entre les deux est sûr. [alive] faux : une lecture remplacée
/// (rafraîchissement, page fermée) ne lance plus rien.
Future<void> _inPool<T>(
  Iterable<T> items,
  bool Function() alive,
  Future<void> Function(T item) task,
) async {
  final pending = items.iterator;
  Future<void> worker() async {
    while (alive() && pending.moveNext()) {
      await task(pending.current);
    }
  }

  await Future.wait([for (var i = 0; i < maxConcurrentSeries; i++) worker()]);
}

/// Les courses des [athletes] d'après leurs fiches ([cards], par id de
/// participant) : un relais, présent sur la fiche de chacun de ses
/// relayeurs, ne fait qu'une course. À courir d'abord, par heure prévue
/// (celles sans heure après), puis courues, par épreuve dans l'ordre de
/// [events] et par rang ; à égalité, l'ordre des athlètes (par nom).
List<ClubRace> clubRaces(
  List<Participant> athletes,
  Map<int, List<AthleteRace>> cards,
  List<CompetitionEvent> events,
) {
  final byEntry = <int, ({AthleteRace race, List<Participant> athletes})>{};
  for (final athlete in athletes) {
    for (final race in cards[athlete.id] ?? const <AthleteRace>[]) {
      byEntry
          .putIfAbsent(race.entry.entryId, () => (race: race, athletes: []))
          .athletes
          .add(athlete);
    }
  }
  final eventOrder = {for (final (i, event) in events.indexed) event.id: i};
  int orderOf(AthleteRace race) =>
      eventOrder[race.event.id] ?? eventOrder.length;

  int compare(AthleteRace a, AthleteRace b) {
    final byRun = (a.toRun ? 0 : 1).compareTo(b.toRun ? 0 : 1);
    if (byRun != 0) return byRun;
    if (a.toRun) {
      final byStart = _nullsLast(a.plannedStart, b.plannedStart);
      return byStart != 0 ? byStart : orderOf(a).compareTo(orderOf(b));
    }
    final byEvent = orderOf(a).compareTo(orderOf(b));
    return byEvent != 0 ? byEvent : _nullsLast(a.row?.rank, b.row?.rank);
  }

  // `sort` n'est pas stable : l'indice départage.
  final indexed = byEntry.values.indexed.toList()
    ..sort((a, b) {
      final byRace = compare(a.$2.race, b.$2.race);
      return byRace != 0 ? byRace : a.$1.compareTo(b.$1);
    });
  return [
    for (final (_, entry) in indexed)
      ClubRace(athletes: entry.athletes, race: entry.race),
  ];
}

int _nullsLast<T extends Comparable<Object>>(T? a, T? b) {
  if (a == null) return b == null ? 0 : 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// Rafraîchissement et « Réessayer » de l'espace d'un club : ses
/// classements et ses fiches, relus par le planning 6 au plus en vol, et ce
/// qui en amont a échoué. Les participants (3,6 Mo) ne sont relus que s'ils
/// ont échoué. La page passe le conteneur de son `ProviderScope`.
Future<void> refreshClubSchedule(
  ProviderContainer container,
  ClubKey key,
) async {
  final participants = participantsProvider(key.competitionId);
  if (container.exists(participants) && container.read(participants).hasError) {
    container.invalidate(participants);
  }
  final club = clubProvider(key);
  if (container.exists(club) && container.read(club).hasError) {
    container.invalidate(club);
  }
  // Les épreuves ne sont pas gardées par le planning : en échec, elles ont
  // été jetées, et sa lecture les relit.
  container.read(_clubRefreshProvider(key).notifier).request();
  try {
    await container.read(clubScheduleProvider(key).future);
  } on AppException {
    // L'échec est dans l'état du planning, que la page montre.
  }
}
