import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';

void main() {
  group('ProgrammeSite', () {
    test('round-trips through JSON with its enum', () {
      const site = ProgrammeSite(id: 3, name: 'Côtier 1', type: SiteType.cotier);
      final json = site.toJson();
      expect(ProgrammeSite.fromJson(json), site);
    });
  });

  group('RacePlacement', () {
    test('defaults durationMinutes to 10', () {
      final p = RacePlacement(siteId: 1, beginHour: DateTime(2026, 6, 13, 9));
      expect(p.durationMinutes, 10);
    });

    test('round-trips through JSON', () {
      final p = RacePlacement(
        siteId: 1,
        beginHour: DateTime(2026, 6, 13, 9, 10),
        durationMinutes: 15,
      );
      expect(RacePlacement.fromJson(p.toJson()), p);
    });
  });
}
