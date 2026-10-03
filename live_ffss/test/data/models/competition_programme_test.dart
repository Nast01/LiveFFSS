import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

void main() {
  const programme = CompetitionProgramme(
    competitionId: 42,
    nextLocalId: 5,
    structures: [
      EventStructure(
        raceId: 100,
        categoryId: 7,
        raceLabel: '100m Nage côtière',
        categoryLabel: 'Cadets',
        spotsPerRace: 8,
        levels: [
          RoundLevel(
            type: RoundType.serie,
            qualifiersPerRace: 2,
            races: [
              ProgrammeRace(id: 1, number: 1),
              ProgrammeRace(id: 2, number: 2),
            ],
          ),
          RoundLevel(
            type: RoundType.finale,
            races: [
              ProgrammeRace(id: 3, number: 1, sourceRaceIds: [1, 2]),
            ],
          ),
        ],
      ),
    ],
  );

  test('round-trips the full tree through JSON', () {
    // explicit_to_json is false (no build.yaml): toJson() leaves nested
    // freezed objects as-is; jsonEncode serialises them recursively. This
    // mirrors how ProgrammeService persists (jsonEncode(toJson()) →
    // jsonDecode → fromJson), which is the real round-trip path.
    final restored = CompetitionProgramme.fromJson(
      jsonDecode(jsonEncode(programme.toJson())) as Map<String, dynamic>,
    );
    expect(restored, programme);
  });

  test('defaults: empty programme has nextLocalId 1 and no structures', () {
    const p = CompetitionProgramme(competitionId: 1);
    expect(p.nextLocalId, 1);
    expect(p.structures, isEmpty);
    expect(p.sites, isEmpty);
  });

  test('an unscheduled race carries its source race ids', () {
    const race = ProgrammeRace(id: 1, number: 1);
    expect(race.sourceRaceIds, isEmpty);
  });

  test('RoundLevel decodes an unrecognized type string to RoundType.unknown',
      () {
    final level = RoundLevel.fromJson(
      <String, dynamic>{'type': 'repechage', 'races': <dynamic>[]},
    );
    expect(level.type, RoundType.unknown);
  });

  // La cle est la paire (epreuve, categorie) : un meme 50 m porte deux
  // structures quand deux categories le courent. Quatre controleurs
  // deroulaient cette boucle avant que le modele ne la porte.
  group('structureFor', () {
    const junior = EventStructure(
        raceId: 10, categoryId: 7, raceLabel: '50m', categoryLabel: 'Junior');
    const senior = EventStructure(
        raceId: 10, categoryId: 8, raceLabel: '50m', categoryLabel: 'Senior');
    const programme =
        CompetitionProgramme(competitionId: 1, structures: [junior, senior]);

    test('distingue deux categories d une meme epreuve', () {
      expect(programme.structureFor(10, 7), junior);
      expect(programme.structureFor(10, 8), senior);
    });

    test('rend nul quand la paire n existe pas', () {
      expect(programme.structureFor(10, 9), isNull);
      expect(programme.structureFor(11, 7), isNull);
    });

    test('un programme sans structure rend nul', () {
      expect(const CompetitionProgramme(competitionId: 1).structureFor(10, 7),
          isNull);
    });
  });

  group('withStructure', () {
    const junior = EventStructure(
        raceId: 10, categoryId: 7, raceLabel: '50m', categoryLabel: 'Junior');
    const senior = EventStructure(
        raceId: 10, categoryId: 8, raceLabel: '50m', categoryLabel: 'Senior');

    test('remplace la structure de meme cle, en place', () {
      const programme =
          CompetitionProgramme(competitionId: 1, structures: [junior, senior]);
      const revised = EventStructure(
          raceId: 10,
          categoryId: 7,
          raceLabel: '50m',
          categoryLabel: 'Junior',
          spotsPerRace: 16);

      final updated = programme.withStructure(revised);

      expect(updated.structures, [revised, senior]);
    });

    test('ajoute a la fin quand la cle est nouvelle', () {
      const programme =
          CompetitionProgramme(competitionId: 1, structures: [junior]);

      expect(programme.withStructure(senior).structures, [junior, senior]);
    });

    // L'apercu les affiche dans l'ordre du blob : une edition ne doit pas
    // reordonner la liste sous l'operateur.
    test('l ordre des autres ne bouge pas', () {
      const third = EventStructure(
          raceId: 11,
          categoryId: 7,
          raceLabel: '100m',
          categoryLabel: 'Junior');
      const programme = CompetitionProgramme(
          competitionId: 1, structures: [junior, senior, third]);
      const revised = EventStructure(
          raceId: 10,
          categoryId: 8,
          raceLabel: '50m',
          categoryLabel: 'Senior',
          spotsPerRace: 16);

      expect(programme.withStructure(revised).structures,
          [junior, revised, third]);
    });
  });
}
