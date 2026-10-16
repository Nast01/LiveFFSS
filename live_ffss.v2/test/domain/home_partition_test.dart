import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/domain/competition_summary.dart';
import 'package:live_ffss_v2/domain/home_partition.dart';

import '../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17, 9, 42);

  List<int> ids(List<CompetitionSummary> list) => [for (final c in list) c.id];

  group('partitionHome — en direct', () {
    test('une compétition commencée hier et finie demain est en direct', () {
      final p = partitionHome([
        competition(
          1,
          start: DateTime(2026, 10, 16),
          end: DateTime(2026, 10, 18),
        ),
      ], today);

      expect(ids(p.live), [1]);
      expect(p.upcoming, isEmpty);
      expect(p.recent, isEmpty);
    });

    test(
      'une compétition qui commence ou finit aujourd\'hui est en direct',
      () {
        final p = partitionHome([
          competition(
            1,
            start: DateTime(2026, 10, 17),
            end: DateTime(2026, 10, 19),
          ),
          competition(
            2,
            start: DateTime(2026, 10, 15),
            end: DateTime(2026, 10, 17),
          ),
        ], today);

        expect(ids(p.live), [2, 1]);
      },
    );
  });

  group('partitionHome — à venir', () {
    test('triées par date de début puis par nom', () {
      final p = partitionHome([
        competition(1, name: 'B', start: DateTime(2026, 11, 1)),
        competition(2, name: 'Z', start: DateTime(2026, 10, 18)),
        competition(3, name: 'A', start: DateTime(2026, 11, 1)),
      ], today);

      expect(ids(p.upcoming), [2, 3, 1]);
    });
  });

  group('partitionHome — terminées récemment', () {
    test('finie il y a exactement 14 jours : encore récente', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 3)),
      ], today);

      expect(ids(p.recent), [1]);
    });

    test('finie il y a 15 jours : écartée', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 2)),
      ], today);

      expect(p.live, isEmpty);
      expect(p.upcoming, isEmpty);
      expect(p.recent, isEmpty);
    });

    test('de la plus récente à la plus ancienne', () {
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 5)),
        competition(
          2,
          start: DateTime(2026, 10, 12),
          end: DateTime(2026, 10, 16),
        ),
      ], today);

      expect(ids(p.recent), [2, 1]);
    });

    test('le passage à l\'heure d\'hiver ne décale pas la fenêtre', () {
      // Le 25 octobre 2026, l'heure recule : soustraire 14 × 24 h à minuit
      // tomberait la veille à 23 h et ferait entrer une compétition de trop.
      final afterDst = DateTime(2026, 11, 8, 10);
      final p = partitionHome([
        competition(1, start: DateTime(2026, 10, 25)),
        competition(2, start: DateTime(2026, 10, 24)),
      ], afterDst);

      expect(ids(p.recent), [1]);
    });
  });

  test('dayOf ramène un instant à minuit du même jour', () {
    expect(dayOf(DateTime(2026, 3, 27, 23, 59)), DateTime(2026, 3, 27));
  });
}
