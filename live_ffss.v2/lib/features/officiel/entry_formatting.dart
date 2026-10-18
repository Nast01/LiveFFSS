import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';

String manualRuleLabel(ManualTimeRule rule, AppLocalizations l10n) =>
    switch (rule) {
      ManualTimeRule.single => l10n.entryRuleSingle,
      ManualTimeRule.average => l10n.entryRuleAverage,
      ManualTimeRule.median => l10n.entryRuleMedian,
    };

/// Pourquoi l'opération a été refusée ; le message du site quand il en a
/// donné un.
String rejectionReason(OutboxOperation op, AppLocalizations l10n) {
  final reason = op.reason?.trim();
  return switch (op.rejection) {
    OutboxRejection.validatedByJudge => l10n.entryRejectedValidated,
    OutboxRejection.unreadableResult => l10n.entryRejectedUnreadable,
    OutboxRejection.emptyPlace => l10n.entryRejectedEmptyPlace,
    OutboxRejection.server || null =>
      reason == null || reason.isEmpty ? l10n.entryRejectedServer : reason,
  };
}

/// Ce que la liste des couloirs dit d'un couloir : son statut s'il n'est pas
/// OK, sinon son temps manuel. Le code ne se montre que sur une DQ : FFSS
/// ne sait pas l'effacer, une DQ annulée le garde.
String? entryLaneSummary(EntryLane lane, AppLocalizations l10n) {
  final result = lane.result;
  switch (result.status) {
    case statusDisqualified:
      return l10n.entryDisqualified(result.complement.trim()).trim();
    case statusForfeit:
      return l10n.forfeit;
  }
  final time = manualTime(result.chronos);
  return time == null ? null : hundredthsLabel(time.hundredths);
}

/// Un relais s'annonce sous le nom de son club, comme dans les séries.
String laneTitle(LaneAssignment lane) =>
    lane.isRelay ? lane.club : lane.athletes.join(', ');

String laneSubtitle(LaneAssignment lane) => lane.isRelay
    ? lane.athletes.join(', ')
    : [
        lane.club,
        lane.category,
      ].where((p) => p != null && p.isNotEmpty).join(' · ');

String laneActionLabel(EntryLaneAction action, AppLocalizations l10n) =>
    switch (action) {
      EntryLaneAction.disqualify ||
      EntryLaneAction.editDisqualification => l10n.entryDisqualify,
      EntryLaneAction.cancelDisqualification =>
        l10n.entryCancelDisqualification,
      EntryLaneAction.forfeit => l10n.forfeit,
      EntryLaneAction.cancelForfeit => l10n.entryCancelForfeit,
    };
