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

/// [busy] : un envoi est déjà en vol pour cet engagement. [unconfirmed] :
/// le site a accepté, mais la place relue montre l'état d'avant.
enum ForfeitOutcome { done, locked, notAllowed, failed, busy, unconfirmed }

/// Le dernier envoi réussi : pour un engagement dont la place n'est pas
/// lue, c'est tout ce que l'app sait, et elle ne le fait pas passer pour un
/// état lu.
typedef ForfeitSent = ({bool forfeit, DateTime at});

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

    /// Nul sans place qui le porte : seule la place dit le forfait.
    bool? forfeit,

    /// Une place du tour n'a pu être lue : elle pouvait le porter.
    @Default(false) bool placesUnread,
    DateTime? deadline,

    /// Plus rien à déclarer, quelle que soit l'heure : sa course n'attend
    /// plus (chambre d'appel, en cours ou courue), ou aucune échéance n'est
    /// connue.
    @Default(false) bool locked,
    ForfeitSent? lastSent,
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
/// Sont lues les places du tour séries de chaque épreuve du club, celles des
/// courses en attente d'abord puis celles des autres (un engagement trouvé
/// dans une course partie ou courue est verrouillé), 6 au plus en vol, jusqu'à
/// trouver chaque engagement ; à l'ouverture et par
/// [ClubForfeitsNotifier.refresh], sans minuterie.
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

  /// Le créneau de la course dont dépend chaque engagement (la sienne, ou
  /// celle qui donne l'échéance) : relu juste avant d'envoyer.
  final _slots = <int, ({int heatId, int itemId, DateTime day})>{};

  /// Gardés hors de `state` : une relecture pendant un envoi les remet.
  final _inFlight = <int>{};
  final _sent = <int, ForfeitSent>{};

  @override
  Future<List<ClubForfeit>> build() async {
    final competitionId = key.competitionId;
    // Gardés en vie pour [setForfeit], sans tout relire à chaque relecture
    // des droits : le droit se vérifie au moment d'envoyer.
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

      final entries = clubEntries(club.athletes, events);
      final roundOf = {
        for (final entry in entries)
          entry.event.id: heatsRoundOf(programme, entry.event),
      };
      // Une course est partagée par les catégories d'une même discipline :
      // chaque place n'est lue qu'une fois. Les courses à courir d'abord :
      // c'est là que sont les engagements à déclarer.
      final heatOfPlace = <int, Heat>{};
      for (final waiting in [true, false]) {
        for (final round in roundOf.values) {
          for (final heat in round) {
            if ((heat.status == RunStatus.waiting) != waiting) continue;
            for (final placeId in heat.placeIds) {
              heatOfPlace.putIfAbsent(placeId, () => heat);
            }
          }
        }
      }
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
      final slotOfHeat = {
        for (final meeting in programme.meetings)
          for (final item in meeting.items)
            for (final heat in item.heats)
              heat.id: (heatId: heat.id, itemId: item.id, day: meeting.day),
      };
      final forfeits = [
        for (final entry in entries)
          _forfeitOf(
            entry,
            roundOf[entry.event.id]!,
            found[entry.entryId],
            heatOfPlace,
            read,
          ),
      ];
      _slots
        ..clear()
        ..addAll({
          for (final (forfeit, heat) in forfeits)
            forfeit.entryId: ?slotOfHeat[heat?.id],
        });
      return [
        for (final (forfeit, _) in forfeits)
          forfeit.copyWith(
            lastSent: _sent[forfeit.entryId],
            sending: _inFlight.contains(forfeit.entryId)
                ? ForfeitSending.sending
                : ForfeitSending.idle,
          ),
      ];
    } finally {
      for (final subscription in subscriptions) {
        subscription.close();
      }
    }
  }

  /// L'engagement, et la course à revérifier avant d'envoyer : la sienne,
  /// sinon la plus tôt du tour en attente, qui donne l'échéance.
  static (ClubForfeit, Heat?) _forfeitOf(
    ClubEntry entry,
    List<Heat> round,
    ({int placeId, LaneAssignment lane})? found,
    Map<int, Heat> heatOfPlace,
    Set<int> read,
  ) {
    final heat = found == null ? null : heatOfPlace[found.placeId];
    bool unread(Heat h) => h.placeIds.any((id) => !read.contains(id));
    // Une course peut partir avant son heure prévue : seule une course en
    // attente laisse encore déclarer.
    final waiting = [
      for (final h in round)
        if (h.status == RunStatus.waiting && h.plannedStart != null) h,
    ]..sort((a, b) => a.plannedStart!.compareTo(b.plannedStart!));
    final checked = heat ?? waiting.firstOrNull;
    final deadline = forfeitDeadline(checked?.plannedStart);
    final started =
        (heat != null && heat.status != RunStatus.waiting) ||
        // Une place illisible d'une course partie pouvait le porter.
        (found == null &&
            round.any((h) => h.status != RunStatus.waiting && unread(h)));
    final forfeit = ClubForfeit(
      entryId: entry.entryId,
      event: entry.event,
      athletes: [
        for (final athlete in entry.athletes) participantName(athlete),
      ],
      heat: heat,
      lane: found?.lane.lane,
      forfeit: found?.lane.forfeit,
      placesUnread: found == null && round.any(unread),
      deadline: deadline,
      // Sans échéance, rien ne dit que la course n'est pas passée.
      locked: started || deadline == null,
    );
    return (forfeit, checked);
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

  /// Déclare ([forfeit] vrai) ou annule tout de suite, sans confirmation
  /// (décision du 2026-10-19) ni file d'envoi : un état connu change
  /// aussitôt, revient en cas d'échec, et la place est relue après un
  /// succès pour confirmer. Un état inconnu le reste : l'envoi est gardé à
  /// part ([ClubForfeit.lastSent]).
  Future<ForfeitOutcome> setForfeit(
    int entryId, {
    required bool forfeit,
  }) async {
    final item = state.value?.where((f) => f.entryId == entryId).firstOrNull;
    if (item == null) return ForfeitOutcome.failed;
    if (_inFlight.contains(entryId)) return ForfeitOutcome.busy;
    if (!_allowed()) return ForfeitOutcome.notAllowed;
    // L'écran a pu rester ouvert après l'échéance.
    if (item.locked ||
        forfeitLocked(item.deadline, ref.read(clockProvider)())) {
      return ForfeitOutcome.locked;
    }
    final engagements = ref.read(engagementRepositoryProvider);
    final meetings = ref.read(meetingRepositoryProvider);
    final clock = ref.read(clockProvider);
    final previous = item.forfeit;
    _inFlight.add(entryId);
    _update(entryId, (f) => f.copyWith(sending: ForfeitSending.sending));
    try {
      // Une course peut partir avant son heure prévue : l'état lu à
      // l'ouverture ne suffit pas.
      final bool waiting;
      try {
        waiting = await _stillWaiting(meetings, entryId);
      } on AppException {
        return ForfeitOutcome.failed;
      }
      if (!ref.mounted) return ForfeitOutcome.failed;
      if (!waiting) {
        _update(entryId, (f) => f.copyWith(locked: true));
        return ForfeitOutcome.locked;
      }
      _update(
        entryId,
        (f) => f.copyWith(forfeit: previous == null ? null : forfeit),
      );
      try {
        await engagements.setForfeit(entryId, forfeit: forfeit);
      } on AppException {
        _update(entryId, (f) => f.copyWith(forfeit: previous));
        return ForfeitOutcome.failed;
      }
      _sent[entryId] = (forfeit: forfeit, at: clock());
      if (!ref.mounted) return ForfeitOutcome.done;
      _update(entryId, (f) => f.copyWith(lastSent: _sent[entryId]));

      final placeId = _places[entryId];
      if (placeId == null) return ForfeitOutcome.done;
      try {
        final lanes = await meetings.getLanes([placeId]);
        if (!ref.mounted) return ForfeitOutcome.done;
        if (lanes[placeId] case final lane? when lane.entryId == entryId) {
          _update(entryId, (f) => f.copyWith(forfeit: lane.forfeit));
          if (lane.forfeit != forfeit) return ForfeitOutcome.unconfirmed;
        }
      } on AppException {
        // L'envoi a réussi : son état reste.
      }
      return ForfeitOutcome.done;
    } finally {
      _inFlight.remove(entryId);
      _update(entryId, (f) => f.copyWith(sending: ForfeitSending.idle));
    }
  }

  /// La course de l'engagement est-elle toujours en attente ? Relue sur son
  /// créneau, une seule lecture légère. Lève [AppException] si le créneau ne
  /// se lit pas ; une course absente du créneau relu ne laisse rien partir.
  Future<bool> _stillWaiting(MeetingRepository meetings, int entryId) async {
    final slot = _slots[entryId];
    if (slot == null) return false;
    final item = await meetings.getMeetingItem(slot.itemId, day: slot.day);
    final heat = item?.heats.where((h) => h.id == slot.heatId).firstOrNull;
    return heat?.status == RunStatus.waiting;
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
    if (!ref.mounted) return;
    final list = state.value;
    if (list == null) return;
    state = AsyncData([
      for (final f in list) f.entryId == entryId ? change(f) : f,
    ]);
  }
}
