import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/router/app_router.dart';

void main() {
  group('programmeItemKey', () {
    test('un lien bien formé donne la compétition et le créneau', () {
      expect(programmeItemKey({'competitionId': '1453', 'itemId': '177'}), (
        competitionId: 1453,
        itemId: 177,
      ));
    });

    test('un lien mal formé ne donne rien', () {
      expect(
        programmeItemKey({'competitionId': 'abc', 'itemId': '177'}),
        isNull,
      );
      expect(programmeItemKey({'competitionId': '1453', 'itemId': ''}), isNull);
      expect(programmeItemKey({}), isNull);
    });
  });
}
