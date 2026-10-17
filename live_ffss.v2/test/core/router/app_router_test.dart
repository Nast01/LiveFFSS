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

  group('Routes.liveItem', () {
    test('le détail d\'un créneau reste dans la branche du Live', () {
      expect(Routes.liveItem(1453, 177), '/live/competition/1453/creneau/177');
      expect(Routes.liveItem(1453, 177), startsWith('${Routes.live}/'));
    });
  });

  group('itemRedirect', () {
    test('un lien bien formé reste où il est', () {
      expect(
        itemRedirect({'competitionId': '1453', 'itemId': '177'}, Routes.live),
        isNull,
      );
    });

    test('un lien mal formé retombe sur l\'onglet qui le porte', () {
      expect(
        itemRedirect({'competitionId': 'abc', 'itemId': '177'}, Routes.live),
        Routes.live,
      );
      expect(itemRedirect({}, Routes.programme), Routes.programme);
    });
  });
}
