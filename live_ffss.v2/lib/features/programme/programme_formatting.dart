import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/meeting.dart';
import 'package:live_ffss_v2/domain/programme.dart';
import 'package:live_ffss_v2/domain/progression.dart';

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
  return lane.forfeit ? l10n.forfeit : null;
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
