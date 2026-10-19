import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/providers.dart';
import 'package:live_ffss_v2/data/repositories/engagement_repository.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/my_space.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/domain/series_link.dart';
import 'package:live_ffss_v2/features/auth/competition_roles.dart';
import 'package:live_ffss_v2/features/auth/session.dart';
import 'package:live_ffss_v2/features/my_space/my_space_providers.dart';
import 'package:live_ffss_v2/features/results/results_formatting.dart';
import 'package:live_ffss_v2/features/results/results_providers.dart';
import 'package:live_ffss_v2/features/shell/space_competition.dart';

part 'club_forfeits_providers.freezed.dart';

enum ForfeitSending { idle, sending }

enum ForfeitOutcome { done, locked, notAllowed, failed }

/// Un engagement du club et son forfait, lu sur sa place.
@freezed
abstract class ClubForfeit with _$ClubForfeit {
  const factory ClubForfeit({
    required int entryId,
    required CompetitionEvent event,

    /// Ceux du club qui le courent : plusieurs pour un relais.
    required List<String> athletes,

    /// Sa course et son couloir, nuls tant qu'aucune place lue ne le porte.
    Heat? heat,
    int? lane,

    /// Nul : une place qui pouvait le porter n'a pu être lue, l'état n'est
    /// pas connu. Sans place trouvée, faux : le forfait vaut pour
    /// l'engagement, et rien ne dit qu'il est déclaré.
    bool? forfeit,
    DateTime? deadline,
    @Default(ForfeitSending.idle) ForfeitSending sending,
  }) = _ClubForfeit;
}

/// Un engagement du club et ceux de ses athlètes qui le courent.
typedef ClubEntry = ({
  int entryId,
  CompetitionEvent event,
  List<Participant> athletes,
});

/// Les engagements des [athletes] dans les [events] (eau plate), un par
/// engagement : un relais, porté par chacun de ses relayeurs, ne vient
/// qu'une fois. Dans l'ordre des épreuves, puis des athlètes.
List<ClubEntry> clubEntries(
  List<Participant> athletes,
  List<CompetitionEvent> events,
) {
  final eventsById = {for (final event in events) event.id: event};
  final byEntry = <int, ClubEntry>{};
  for (final athlete in athletes) {
    for (final entry in athlete.entries) {
      final event = eventsById[entry.eventId];
      if (event == null) continue;
      byEntry
          .putIfAbsent(
            entry.entryId,
            () => (entryId: entry.entryId, event: event, athletes: []),
          )
          .athletes
          .add(athlete);
    }
  }
  final order = {for (final (i, event) in events.indexed) event.id: i};
  // `sort` n'est pas stable : l'indice départage.
  final indexed = byEntry.values.indexed.toList()
    ..sort((a, b) {
      final byEvent = order[a.$2.event.id]!.compareTo(order[b.$2.event.id]!);
      return byEvent != 0 ? byEvent : a.$1.compareTo(b.$1);
    });
  return [for (final (_, entry) in indexed) entry];
}

/// Les forfaits d'un club (lot 6b) : l'état ne se lit que sur les places
/// (`engagement.isForfait`), aucune route ne donnant celle d'un engagement.
/// Sont lues les places des courses non terminées du tour séries de chaque
/// épreuve du club, 6 au plus en vol, jusqu'à trouver chaque engagement ; à
/// l'ouverture et par [ClubForfeitsNotifier.refresh], sans minuterie.
///
/// Épreuves et programme sont lus sans être suivis, le temps du calcul,
/// comme [clubScheduleProvider] : suivis, le rafraîchissement de l'onglet
/// Résultats relirait toutes ces places.
final clubForfeitsProvider = AsyncNotifierProvider.autoDispose
    .family<ClubForfeitsNotifier, List<ClubForfeit>, ClubKey>(
      ClubForfeitsNotifier.new,
    );

class ClubForfeitsNotifier extends AsyncNotifier<List<ClubForfeit>> {
  ClubForfeitsNotifier(this.key);

  final ClubKey key;

  /// La place où chaque engagement a été trouvé : relue après un envoi.
  final _places = <int, int>{};

  @override
  Future<List<ClubForfeit>> build() async {
    final competitionId = key.competitionId;
    // Gardés en vie pour [toggle], sans tout relire à chaque relecture des
    // droits : le droit se vérifie au moment d'envoyer.
    ref.listen(competitionRolesProvider(competitionId), (_, _) {});
    final repository = ref.read(meetingRepositoryProvider);
    final subscriptions = <ProviderSubscription<Object?>>[];
    Future<T> readOnce<T>(ProviderListenable<Future<T>> provider) {
      final subscription = ref.listen(provider, (_, _) {});
      subscriptions.add(subscription);
      return subscription.read();
    }

    try {
      // Une compétition côtière n'a rien que l'app sache lire.
      final competition = await ref.watch(
        spaceCompetitionProvider(competitionId).future,
      );
      if (!ref.mounted || isCoastalOnly(competition)) return const [];
      // Lues ensemble ; celles qu'on n'attend pas encore ne doivent pas
      // remonter leur échec comme non traité.
      final clubRead = ref.watch(clubProvider(key).future);
      final eventsRead = readOnce(eventsProvider(competitionId).future)
        ..ignore();
      final programmeRead = readOnce(
        resultsProgrammeProvider(competitionId).future,
      )..ignore();
      final club = await clubRead;
      final events = await eventsRead;
      final programme = await programmeRead;
      if (!ref.mounted) return const [];

      final toRunOf = <int, List<Heat>>{};
      final entries = <ClubEntry>[];
      for (final entry in clubEntries(club.athletes, events)) {
        final round = heatsRoundOf(programme, entry.event);
        final toRun = [
          for (final heat in round)
            if (heat.status != RunStatus.finished) heat,
        ];
        // Tour séries couru : plus rien à déclarer.
        if (round.isNotEmpty && toRun.isEmpty) continue;
        toRunOf[entry.event.id] = toRun;
        entries.add(entry);
      }

      // Une course est partagée par les catégories d'une même discipline :
      // chaque place n'est lue qu'une fois.
      final heatOfPlace = <int, Heat>{
        for (final heats in toRunOf.values)
          for (final heat in heats)
            for (final placeId in heat.placeIds) placeId: heat,
      };
      final wanted = {for (final entry in entries) entry.entryId};
      final found = <int, ({int placeId, LaneAssignment lane})>{};
      final read = <int>{};
      await inPool(
        heatOfPlace.keys,
        () => ref.mounted && found.length < wanted.length,
        (placeId) async {
          final Map<int, LaneAssignment?> lanes;
          try {
            lanes = await repository.getLanes([placeId]);
          } on AppException {
            return;
          }
          if (!lanes.containsKey(placeId)) return;
          read.add(placeId);
          if (lanes[placeId] case final lane?
              when wanted.contains(lane.entryId)) {
            found[lane.entryId!] = (placeId: placeId, lane: lane);
          }
        },
      );
      if (!ref.mounted) return const [];

      _places
        ..clear()
        ..addAll({
          for (final MapEntry(:key, :value) in found.entries)
            key: value.placeId,
        });
      return [
        for (final entry in entries)
          _forfeitOf(
            entry,
            toRunOf[entry.event.id]!,
            found[entry.entryId],
            heatOfPlace,
            read,
          ),
      ];
    } finally {
      for (final subscription in subscriptions) {
        subscription.close();
      }
    }
  }

  static ClubForfeit _forfeitOf(
    ClubEntry entry,
    List<Heat> toRun,
    ({int placeId, LaneAssignment lane})? found,
    Map<int, Heat> heatOfPlace,
    Set<int> read,
  ) {
    final heat = found == null ? null : heatOfPlace[found.placeId];
    // Une place illisible pouvait le porter : « pas forfait » serait faux.
    final unread = toRun.any(
      (h) => h.placeIds.any((placeId) => !read.contains(placeId)),
    );
    return ClubForfeit(
      entryId: entry.entryId,
      event: entry.event,
      athletes: [
        for (final athlete in entry.athletes) participantName(athlete),
      ],
      heat: heat,
      lane: found?.lane.lane,
      forfeit: found != null ? found.lane.forfeit : (unread ? null : false),
      // Sa course si elle est connue, sinon la première du tour à courir.
      deadline: forfeitDeadline(
        heat?.plannedStart ?? toRun.firstOrNull?.plannedStart,
      ),
    );
  }

  /// Relit les places, et ce qui en amont a échoué.
  Future<void> refresh() async {
    if (!ref.mounted) return;
    final club = clubProvider(key);
    if (ref.read(club).hasError) ref.invalidate(club);
    final competition = spaceCompetitionProvider(key.competitionId);
    if (ref.read(competition).hasError) ref.invalidate(competition);
    ref.invalidateSelf();
    try {
      await future;
    } on AppException {
      // L'échec est dans `state`, que la page montre.
    }
  }

  /// Déclare ou annule tout de suite, sans confirmation (décision du
  /// 2026-10-19) ni file d'envoi : l'interrupteur change aussitôt, revient
  /// en cas d'échec, et la place est relue après un succès pour confirmer.
  Future<ForfeitOutcome> toggle(int entryId) async {
    final item = state.value?.where((f) => f.entryId == entryId).firstOrNull;
    final previous = item?.forfeit;
    // État inconnu : rien ne dit dans quel sens basculer.
    if (item == null ||
        previous == null ||
        item.sending == ForfeitSending.sending) {
      return ForfeitOutcome.failed;
    }
    if (!_allowed()) return ForfeitOutcome.notAllowed;
    // L'écran a pu rester ouvert après l'échéance.
    if (forfeitLocked(item.deadline, ref.read(clockProvider)())) {
      return ForfeitOutcome.locked;
    }
    final engagements = ref.read(engagementRepositoryProvider);
    final meetings = ref.read(meetingRepositoryProvider);
    final target = !previous;
    _update(
      entryId,
      (f) => f.copyWith(forfeit: target, sending: ForfeitSending.sending),
    );
    try {
      await engagements.setForfeit(entryId, forfeit: target);
    } on AppException {
      if (ref.mounted) {
        _update(
          entryId,
          (f) => f.copyWith(forfeit: previous, sending: ForfeitSending.idle),
        );
      }
      return ForfeitOutcome.failed;
    }
    if (!ref.mounted) return ForfeitOutcome.done;

    var confirmed = target;
    if (_places[entryId] case final placeId?) {
      try {
        final lanes = await meetings.getLanes([placeId]);
        if (!ref.mounted) return ForfeitOutcome.done;
        if (lanes[placeId] case final lane? when lane.entryId == entryId) {
          confirmed = lane.forfeit;
        }
      } on AppException {
        // L'envoi a réussi : son état reste.
      }
    }
    _update(
      entryId,
      (f) => f.copyWith(forfeit: confirmed, sending: ForfeitSending.idle),
    );
    return ForfeitOutcome.done;
  }

  /// Comme la saisie, un droit établi pour la session en cours : pendant une
  /// relecture des rôles, ou si elle échoue, rien ne part.
  bool _allowed() {
    if (ref.read(sessionProvider).value == null) return false;
    final roles = ref.read(competitionRolesProvider(key.competitionId));
    if (roles.isLoading || roles.hasError) return false;
    return clubRole(roles.value, key.clubId) != ClubRole.none;
  }

  void _update(int entryId, ClubForfeit Function(ClubForfeit) change) {
    final list = state.value;
    if (list == null) return;
    state = AsyncData([
      for (final f in list) f.entryId == entryId ? change(f) : f,
    ]);
  }
}
