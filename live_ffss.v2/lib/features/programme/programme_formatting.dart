import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/heat.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/programme_events.dart';
import 'package:live_ffss_v2/domain/progression.dart';
import 'package:live_ffss_v2/domain/run_status.dart';
import 'package:live_ffss_v2/features/home/competition_formatting.dart';

extension ItemStatusLabel on ItemStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ItemStatus.live => l10n.liveBadge,
    ItemStatus.finished => l10n.statusFinished,
    ItemStatus.seriesPending => l10n.seriesPending,
    ItemStatus.upcoming => l10n.statusUpcoming,
    ItemStatus.none => '',
  };
}

/// « 10 × 8 » : nombre de séries par places.
String stageFormat(Stage stage) =>
    '${stage.heatCount} × ${stage.placesPerHeat}';

String? qualificationText(Stage stage, AppLocalizations l10n) {
  final rule = qualificationRule(stage);
  if (rule == null) return null;
  return switch (rule.kind) {
    QualificationRuleKind.byStage => l10n.qualificationByStage,
    QualificationRuleKind.byHeat =>
      rule.places == null
          ? l10n.qualificationByHeatUnknown
          : l10n.qualificationByHeat(rule.places!),
  };
}

extension StageLevelLabel on StageLevel {
  String label(AppLocalizations l10n) => switch (this) {
    StageLevel.heats => l10n.stageLevelHeats,
    StageLevel.quarterFinal => l10n.stageLevelQuarterFinal,
    StageLevel.semiFinal => l10n.stageLevelSemiFinal,
    StageLevel.finalStage => l10n.stageLevelFinal,
  };
}

/// « Séries 14 × 8 › 3 finales ». Bâtie sur le niveau et non sur le nom publié,
/// qui porte les catégories (« Série - Cadet, Junior… »). Les étapes suivantes
/// sont dites « finales » quand elles en sont toutes, sinon « étapes ».
String collapsedProgression(Progression progression, AppLocalizations l10n) {
  final columns = progressionColumns(progression);
  if (columns.isEmpty) return '';
  final head = columns.first;
  // Les étapes d'une colonne se courent ensemble : on additionne leurs séries,
  // et les places par série sont celles de la première.
  final heatCount = head.fold(0, (sum, s) => sum + s.heatCount);
  final first =
      '${head.first.level.label(l10n)} $heatCount × ${head.first.placesPerHeat}';
  final following = columns.skip(1).expand((column) => column).toList();
  if (following.isEmpty) return first;
  final allFinals = following.every((s) => s.level == StageLevel.finalStage);
  return l10n.progressionCollapsed(
    first,
    allFinals
        ? l10n.followingFinals(following.length)
        : l10n.followingStages(following.length),
  );
}

/// Le temps d'une place, ou le statut publié quand elle n'a pas de temps
/// valable (« DSQ », « Abandon »). Un forfait sans résultat publié le dit :
/// sans cela, sa ligne ressemblerait à celle d'un nageur pas encore parti.
String? performanceText(LaneAssignment lane, AppLocalizations l10n) {
  final performance = lane.performance;
  final text = performance == null
      ? null
      : performance.isOk
      ? performance.time?.trim()
      : [
          performance.statusLabel?.trim(),
          performance.disqualificationCode,
        ].where((part) => part != null && part.isNotEmpty).join(' ');
  if (text != null && text.isNotEmpty) return text;
  return lane.forfeit == true ? l10n.forfeit : null;
}

/// « Programme · sam. 28 · Réunion 2 - Finales ».
String itemBreadcrumb(Meeting meeting, AppLocalizations l10n, String locale) =>
    [
      l10n.programmeTitle,
      dayTabLabel(meeting.day, locale),
      meeting.name,
    ].where((part) => part.isNotEmpty).join(' · ');

/// « ven. 27 » : le libellé court d'un onglet de jour.
String dayTabLabel(DateTime day, String locale) =>
    DateFormat('EEE d', locale).format(day);

/// « 06:45 », ou rien quand l'heure n'est pas publiée.
String timeLabel(DateTime? time) =>
    time == null ? '' : DateFormat('HH:mm').format(time);

/// « 06:45 – 13:45 », sans le morceau inconnu.
String timeRangeLabel(DateTime? start, DateTime? end) =>
    [timeLabel(start), timeLabel(end)].where((t) => t.isNotEmpty).join(' – ');

String durationLabel(Duration duration, AppLocalizations l10n) {
  final minutes = duration.inMinutes;
  if (minutes < 60) return l10n.durationMinutes(minutes);
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0
      ? l10n.durationHours(hours)
      : l10n.durationHoursMinutes(hours, rest.toString().padLeft(2, '0'));
}

String endTimeLabel(DateTime? end) => end == null ? '' : '→ ${timeLabel(end)}';

String meetingSummaryLabel(
  ({int items, int events}) summary,
  AppLocalizations l10n,
) => [
  l10n.meetingItemCount(summary.items),
  if (summary.events > 0) l10n.meetingEventCount(summary.events),
].join(' · ');

/// Les catégories d'une étape, telles que FFSS les écrit après le niveau
/// (« Finale - Cadet » → « Cadet »). Nul quand le nom n'en porte pas.
String? stageCategories(Stage stage) {
  final index = stage.name.indexOf(' - ');
  if (index < 0) return null;
  final categories = stage.name.substring(index + 3).trim();
  return categories.isEmpty ? null : categories;
}

/// La pastille d'un créneau dans la chronologie : le début de son nom
/// (« Finale B ») et son heure.
String itemChipLabel(MeetingItem item) => [
  item.name.split(' · ').first.trim(),
  timeLabel(item.startTime),
].where((part) => part.isNotEmpty).join(' · ');

/// Le jour et la plage horaire d'une étape qui tient en un seul créneau.
String stageScheduleLabel(MeetingItem item, String locale) {
  final start = item.startTime;
  if (start == null) return '';
  return [
    dayTabLabel(start, locale),
    timeRangeLabel(start, item.endTime),
  ].join(' · ');
}

/// « Séries à venir » seulement quand il n'y a vraiment rien à montrer : une
/// finale sans série peut déjà avoir sa composition publiée.
bool showsSeriesPending(MeetingItem item, Map<int, LaneAssignment?> lanes) =>
    itemStatus(item) == ItemStatus.seriesPending &&
    item.heats.every((heat) => lanesOfHeat(heat, lanes).isEmpty);

enum EventBadgeKind { live, done, next }

/// Le badge d'une carte d'épreuve : « EN DIRECT » ; « Séries ✓ » quand le tour
/// de la réunion est couru et que d'autres suivent ; « Terminé » quand il n'y
/// a plus rien à courir ; sinon l'heure de son prochain créneau.
({EventBadgeKind kind, String label}) eventBadge(
  ProgrammeEvent event,
  AppLocalizations l10n,
) {
  switch (event.status) {
    case ItemStatus.live:
      return (kind: EventBadgeKind.live, label: l10n.liveBadge);
    case ItemStatus.finished:
      final step = _stepOf(event);
      if (step == null || event.steps.length <= 1 || allStepsFinished(event)) {
        return (kind: EventBadgeKind.done, label: l10n.statusFinished);
      }
      return (kind: EventBadgeKind.done, label: '${stepLabel(step, l10n)} ✓');
    case ItemStatus.upcoming || ItemStatus.seriesPending || ItemStatus.none:
      final time = timeLabel(eventTarget(event.items)?.startTime);
      return (
        kind: EventBadgeKind.next,
        label: time.isEmpty ? event.status.label(l10n) : time,
      );
  }
}

/// Le tour que la carte montre dans sa réunion : celui de son premier
/// créneau.
EventStep? _stepOf(ProgrammeEvent event) {
  if (event.items.isEmpty) return null;
  final id = event.items.first.id;
  for (final step in event.steps) {
    if (step.items.any((item) => item.id == id)) return step;
  }
  return null;
}

/// « Séries », « Finale », ou « Finales » pour un tour qui en réunit
/// plusieurs (A et B, ou une par catégorie).
String stepLabel(EventStep step, AppLocalizations l10n) =>
    step.level == StageLevel.finalStage && step.stageCount > 1
    ? l10n.stageLevelFinals
    : step.level.label(l10n);

/// Sous le nom d'un tour : la série en cours (« Série 3/4 »), l'heure cochée
/// d'un tour couru, sinon son heure, précédée du jour quand ce n'est pas
/// [day] (« dim. 29 15:00 »).
String stepDetail(
  EventStep step,
  DateTime day,
  String locale,
  AppLocalizations l10n,
) {
  if (step.status == ItemStatus.live) {
    if (_heatProgress([for (final item in step.items) ...item.heats], l10n)
        case final progress?) {
      return progress;
    }
  }
  final start = step.start;
  if (start == null) return l10n.statusUpcoming;
  final sameDay =
      start.year == day.year &&
      start.month == day.month &&
      start.day == day.day;
  final when = sameDay
      ? timeLabel(start)
      : '${dayTabLabel(start, locale)} ${timeLabel(start)}';
  return step.status == ItemStatus.finished ? '$when ✓' : when;
}

/// « Série 3/4 » : la première série en cours parmi [heats].
String? _heatProgress(List<Heat> heats, AppLocalizations l10n) {
  for (var i = 0; i < heats.length; i++) {
    final status = heats[i].status;
    if (status == RunStatus.inProgress || status == RunStatus.marshalling) {
      return l10n.heatOfTotal(i + 1, heats.length);
    }
  }
  return null;
}

/// « Dames · Cadet, Junior », sans les morceaux inconnus.
String eventSubtitle(ProgrammeEvent event, AppLocalizations l10n) => [
  if (event.gender case final gender?) genderLabel(gender, l10n),
  if (event.categories.isNotEmpty) event.categories.join(', '),
].join(' · ');

/// Les pastilles disent l'avancement d'une épreuve sans finale, ou du tour en
/// cours ; ailleurs, le parcours suffit.
bool showsHeatDots(ProgrammeEvent event) =>
    event.heats.isNotEmpty &&
    (event.steps.length <= 1 || event.status == ItemStatus.live);

/// À côté des pastilles : la série en cours, sinon leur nombre.
String heatDotsLabel(ProgrammeEvent event, AppLocalizations l10n) =>
    _heatProgress(event.heats, l10n) ??
    l10n.programmeHeatCount(event.heats.length);

/// Ce que dit une réunion repliée : « Terminée · 4 épreuves » quand elle est
/// courue, sinon ses créneaux et ses épreuves.
String meetingCollapsedLabel(
  Meeting meeting,
  Programme programme,
  AppLocalizations l10n, {
  required bool finished,
}) {
  if (!finished) return meetingSummaryLabel(meetingSummary(meeting), l10n);
  final events = meetingEntries(
    meeting,
    programme,
  ).whereType<EventEntry>().length;
  return '${l10n.meetingFinished} · ${l10n.meetingEventCount(events)}';
}
