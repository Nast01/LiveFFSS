import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/schedule_block.dart';
import 'package:live_ffss/app/domain/models/site_day_start.dart';

void main() {
  test('ScheduleBlock defaults: duration 10, no race, empty label', () {
    final b = ScheduleBlock(id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0);
    expect(b.durationMinutes, 10);
    expect(b.raceId, isNull);
    expect(b.manualLabel, '');
  });

  test('a race block and a manual block round-trip through JSON', () {
    final race = ScheduleBlock(
        id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0, raceId: 99);
    final manual = ScheduleBlock(
        id: 2,
        siteId: 2,
        day: DateTime(2026, 6, 13),
        order: 1,
        durationMinutes: 60,
        manualLabel: 'Pause');
    for (final b in [race, manual]) {
      expect(ScheduleBlock.fromJson(b.toJson()), b);
    }
  });

  test('SiteDayStart round-trips', () {
    final s = SiteDayStart(siteId: 2, day: DateTime(2026, 6, 13), startMinutes: 510);
    expect(SiteDayStart.fromJson(s.toJson()), s);
  });

  test('CompetitionProgramme carries blocks and dayStarts through JSON', () {
    final p = CompetitionProgramme(
      competitionId: 42,
      blocks: [
        ScheduleBlock(id: 1, siteId: 2, day: DateTime(2026, 6, 13), order: 0, raceId: 99),
      ],
      dayStarts: [
        SiteDayStart(siteId: 2, day: DateTime(2026, 6, 13), startMinutes: 540),
      ],
    );
    final restored = CompetitionProgramme.fromJson(
      jsonDecode(jsonEncode(p.toJson())) as Map<String, dynamic>,
    );
    expect(restored, p);
  });

  test('an empty programme has no blocks and no dayStarts', () {
    const p = CompetitionProgramme(competitionId: 1);
    expect(p.blocks, isEmpty);
    expect(p.dayStarts, isEmpty);
  });
}
