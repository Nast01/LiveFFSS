import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/features/shell/current_competition.dart';

import '../../support/competitions.dart';

void main() {
  final today = DateTime(2026, 10, 17);
  final liveA = competition(
    1,
    name: 'A',
    start: DateTime(2026, 10, 16),
    end: DateTime(2026, 10, 18),
  );
  final liveB = competition(
    2,
    name: 'B',
    start: DateTime(2026, 10, 15),
    end: DateTime(2026, 10, 18),
  );
  final upcoming = competition(3, start: DateTime(2026, 11, 1));

  test('la compétition choisie, si elle est dans la liste', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB, upcoming],
        selection: (id: 3, summary: null),
        favorites: {},
        today: today,
      ),
      upcoming,
    );
  });

  test('choisie hors de la liste : le résumé gardé en mémoire', () {
    final old = competition(99, start: DateTime(2025, 5, 1));

    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: old),
        favorites: {},
        today: today,
      ),
      old,
    );
  });

  test('rien de choisi : la première du carrousel, favoris d\'abord', () {
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {1},
        today: today,
      ),
      liveA,
    );
    expect(
      currentCompetition(
        competitions: [liveA, liveB],
        selection: null,
        favorites: {},
        today: today,
      ),
      liveB,
    );
  });

  test('choisie mais introuvable, sans résumé : le défaut', () {
    expect(
      currentCompetition(
        competitions: [liveA],
        selection: (id: 99, summary: null),
        favorites: {},
        today: today,
      ),
      liveA,
    );
  });

  test('rien en direct et rien de choisi : aucune', () {
    expect(
      currentCompetition(
        competitions: [upcoming],
        selection: null,
        favorites: {},
        today: today,
      ),
      isNull,
    );
  });
}
