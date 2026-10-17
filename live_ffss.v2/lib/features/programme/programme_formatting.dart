import 'package:intl/intl.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
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

/// Le rang publié par FFSS ; l'app n'en calcule aucun.
String? rankText(LaneAssignment lane) {
  final rank = lane.performance?.rankLabel;
  if (rank == null || rank.isEmpty) return null;
  final category = lane.category;
  if (category == null || category.isEmpty) return rank;
  return '$rank · $category';
}

/// « ven. 27 » : le libellé court d'un onglet de jour.
String dayTabLabel(DateTime day, String locale) =>
    DateFormat('EEE d', locale).format(day);

/// « 06:45 », ou rien quand l'heure n'est pas publiée.
String timeLabel(DateTime? time) =>
    time == null ? '' : DateFormat('HH:mm').format(time);

/// « 06:45 – 13:45 », sans le morceau inconnu.
String timeRangeLabel(DateTime? start, DateTime? end) =>
    [timeLabel(start), timeLabel(end)].where((t) => t.isNotEmpty).join(' – ');
