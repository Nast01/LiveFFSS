import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';

part 'programme_events.freezed.dart';

/// Un tour d'une épreuve : une colonne de son déroulement (les finales par
/// catégorie, A et B, en font une seule) et ses créneaux sur tout le
/// programme, tous jours confondus.
@freezed
abstract class EventStep with _$EventStep {
  const EventStep._();

  const factory EventStep({
    required StageLevel level,

    /// Les étapes réunies dans le tour : plus d'une se dit « Finales ».
    @Default(1) int stageCount,
    @Default(<MeetingItem>[]) List<MeetingItem> items,

    /// `none` pour un tour prévu au déroulement sans créneau au programme.
    required ItemStatus status,
  }) = _EventStep;

  /// L'heure du premier de ses créneaux.
  DateTime? get start {
    DateTime? first;
    for (final item in items) {
      final time = item.startTime;
      if (time != null && (first == null || time.isBefore(first))) {
        first = time;
      }
    }
    return first;
  }
}

/// Une épreuve telle qu'une réunion la montre : ses créneaux dans cette
/// réunion, et son parcours sur toute la compétition.
@freezed
abstract class ProgrammeEvent with _$ProgrammeEvent {
  const ProgrammeEvent._();

  const factory ProgrammeEvent({
    /// `p<id>` pour une épreuve du déroulement, `i<id>` pour un créneau de
    /// course qu'aucun déroulement ne porte : de quoi la retrouver à
    /// l'ouverture de la vue.
    required String key,
    required String name,
    Gender? gender,
    @Default(<String>[]) List<String> categories,

    /// Vide quand l'épreuve n'est pas au déroulement.
    @Default(<EventStep>[]) List<EventStep> steps,

    /// Ses créneaux dans la réunion, dans l'ordre du programme.
    @Default(<MeetingItem>[]) List<MeetingItem> items,

    /// L'état de ces créneaux-là (`stageStatus`).
    required ItemStatus status,
  }) = _ProgrammeEvent;

  /// Les séries de ses créneaux dans la réunion : une pastille chacune.
  List<Heat> get heats => [for (final item in items) ...item.heats];
}

/// Une ligne d'une réunion : une épreuve, ou un créneau sans course
/// (échauffement, pause), montré à sa place dans le temps.
@freezed
sealed class MeetingEntry with _$MeetingEntry {
  const factory MeetingEntry.event(ProgrammeEvent event) = EventEntry;
  const factory MeetingEntry.pause(MeetingItem item) = PauseEntry;
}

/// Les lignes de [meeting] : une carte par épreuve, à la place de son premier
/// créneau, qui réunit tous ses créneaux de la réunion. Le parcours se lit
/// sur [programme] entier, pour qu'une carte de séries dise déjà quand se
/// courent les finales.
List<MeetingEntry> meetingEntries(Meeting meeting, Programme programme) {
  final order = <String>[];
  final pauses = <String, MeetingItem>{};
  final itemsByKey = <String, List<MeetingItem>>{};
  final progressionByKey = <String, Progression?>{};
  for (final item in meeting.items) {
    if (item.heats.isEmpty) {
      final key = 'pause${item.id}';
      order.add(key);
      pauses[key] = item;
      continue;
    }
    final roundId = item.roundId;
    final progression = roundId == null
        ? null
        : programme.progressionOfStage(roundId);
    final key = progression == null ? 'i${item.id}' : 'p${progression.id}';
    if (!itemsByKey.containsKey(key)) {
      order.add(key);
      progressionByKey[key] = progression;
    }
    (itemsByKey[key] ??= []).add(item);
  }
  return [
    for (final key in order)
      if (pauses[key] case final pause?)
        MeetingEntry.pause(pause)
      else
        MeetingEntry.event(
          _event(key, progressionByKey[key], itemsByKey[key]!, programme),
        ),
  ];
}

ProgrammeEvent _event(
  String key,
  Progression? progression,
  List<MeetingItem> items,
  Programme programme,
) {
  final status = stageStatus(items);
  if (progression == null) {
    return ProgrammeEvent(
      key: key,
      name: items.first.name,
      items: items,
      status: status,
    );
  }
  return ProgrammeEvent(
    key: key,
    name: progression.disciplineName.isNotEmpty
        ? progression.disciplineName
        : progression.name,
    gender: progression.gender,
    categories: progression.categories,
    steps: [
      for (final column in progressionColumns(progression))
        _step(column, programme.meetings),
    ],
    items: items,
    status: status,
  );
}

EventStep _step(List<Stage> column, List<Meeting> meetings) {
  final items = [
    for (final stage in column) ...itemsOfStage(meetings, stage.id),
  ]..sort(_byStart);
  return EventStep(
    level: column.first.level,
    stageCount: column.length,
    items: items,
    status: stageStatus(items),
  );
}

int _byStart(MeetingItem a, MeetingItem b) {
  final x = a.startTime;
  final y = b.startTime;
  if (x == null || y == null) return 0;
  return x.compareTo(y);
}

/// Le créneau qu'ouvre un toucher : celui en cours, sinon le premier qui
/// n'est pas terminé, sinon le premier.
MeetingItem? eventTarget(List<MeetingItem> items) {
  for (final item in items) {
    if (itemStatus(item) == ItemStatus.live) return item;
  }
  for (final item in items) {
    if (itemStatus(item) != ItemStatus.finished) return item;
  }
  return items.isEmpty ? null : items.first;
}

/// Vrai quand chaque tour de l'épreuve est couru : un tour prévu sans créneau
/// au programme ne l'est pas.
bool allStepsFinished(ProgrammeEvent event) =>
    event.steps.isNotEmpty &&
    event.steps.every((step) => step.status == ItemStatus.finished);

/// L'épreuve sur laquelle ouvrir la journée [meetings] : celle en cours,
/// sinon la première qui n'est pas terminée. Nulle quand tout est couru.
({int meetingId, String eventKey})? programmeFocus(
  List<Meeting> meetings,
  Programme programme,
) {
  ({int meetingId, String eventKey})? next;
  for (final meeting in meetings) {
    for (final entry in meetingEntries(meeting, programme)) {
      if (entry is! EventEntry) continue;
      final event = entry.event;
      if (event.status == ItemStatus.live) {
        return (meetingId: meeting.id, eventKey: event.key);
      }
      if (next == null && event.status != ItemStatus.finished) {
        next = (meetingId: meeting.id, eventKey: event.key);
      }
    }
  }
  return next;
}

/// L'épreuve sur laquelle ouvrir la vue : seulement quand le jour affiché
/// [day] est aujourd'hui ; un autre jour s'ouvre en haut, à sa première
/// réunion.
({int meetingId, String eventKey})? openingFocus(
  Programme programme,
  DateTime? day,
  DateTime now,
) {
  if (day == null ||
      day.year != now.year ||
      day.month != now.month ||
      day.day != now.day) {
    return null;
  }
  return programmeFocus(meetingsOfDay(programme.meetings, day), programme);
}
