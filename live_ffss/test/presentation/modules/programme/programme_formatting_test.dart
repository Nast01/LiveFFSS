import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/presentation/modules/programme/programme_formatting.dart';

void main() {
  test('endHour is beginHour plus the duration', () {
    final p = RacePlacement(
      siteId: 1,
      beginHour: DateTime(2026, 6, 13, 9),
      durationMinutes: 10,
    );
    expect(p.endHour, DateTime(2026, 6, 13, 9, 10));
  });

  test('RoundType.labelKey maps each arm to a translation key', () {
    expect(RoundType.serie.labelKey, 'round_serie');
    expect(RoundType.quart.labelKey, 'round_quart');
    expect(RoundType.demi.labelKey, 'round_demi');
    expect(RoundType.finale.labelKey, 'round_finale');
    expect(RoundType.unknown.labelKey, 'round_unknown');
  });

  test('EventStructure.chain lists the level types in order', () {
    const s = EventStructure(
      raceId: 1,
      categoryId: 1,
      raceLabel: 'x',
      categoryLabel: 'y',
      levels: [
        RoundLevel(type: RoundType.serie),
        RoundLevel(type: RoundType.finale),
      ],
    );
    expect(s.chain, [RoundType.serie, RoundType.finale]);
    expect(s.isDefined, isTrue);
  });

  test('an EventStructure with no levels is not defined', () {
    const s = EventStructure(
      raceId: 1,
      categoryId: 1,
      raceLabel: 'x',
      categoryLabel: 'y',
    );
    expect(s.isDefined, isFalse);
    expect(s.chain, isEmpty);
  });
}
