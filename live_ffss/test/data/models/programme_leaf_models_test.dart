import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';

void main() {
  group('ProgrammeSite', () {
    test('round-trips through JSON with its enum', () {
      const site = ProgrammeSite(id: 3, name: 'Côtier 1', type: SiteType.cotier);
      final json = site.toJson();
      expect(ProgrammeSite.fromJson(json), site);
    });

    test('decodes an unrecognized type string to SiteType.unknown', () {
      final site = ProgrammeSite.fromJson(
        <String, dynamic>{'id': 1, 'name': 'x', 'type': 'kayak'},
      );
      expect(site.type, SiteType.unknown);
    });
  });
}
