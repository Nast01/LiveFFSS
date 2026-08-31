import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/race.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_races_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RaceRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailRacesController controller;

  Race race(
    int id, {
    String specLabel = 'Eau-plate',
    int specId = 1,
    int disciplineId = 1,
    String name = '',
    Gender gender = Gender.male,
    List<Category> categories = const [],
  }) =>
      Race(
        id: id,
        name: name.isEmpty ? 'Race$id' : name,
        nameEnglish: 'Race$id (en)',
        distance: 100,
        gender: gender,
        athletesPerTeam: 1,
        specialityId: specId,
        specialityLabel: specLabel,
        disciplineId: disciplineId,
        isEligibleToNationalRecord: false,
        categories: categories,
      );

  const junior = Category(id: 7, name: 'Junior');
  const senior = Category(id: 8, name: 'Senior');

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
    /// Four épreuves spanning two spécialités, two disciplines, two genders and
    /// two categories — enough for every combination the bar offers.
    Future<void> loadFour() async {
      when(() => repo.getRaces(any())).thenAnswer((_) async => [
            race(1,
                specLabel: 'Côtier',
                specId: 2,
                disciplineId: 8,
                name: 'Surfski',
                gender: Gender.female,
                categories: const [junior]),
            race(2,
                specLabel: 'Côtier',
                specId: 2,
                disciplineId: 8,
                name: 'Surfski',
                categories: const [senior]),
            race(3,
                disciplineId: 13,
                name: 'Nage',
                categories: const [junior, senior]),
            race(4, disciplineId: 13, name: 'Nage', gender: Gender.mixed),
          ]);
      await controller.loadRaces(99);
    }

    List<int> visibleIds() => controller.filteredRaces.map((r) => r.id).toList();

    test('sans filtre, toutes les épreuves sont visibles', () async {
      await loadFour();

      expect(controller.filteredRaces, hasLength(4));
      expect(controller.hasActiveFilters, isFalse);
    });

    test('la spécialité sépare le côtier de l eau plate', () async {
      await loadFour();

      controller.toggle(RaceFilter.speciality, 2);

      expect(visibleIds(), [1, 2]);
      expect(controller.hasActiveFilters, isTrue);
    });

    test('deux valeurs d un même critère sont un OU', () async {
      await loadFour();

      controller.toggle(RaceFilter.gender, Gender.female);
      controller.toggle(RaceFilter.gender, Gender.mixed);

      expect(visibleIds(), [4, 1]); // triees par specialite puis nom
    });

    test('deux critères sont un ET', () async {
      await loadFour();

      controller.toggle(RaceFilter.discipline, 13);
      controller.toggle(RaceFilter.gender, Gender.male);

      expect(visibleIds(), [3]);
    });

    test('une épreuve compte dès qu une seule de ses catégories est cochée',
        () async {
      // Une épreuve court plusieurs catégories : la masquer parce que l'une
      // d'elles n'est pas retenue cacherait une épreuve qui a bien lieu.
      await loadFour();

      controller.toggle(RaceFilter.category, 8); // Senior

      expect(visibleIds(), [3, 2]); // idem
    });

    test('les valeurs proposées sont celles des épreuves chargées', () async {
      await loadFour();

      expect(
        controller.optionsFor(RaceFilter.speciality).map((o) => o.label),
        ['Côtier', 'Eau-plate'],
      );
      expect(
        controller.optionsFor(RaceFilter.discipline).map((o) => o.label),
        ['Nage', 'Surfski'],
      );
      expect(
        controller.optionsFor(RaceFilter.category).map((o) => o.label),
        ['Junior', 'Senior'],
      );
      expect(
        controller.optionsFor(RaceFilter.gender).map((o) => o.value),
        [Gender.male, Gender.female, Gender.mixed],
      );
    });

    test('clear vide un critère, clearFilters les vide tous', () async {
      await loadFour();
      controller.toggle(RaceFilter.gender, Gender.female);
      controller.toggle(RaceFilter.speciality, 2);

      controller.clear(RaceFilter.gender);
      expect(controller.selectedCount(RaceFilter.gender), 0);
      expect(controller.selectedCount(RaceFilter.speciality), 1);

      controller.clearFilters();
      expect(controller.hasActiveFilters, isFalse);
      expect(controller.filteredRaces, hasLength(4));
    });

    test('une valeur disparue du serveur est décochée au rechargement',
        () async {
      // Sinon l'opérateur reste devant une liste vide sans rien à décocher.
      await loadFour();
      controller.toggle(RaceFilter.speciality, 2);
      expect(controller.filteredRaces, hasLength(2));

      when(() => repo.getRaces(any()))
          .thenAnswer((_) async => [race(3, disciplineId: 13, name: 'Nage')]);
      await controller.loadRaces(99);

      expect(controller.selectedCount(RaceFilter.speciality), 0);
      expect(controller.filteredRaces, hasLength(1));
    });
  });
}
