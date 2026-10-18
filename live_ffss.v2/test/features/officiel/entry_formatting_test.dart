import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/l10n/gen/app_localizations.dart';
import 'package:live_ffss_v2/domain/lane_assignment.dart';
import 'package:live_ffss_v2/domain/manual_timing.dart';
import 'package:live_ffss_v2/domain/outbox.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:live_ffss_v2/features/officiel/entry_formatting.dart';
import 'package:live_ffss_v2/features/officiel/entry_view.dart';

EntryLane _lane({
  int status = statusOk,
  String complement = '',
  List<int?> chronos = const [null, null, null],
}) => EntryLane(
  lane: const LaneAssignment(id: 1, lane: 1, athletes: ['A']),
  result: RaceResult(
    seriesId: 5,
    entryId: 7,
    status: status,
    complement: complement,
    chronos: chronos,
  ),
);

OutboxOperation _rejected(OutboxRejection rejection, {String? reason}) =>
    OutboxOperation(
      id: 'a',
      account: 'DUPONT Jean',
      competitionId: 1416,
      placeId: 1,
      seriesId: 5,
      entryId: 7,
      change: const ResultChange(),
      state: OutboxState.rejected,
      rejection: rejection,
      reason: reason,
    );

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  test('la règle du temps manuel', () {
    expect(manualRuleLabel(ManualTimeRule.average, l10n), 'moyenne de 2');
    expect(manualRuleLabel(ManualTimeRule.median, l10n), 'médiane de 3');
  });

  test('la raison d\'un refus, le message du site s\'il en a un', () {
    expect(
      rejectionReason(_rejected(OutboxRejection.validatedByJudge), l10n),
      'validé par le juge des résultats',
    );
    expect(
      rejectionReason(
        _rejected(OutboxRejection.server, reason: 'Série close'),
        l10n,
      ),
      'Série close',
    );
    expect(
      rejectionReason(_rejected(OutboxRejection.server, reason: ' '), l10n),
      'refus du site',
    );
  });

  test('la liste dit le statut, sinon le temps manuel', () {
    expect(
      entryLaneSummary(
        _lane(status: statusDisqualified, complement: '12'),
        l10n,
      ),
      'DQ 12',
    );
    expect(entryLaneSummary(_lane(status: statusDisqualified), l10n), 'DQ');
    expect(entryLaneSummary(_lane(status: statusForfeit), l10n), 'Forfait');
    // Une DQ annulée garde son code sur le site : il ne se montre plus.
    expect(
      entryLaneSummary(
        _lane(complement: '12', chronos: [4300, 4400, null]),
        l10n,
      ),
      '43"50',
    );
    expect(entryLaneSummary(_lane(), l10n), isNull);
  });
}
