import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/live.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';

part 'entry_view.freezed.dart';

/// Au plus `mmsscc` : au-delà, le pavé ne prend plus de chiffre.
const int maxChronoDigits = 6;

/// Les chiffres d'un champ après l'appui sur [digit]. [replace] : le champ
/// vient d'être choisi, et le premier chiffre tapé remplace ce qu'il montrait
/// (ajouter un chiffre à un temps déjà saisi en ferait un autre, dix fois
/// plus long).
String typeChronoDigit(String digits, String digit, {required bool replace}) {
  if (replace) return digit;
  return digits.length >= maxChronoDigits ? digits : '$digits$digit';
}

String eraseChronoDigit(String digits) =>
    digits.isEmpty ? digits : digits.substring(0, digits.length - 1);

/// Les chiffres qui, tapés au pavé, redonnent [hundredths] : de quoi montrer
/// un chrono déjà saisi dans son champ. Vide sans chrono.
String chronoDigitsOf(int? hundredths) {
  if (hundredths == null || hundredths <= 0) return '';
  final minutes = hundredths ~/ 6000;
  final seconds = hundredths % 6000 ~/ 100;
  final rest = hundredths % 100;
  return (minutes * 10000 + seconds * 100 + rest).toString();
}

/// Un champ rempli que [parseChronoDigits] refuse (secondes au-delà de 59).
bool isChronoInvalid(String digits) =>
    digits.isNotEmpty && parseChronoDigits(digits) == null;

/// La valeur d'un champ : nulle s'il est vide ou à zéro, que le site range
/// de même comme « pas de chrono ».
int? chronoValue(String digits) {
  final value = parseChronoDigits(digits);
  return value != null && value > 0 ? value : null;
}

/// Les trois chronos d'une saisie, ou nul si un champ est invalide.
List<int?>? draftChronos(List<String> digits) {
  if (digits.any(isChronoInvalid)) return null;
  return [for (final d in digits) chronoValue(d)];
}

/// Les champs d'un couloir : ce que l'officiel a tapé sans l'enregistrer
/// ([draft]), sinon ses chronos actuels. Un couloir en lecture seule montre
/// le site tel quel : des chiffres tapés avant la validation ne partiront
/// jamais.
List<String> laneDigits(EntryLane lane, List<String>? draft) =>
    (lane.editable ? draft : null) ??
    [for (final c in lane.result.chronos) chronoDigitsOf(c)];

/// Vrai quand [draft] change les chronos du couloir : un invalide compte,
/// il n'est pas enregistré.
bool hasUnsavedDraft(EntryLane lane, List<String>? draft) {
  if (draft == null || !lane.editable) return false;
  final chronos = draftChronos(draft);
  return chronos == null || !_sameChronos(chronos, lane.result.chronos);
}

bool _sameChronos(List<int?> a, List<int?> b) {
  for (var i = 0; i < chronoCount; i++) {
    if (a.elementAtOrNull(i) != b.elementAtOrNull(i)) return false;
  }
  return true;
}

/// Sans série FFSS (finale à venir), rien où écrire.
bool canEnterHeat(Heat heat) => heat.seriesId != null;

enum EntrySendState { none, pending, sent, rejected }

/// Un couloir de l'écran de saisie.
@freezed
abstract class EntryLane with _$EntryLane {
  const factory EntryLane({
    required LaneAssignment lane,

    /// Le résultat lu sur le site, avec par-dessus les saisies pas encore
    /// écrites, ou écrites après la lecture.
    required RaceResult result,

    /// Le juge des résultats a posé un `temps` : lecture seule.
    @Default(false) bool validatedByJudge,

    /// Faux sans engagement ou une fois validé : rien ne peut partir.
    @Default(false) bool editable,
    @Default(EntrySendState.none) EntrySendState sendState,

    /// La dernière opération refusée du couloir, pour en dire la raison et
    /// proposer de la réessayer ou de l'écarter.
    OutboxOperation? rejected,
  }) = _EntryLane;
}

/// Les couloirs occupés [lanes] d'une série, avec les résultats lus à
/// [readAt] ([results] par engagement) et les saisies de [account] en file.
List<EntryLane> entryLanes({
  required Heat heat,
  required List<LaneAssignment> lanes,
  required Map<int, RaceResult> results,
  required List<OutboxOperation> queue,
  required String? account,
  required DateTime readAt,
}) => [
  for (final lane in lanes)
    _entryLane(lane, results[lane.entryId] ?? _fromPlace(heat, lane), [
      if (account != null)
        for (final op in queue)
          if (op.placeId == lane.id && isSameAccount(op.account, account)) op,
    ], readAt),
];

EntryLane _entryLane(
  LaneAssignment lane,
  RaceResult server,
  List<OutboxOperation> ops,
  DateTime readAt,
) {
  final validated = isValidatedByJudge(server);
  var result = server;
  // Validé : le site tel quel. Une saisie en file y sera refusée.
  for (final op in validated ? const <OutboxOperation>[] : ops) {
    // Une opération envoyée avant la lecture y est déjà ; après, le site
    // lu est en retard sur elle.
    final sentAt = op.sentAt;
    final unread =
        op.state == OutboxState.pending ||
        (op.state == OutboxState.sent &&
            sentAt != null &&
            !sentAt.isBefore(readAt));
    if (unread) result = applyChange(result, op.change);
  }
  final last = ops.lastOrNull;
  return EntryLane(
    lane: lane,
    result: result,
    validatedByJudge: validated,
    editable: !validated && lane.entryId != null,
    sendState: ops.any((o) => o.state == OutboxState.pending)
        ? EntrySendState.pending
        : switch (last?.state) {
            OutboxState.rejected => EntrySendState.rejected,
            OutboxState.sent => EntrySendState.sent,
            _ => EntrySendState.none,
          },
    rejected: ops.lastWhereOrNull((o) => o.state == OutboxState.rejected),
  );
}

/// Faute de ligne dans la série (pas encore de résultat, ou ligne
/// illisible), ce que la place publie.
RaceResult _fromPlace(Heat heat, LaneAssignment lane) {
  final performance = lane.performance;
  final disqualified = performance?.isDisqualified ?? false;
  return RaceResult(
    id: lane.resultId,
    seriesId: heat.seriesId ?? 0,
    entryId: lane.entryId ?? 0,
    time: performance?.timeHundredths,
    status: disqualified
        ? statusDisqualified
        : lane.forfeit
        ? statusForfeit
        : statusOk,
    complement: disqualified ? performance?.disqualificationCode ?? '' : '',
  );
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (var i = length - 1; i >= 0; i--) {
      if (test(this[i])) return this[i];
    }
    return null;
  }
}

/// Réessayer une saisie que le juge a validée retomberait sur le même refus :
/// on ne peut que l'écarter.
bool canRetryRejection(OutboxOperation op) =>
    op.rejection != OutboxRejection.validatedByJudge;

enum EntryLaneAction {
  disqualify,
  editDisqualification,
  cancelDisqualification,
  forfeit,
  cancelForfeit,
}

/// Ce que l'officiel peut faire du statut d'un couloir : rien une fois
/// validé, annuler la DQ ou le forfait posé, sinon les poser.
List<EntryLaneAction> laneActions(EntryLane lane) {
  if (!lane.editable) return const [];
  return switch (lane.result.status) {
    statusDisqualified => const [
      EntryLaneAction.editDisqualification,
      EntryLaneAction.cancelDisqualification,
    ],
    statusForfeit => const [EntryLaneAction.cancelForfeit],
    _ => const [EntryLaneAction.disqualify, EntryLaneAction.forfeit],
  };
}

/// La série ouverte dans l'écran de saisie, et ses voisines pour ‹ ›.
@freezed
abstract class EntryCursor with _$EntryCursor {
  const factory EntryCursor({
    required LiveEntry entry,
    required ({int position, int total}) position,
    LiveEntry? previous,
    LiveEntry? next,
  }) = _EntryCursor;
}

/// [heatId] s'il peut être saisi, sinon la première série saisissable du
/// créneau [itemId] ; nul s'il n'y en a pas.
EntryCursor? entryCursor(
  List<Meeting> meetings, {
  required int itemId,
  int? heatId,
}) {
  final sequence = entrySequence(meetings);
  var index = sequence.indexWhere((e) => e.heat.id == heatId);
  if (index < 0) index = sequence.indexWhere((e) => e.item.id == itemId);
  if (index < 0) return null;
  final entry = sequence[index];
  return EntryCursor(
    entry: entry,
    position: heatPosition(meetings, entry),
    previous: index > 0 ? sequence[index - 1] : null,
    next: index + 1 < sequence.length ? sequence[index + 1] : null,
  );
}

enum EntryMode {
  /// « Tous » : la liste des couloirs.
  list,

  /// Un couloir en grand.
  lane,

  /// Le couloir du filtre n'a personne dans cette série.
  emptyLane,
}

typedef EntryFocus = ({EntryMode mode, EntryLane? lane});

/// Ce que l'écran montre : le couloir du filtre ([filter]) quand il y en a
/// un, sinon celui ouvert depuis la liste ([openPlaceId]), sinon la liste.
EntryFocus entryFocus(
  List<EntryLane> lanes, {
  required int? filter,
  required int? openPlaceId,
}) {
  if (filter != null) {
    for (final lane in lanes) {
      if (lane.lane.lane == filter) return (mode: EntryMode.lane, lane: lane);
    }
    return (mode: EntryMode.emptyLane, lane: null);
  }
  for (final lane in lanes) {
    if (lane.lane.id == openPlaceId) return (mode: EntryMode.lane, lane: lane);
  }
  return (mode: EntryMode.list, lane: null);
}

/// Les couloirs du filtre : de 1 au dernier occupé, sans perdre celui choisi
/// quand une série en a moins.
List<int> laneFilterOptions(List<EntryLane> lanes, int? filter) {
  var last = filter ?? 0;
  for (final lane in lanes) {
    if (lane.lane.lane > last) last = lane.lane.lane;
  }
  return [for (var n = 1; n <= last; n++) n];
}
