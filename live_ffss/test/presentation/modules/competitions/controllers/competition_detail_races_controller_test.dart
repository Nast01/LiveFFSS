import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RaceRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailRacesController controller;

  Race race(int id, {String specLabel = 'Eau-plate'}) => Race(
        id: id,
        name: 'Race$id',
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: Gender.male,
        athletesPerTeam: 1,
        specialityId: 1,
        specialityLabel: specLabel,
        disciplineId: 1,
        isEligibleToNationalRecord: false,
        categories: const [],
      );

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailRacesController(repo);
  });

  group('CompetitionDetailRacesController.loadRaces', () {
    test('loads, sorts by specialityId then name', () async {
      when(() => repo.getRaces(any())).thenAnswer((_) async => [
            race(2, specLabel: 'Côtier'),
            race(1),
          ]);

      await controller.loadRaces(99);

      expect(controller.allRaces.length, 2);
      // specialityId is 1 for both fixtures, so name tiebreak kicks in.
      expect(controller.allRaces.first.id, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError', () async {
      when(() => repo.getRaces(any())).thenThrow(Exception('boom'));

      await controller.loadRaces(99);

      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('CompetitionDetailRacesController filtering', () {
    test('setFilterIndex(1) keeps only beach races', () async {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
        race(3, specLabel: 'Côtier'),
      ];
      controller.setFilterIndex(1);
      expect(controller.filteredRaces.length, 2);
      expect(controller.filteredRaces.every((r) => r.specialityLabel == 'Côtier'),
          isTrue);
    });

    test('setFilterIndex(2) keeps only eau-plate races', () {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
      ];
      controller.setFilterIndex(2);
      expect(controller.filteredRaces.length, 1);
      expect(controller.filteredRaces.first.specialityLabel, 'Eau-plate');
    });

    test('setFilterIndex(0) shows all', () {
      controller.allRaces.value = [
        race(1, specLabel: 'Côtier'),
        race(2, specLabel: 'Eau-plate'),
      ];
      controller.setFilterIndex(0);
      expect(controller.filteredRaces.length, 2);
    });
  });
}
