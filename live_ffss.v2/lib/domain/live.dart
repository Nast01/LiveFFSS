import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'live.freezed.dart';

/// Le nombre de séries courues que l'onglet Live garde : au-delà, la liste
/// devient un second programme.
const int liveRecentLimit = 10;

/// Une série avec le créneau et la réunion qui la portent.
@freezed
abstract class LiveEntry with _$LiveEntry {
  const LiveEntry._();

  const factory LiveEntry({
    required Meeting meeting,
    required MeetingItem item,
    required Heat heat,
  }) = _LiveEntry;

  /// Le créneau donne l'heure quand FFSS n'en sert pas pour la série.
  DateTime? get start => heat.plannedStart ?? item.startTime;
}

/// Toutes les séries, dans l'ordre du programme.
List<LiveEntry> _entries(List<Meeting> meetings) => [
  for (final meeting in meetings)
    for (final item in meeting.items)
      for (final heat in item.heats)
        LiveEntry(meeting: meeting, item: item, heat: heat),
];

/// Les séries du Live : celles qui se courent (chambre d'appel ou en cours),
/// puis les dernières terminées et publiées.
///
/// L'heure est une date complète (le mapper place la série sur le jour de sa
/// réunion) : le tri tient donc sur plusieurs jours. Une série terminée sans
/// série FFSS n'a pas de résultats à montrer.
({List<LiveEntry> running, List<LiveEntry> recent}) liveSelection(
  List<Meeting> meetings,
) {
  final entries = _entries(meetings);
  final order = {
    for (var i = 0; i < entries.length; i++) entries[i].heat.id: i,
  };

  final running = [
    for (final entry in entries)
      if (entry.heat.status == RunStatus.marshalling ||
          entry.heat.status == RunStatus.inProgress)
        entry,
  ]..sort((a, b) => _compareStart(a, b, order, descending: false));

  final recent = [
    for (final entry in entries)
      if (entry.heat.status == RunStatus.finished &&
          entry.heat.seriesId != null)
        entry,
  ]..sort((a, b) => _compareStart(a, b, order, descending: true));

  return (running: running, recent: recent.take(liveRecentLimit).toList());
}

/// Une série sans heure passe en fin dans les deux sens. À heure égale,
/// l'ordre du programme départage (inversé pour les plus récentes d'abord).
int _compareStart(
  LiveEntry a,
  LiveEntry b,
  Map<int, int> order, {
  required bool descending,
}) {
  final sa = a.start;
  final sb = b.start;
  if (sa == null || sb == null) {
    if (sa == null && sb == null) {
      return _byProgram(a, b, order, descending);
    }
    return sa == null ? 1 : -1;
  }
  final byTime = descending ? sb.compareTo(sa) : sa.compareTo(sb);
  return byTime != 0 ? byTime : _byProgram(a, b, order, descending);
}

int _byProgram(LiveEntry a, LiveEntry b, Map<int, int> order, bool descending) {
  final byOrder = order[a.heat.id]!.compareTo(order[b.heat.id]!);
  return descending ? -byOrder : byOrder;
}

/// Temporaire tant que la série n'est pas terminée, ou que le libellé FFSS
/// ne dit pas autre chose.
bool isProvisional(Heat heat) =>
    heat.status != RunStatus.finished || heat.resultsProvisional;

/// Vrai dès qu'une place porte un temps, une DQ ou un forfait : un statut
/// « OK » sans temps n'est pas un résultat.
bool hasPublishedResults(Iterable<LaneAssignment> lanes) => lanes.any(
  (lane) =>
      lane.forfeit == true ||
      (lane.performance?.isDisqualified ?? false) ||
      (lane.performance?.time?.trim().isNotEmpty ?? false),
);

/// Les places occupées : d'abord celles qui ont une place dans la série, par
/// place croissante (un ex aequo garde l'ordre des couloirs), puis les autres
/// par couloir. [places] évite de recalculer `heatPlaces` quand l'appelant
/// l'a déjà.
List<LaneAssignment> resultOrder(
  List<LaneAssignment> lanes, {
  Map<int, int>? places,
}) {
  final placeOf = places ?? heatPlaces(lanes);
  final occupied = [
    for (final lane in lanes)
      if (!lane.isEmpty) lane,
  ]..sort((a, b) => a.lane.compareTo(b.lane));
  final placed = occupied.where((l) => placeOf.containsKey(l.id)).toList()
    // `List.sort` n'est pas stable : le couloir départage les ex aequo.
    ..sort((a, b) {
      final byPlace = placeOf[a.id]!.compareTo(placeOf[b.id]!);
      return byPlace != 0 ? byPlace : a.lane.compareTo(b.lane);
    });
  return [
    ...placed,
    for (final lane in occupied)
      if (!placeOf.containsKey(lane.id)) lane,
  ];
}

/// La première série « En attente » dans l'ordre du programme, pour l'état
/// où rien ne se court.
LiveEntry? nextScheduled(List<Meeting> meetings) {
  for (final entry in _entries(meetings)) {
    if (entry.heat.status == RunStatus.waiting) return entry;
  }
  return null;
}

/// Le rang de la série parmi celles de la même épreuve et du même tour
/// (« Série 4/10 »). V3 peut répartir les séries d'un tour sur plusieurs
/// créneaux, d'où le regroupement par partie et non par créneau. Un créneau
/// sans partie forme son propre groupe.
({int position, int total}) heatPosition(
  List<Meeting> meetings,
  LiveEntry entry,
) {
  final key = _roundOf(entry);
  final group = [
    for (final other in _entries(meetings))
      if (_roundOf(other) == key) other.heat,
  ]..sort(_byHeatNumber);

  return (position: group.indexOf(entry.heat) + 1, total: group.length);
}

String _roundOf(LiveEntry e) =>
    '${e.heat.raceId}|'
    '${e.item.roundId != null ? 'r${e.item.roundId}' : 'c${e.item.id}'}';

int _byHeatNumber(Heat a, Heat b) {
  final early = DateTime(0);
  final order = a.number.compareTo(b.number);
  if (order != 0) return order;
  return (a.plannedStart ?? early).compareTo(b.plannedStart ?? early);
}

/// Les séries qu'un officiel peut saisir, dans l'ordre où ‹ › les parcourt :
/// les tours dans l'ordre du programme, et toutes les séries d'un tour avant
/// le suivant, même réparties sur plusieurs créneaux. Une série sans série
/// FFSS (finale pas encore générée) n'a rien où écrire.
List<LiveEntry> entrySequence(List<Meeting> meetings) {
  final entries = _entries(meetings);
  final order = {
    for (var i = 0; i < entries.length; i++) entries[i].heat.id: i,
  };
  final rounds = <String, List<LiveEntry>>{};
  for (final entry in entries) {
    if (entry.heat.seriesId == null) continue;
    rounds.putIfAbsent(_roundOf(entry), () => []).add(entry);
  }
  // `List.sort` n'est pas stable : l'ordre du programme départage, pour que
  // ‹ puis › ramène toujours à la même série.
  int compare(LiveEntry a, LiveEntry b) {
    final byNumber = _byHeatNumber(a.heat, b.heat);
    return byNumber != 0
        ? byNumber
        : order[a.heat.id]!.compareTo(order[b.heat.id]!);
  }

  return [for (final round in rounds.values) ...round..sort(compare)];
}
