import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';

part 'programme.freezed.dart';

/// Ce que le bureau publie d'une compétition : ses réunions et le déroulement
/// de ses épreuves.
@freezed
abstract class Programme with _$Programme {
  const Programme._();

  const factory Programme({
    @Default(<Meeting>[]) List<Meeting> meetings,
    @Default(<Progression>[]) List<Progression> progressions,
  }) = _Programme;

  Progression? progressionOfStage(int stageId) {
    for (final progression in progressions) {
      if (progression.stageById(stageId) != null) return progression;
    }
    return null;
  }

  ({Meeting meeting, MeetingItem item})? findItem(int itemId) {
    for (final meeting in meetings) {
      for (final item in meeting.items) {
        if (item.id == itemId) return (meeting: meeting, item: item);
      }
    }
    return null;
  }
}

/// La liste des séries ne dit pas de quelle épreuve elles sont : la réunion les
/// publie sans `epreuve`. Le déroulement, lui, connaît la discipline, le sexe
/// et les parties ; on rattache donc chaque série à l'épreuve de sa partie.
/// Une course qui porte déjà son épreuve (forme de la v1) la garde.
List<Meeting> withRaces(
  List<Meeting> meetings,
  List<Progression> progressions,
) {
  if (progressions.isEmpty) return meetings;
  final lookup = Programme(progressions: progressions);

  return [
    for (final meeting in meetings)
      meeting.copyWith(
        items: [
          for (final item in meeting.items)
            switch (item.roundId == null
                ? null
                : lookup.progressionOfStage(item.roundId!)) {
              final progression? => item.copyWith(
                heats: [
                  for (final heat in item.heats)
                    heat.raceName.isNotEmpty
                        ? heat
                        : heat.copyWith(
                            raceId: progression.id,
                            raceName: progression.disciplineName,
                            gender: progression.gender,
                          ),
                ],
              ),
              _ => item,
            },
        ],
      ),
  ];
}

/// Les jours distincts du programme, du plus ancien au plus récent.
List<DateTime> programmeDays(List<Meeting> meetings) {
  final days = {
    for (final meeting in meetings)
      DateTime(meeting.day.year, meeting.day.month, meeting.day.day),
  };
  return days.toList()..sort();
}

/// Les réunions d'un jour, dans l'ordre reçu.
List<Meeting> meetingsOfDay(List<Meeting> meetings, DateTime day) => [
  for (final meeting in meetings)
    if (meeting.day.year == day.year &&
        meeting.day.month == day.month &&
        meeting.day.day == day.day)
      meeting,
];

/// Le jour à montrer à l'ouverture : aujourd'hui s'il est au programme, sinon
/// le plus proche côté début (avant la compétition) ou côté fin (après).
DateTime? initialDay(List<DateTime> days, DateTime today) {
  if (days.isEmpty) return null;
  final midnight = DateTime(today.year, today.month, today.day);
  if (days.contains(midnight)) return midnight;
  return midnight.isBefore(days.first) ? days.first : days.last;
}

/// L'état d'un créneau, déduit de ses courses.
enum ItemStatus { none, live, finished, seriesPending, upcoming }

ItemStatus itemStatus(MeetingItem item) {
  final heats = item.heats;
  if (heats.isEmpty) return ItemStatus.none;
  if (heats.any(
    (h) =>
        h.status == RunStatus.marshalling || h.status == RunStatus.inProgress,
  )) {
    return ItemStatus.live;
  }
  if (heats.every((h) => h.status == RunStatus.finished)) {
    return ItemStatus.finished;
  }
  if (heats.every((h) => h.seriesId == null)) return ItemStatus.seriesPending;
  return ItemStatus.upcoming;
}

/// L'état d'une seule course, dans les mêmes termes que celui d'un créneau.
ItemStatus heatStatus(Heat heat) => switch (heat.status) {
  RunStatus.marshalling || RunStatus.inProgress => ItemStatus.live,
  RunStatus.finished => ItemStatus.finished,
  RunStatus.waiting =>
    heat.seriesId == null ? ItemStatus.seriesPending : ItemStatus.upcoming,
};

/// Les colonnes de la frise : des étapes consécutives de même niveau (les
/// finales par catégorie) partagent la leur.
List<List<Stage>> progressionColumns(Progression progression) {
  final stages = [...progression.stages]
    ..sort((a, b) => a.order.compareTo(b.order));
  final columns = <List<Stage>>[];
  for (final stage in stages) {
    if (columns.isNotEmpty && columns.last.first.level == stage.level) {
      columns.last.add(stage);
    } else {
      columns.add([stage]);
    }
  }
  return columns;
}

/// Les créneaux d'une partie, dans l'ordre du programme : les réunions sont
/// déjà triées par jour puis heure.
List<MeetingItem> itemsOfStage(List<Meeting> meetings, int stageId) => [
  for (final meeting in meetings)
    for (final item in meeting.items)
      if (item.roundId == stageId) item,
];

enum QualificationRuleKind { byStage, byHeat }

({QualificationRuleKind kind, int? places})? qualificationRule(Stage stage) =>
    switch (stage.qualification) {
      QualificationMethod.byStage => (
        kind: QualificationRuleKind.byStage,
        places: stage.qualifyingPlaces,
      ),
      QualificationMethod.byHeat => (
        kind: QualificationRuleKind.byHeat,
        places: stage.qualifyingPlaces,
      ),
      QualificationMethod.none => null,
    };

/// Le temps prévu d'un créneau, tel que FFSSCompetition publie son début et
/// sa fin. Inconnu sans l'une des deux heures, ou si la fin précède le début :
/// une durée négative n'aurait aucun sens à l'écran.
Duration? itemDuration(MeetingItem item) {
  final start = item.startTime;
  final end = item.endTime;
  if (start == null || end == null || end.isBefore(start)) return null;
  return end.difference(start);
}

/// Une réunion est terminée quand toutes ses épreuves le sont, ou quand son
/// heure de fin est passée : sur la recette, des courses passées restent « En
/// attente », et la réunion ne se replierait jamais.
bool meetingFinished(Meeting meeting, DateTime now) {
  final end = meeting.endTime;
  if (end != null && end.isBefore(now)) return true;
  final events = meeting.items.where((i) => i.heats.isNotEmpty);
  return events.isNotEmpty &&
      events.every((i) => itemStatus(i) == ItemStatus.finished);
}

/// Ce qu'une réunion repliée résume : tous ses créneaux, dont ses épreuves.
({int items, int events}) meetingSummary(Meeting meeting) => (
  items: meeting.items.length,
  events: meeting.items.where((i) => i.heats.isNotEmpty).length,
);
