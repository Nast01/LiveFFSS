import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/discipline.dart';
import 'package:live_ffss_v2/features/home/home_view.dart';

import '../../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17);
  final flat = competition(1, start: DateTime(2026, 10, 20));
  final coastal = competition(
    2,
    start: DateTime(2026, 10, 21),
    disciplines: {Discipline.coastal},
  );
  final mixed = competition(
    3,
    start: DateTime(2026, 10, 22),
    disciplines: {Discipline.flatWater, Discipline.coastal},
  );

  group('matchesFilter', () {
    test('une compétition mixte apparaît sous les deux filtres', () {
      expect(matchesFilter(mixed, HomeFilter.flatWater, {}), isTrue);
      expect(matchesFilter(mixed, HomeFilter.coastal, {}), isTrue);
    });

    test('eau plate et côtier se séparent', () {
      expect(matchesFilter(flat, HomeFilter.coastal, {}), isFalse);
      expect(matchesFilter(coastal, HomeFilter.flatWater, {}), isFalse);
    });

    test('favoris : seulement les favorites', () {
      expect(matchesFilter(flat, HomeFilter.favorites, {1}), isTrue);
      expect(matchesFilter(coastal, HomeFilter.favorites, {1}), isFalse);
    });
  });

  group('orderLive', () {
    final a = competition(10, name: 'A', start: DateTime(2026, 10, 16));
    final b = competition(11, name: 'B', start: DateTime(2026, 10, 15));
    final c = competition(12, name: 'C', start: DateTime(2026, 10, 17));

    test('favoris, puis compétition active, puis date de début', () {
      final ordered = orderLive([a, b, c], favorites: {12}, activeId: 10);

      expect([for (final x in ordered) x.id], [12, 10, 11]);
    });

    test('sans favori ni active : par date de début', () {
      final ordered = orderLive([a, b, c], favorites: {});

      expect([for (final x in ordered) x.id], [11, 10, 12]);
    });
  });

  group('buildHomeView', () {
    test('à venir limité à 5, avec le compte total', () {
      final list = [
        for (var i = 1; i <= 7; i++)
          competition(i, start: DateTime(2026, 10, 17 + i)),
      ];

      final view = buildHomeView(
        competitions: list,
        today: today,
        filter: HomeFilter.all,
        favorites: {},
      );

      expect(view.upcoming.length, upcomingPreviewCount);
      expect(view.upcomingCount, 7);
    });

    test('le filtre s\'applique aux trois groupes', () {
      final live = competition(
        20,
        start: DateTime(2026, 10, 17),
        disciplines: {Discipline.coastal},
      );
      final recent = competition(
        21,
        start: DateTime(2026, 10, 10),
        disciplines: {Discipline.coastal},
      );

      final view = buildHomeView(
        competitions: [flat, live, recent],
        today: today,
        filter: HomeFilter.flatWater,
        favorites: {},
      );

      expect(view.live, isEmpty);
      expect(view.recent, isEmpty);
      expect([for (final x in view.upcoming) x.id], [1]);
    });
  });
}
