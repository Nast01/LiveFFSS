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

/// « Séries 10 × 8 › 3 finales ». Le nom des suivantes dit « finales » quand
/// elles en sont toutes, sinon « étapes » : on ne présume pas du niveau.
String collapsedProgression(Progression progression, AppLocalizations l10n) {
  final columns = progressionColumns(progression);
  if (columns.isEmpty) return '';
  final head = columns.first.first;
  final first = '${head.name} ${stageFormat(head)}';
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
