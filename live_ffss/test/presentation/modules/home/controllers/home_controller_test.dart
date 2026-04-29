import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_preferences_service.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements CompetitionRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockLanguageService extends Mock implements LanguageService {}

class _MockPrefs extends Mock implements UserPreferencesService {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(CompetitionType.mixte);
    registerFallbackValue(CompetitionVisibility.incoming);
    Get.testMode = true;
  });

  late _MockRepo repo;
  late _MockUserService users;
  late _MockLanguageService lang;
  late _MockPrefs prefs;
  late HomeController controller;

  Competition c(
    int id, {
    DateTime? begin,
    DateTime? end,
    String typeWater = '',
    String? location,
  }) =>
      Competition(
        id: id,
        name: 'C$id',
        beginDate: begin,
        endDate: end,
        location: location,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: typeWater,
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        numberOfLanes: 0,
        organizer: 'X',
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
        organizerClub: const Club(id: 1, name: 'X'),
      );

  setUp(() {
    Get.testMode = true;
    repo = _MockRepo();
    users = _MockUserService();
    lang = _MockLanguageService();
    prefs = _MockPrefs();
    when(() => lang.currentLanguage).thenReturn('fr_FR'.obs);
    when(() => prefs.lastViewedIds).thenReturn(<int>[].obs);
    when(() => prefs.favoriteIds).thenReturn(<int>{}.obs);
    when(() => prefs.isFavorite(any())).thenReturn(false);
    controller = HomeController(repo, users, lang, prefs);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeController.loadCompetitions', () {
    test('loads, sorts by beginDate then name, clears error', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenAnswer((_) async => [
            c(2, begin: DateTime.utc(2026, 5, 2)),
            c(1, begin: DateTime.utc(2026, 5, 1)),
          ]);

      await controller.loadCompetitions();

      expect(controller.competitions.length, 2);
      expect(controller.competitions.first.id, 1);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError and clears loading', () async {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenThrow(const NetworkException('offline'));

      await controller.loadCompetitions();

      expect(controller.competitions, isEmpty);
      expect(controller.hasError.value, true);
      expect(controller.isLoading.value, false);
    });
  });

  group('HomeController.filteredCompetitions', () {
    test('temporal=all returns everything', () {
      controller.competitions.value = [c(1), c(2), c(3)];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.all);
      controller.setSearchQuery('');

      expect(controller.filteredCompetitions.length, 3);
    });

    test('temporal=thisWeek keeps only competitions overlapping current week',
        () {
      final now = DateTime.now();
      final inWeek = c(1, begin: now, end: now.add(const Duration(days: 1)));
      final farFuture = c(
        2,
        begin: now.add(const Duration(days: 60)),
        end: now.add(const Duration(days: 61)),
      );
      controller.competitions.value = [inWeek, farFuture];
      controller.setTemporal(TemporalFilter.thisWeek);

      expect(controller.filteredCompetitions, [inWeek]);
    });

    test(
        'temporal=lastViewed returns competitions in last-viewed order, '
        'skipping ids not loaded', () {
      when(() => prefs.lastViewedIds).thenReturn(<int>[3, 99, 1].obs);
      controller.competitions.value = [c(1), c(2), c(3)];
      controller.setTemporal(TemporalFilter.lastViewed);

      final result = controller.filteredCompetitions.map((x) => x.id).toList();
      expect(result, [3, 1]);
    });

    test('discipline=pool keeps only swimming competitions', () {
      controller.competitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
      ];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.pool);

      expect(controller.filteredCompetitions.map((x) => x.id), [1]);
    });

    test('discipline=coastal keeps only beach competitions', () {
      controller.competitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
      ];
      controller.setTemporal(TemporalFilter.all);
      controller.setDiscipline(HomeFilter.coastal);

      expect(controller.filteredCompetitions.map((x) => x.id), [2]);
    });

    test('search filters by name and location, case-insensitive', () {
      controller.competitions.value = [
        c(1, location: 'Paris'),
        c(2, location: 'Lyon'),
      ];
      controller.setTemporal(TemporalFilter.all);

      controller.setSearchQuery('PARIS');
      expect(controller.filteredCompetitions.map((x) => x.id), [1]);

      controller.setSearchQuery('c2');
      expect(controller.filteredCompetitions.map((x) => x.id), [2]);
    });

    test('combines temporal, discipline, and search', () {
      final now = DateTime.now();
      controller.competitions.value = [
        c(1,
            begin: now,
            end: now.add(const Duration(days: 1)),
            typeWater: 'Eau-plate'),
        c(2,
            begin: now,
            end: now.add(const Duration(days: 1)),
            typeWater: 'Côtier'),
        c(3,
            begin: now.add(const Duration(days: 60)),
            end: now.add(const Duration(days: 61)),
            typeWater: 'Eau-plate'),
      ];
      controller.setTemporal(TemporalFilter.thisWeek);
      controller.setDiscipline(HomeFilter.pool);
      controller.setSearchQuery('C1');

      expect(controller.filteredCompetitions.map((x) => x.id), [1]);
    });
  });

  group('HomeController favorites', () {
    test('toggleFavorite delegates to UserPreferencesService', () async {
      when(() => prefs.toggleFavorite(any())).thenAnswer((_) async {});
      await controller.toggleFavorite(42);
      verify(() => prefs.toggleFavorite(42)).called(1);
    });

    test('isFavorite delegates to UserPreferencesService', () {
      when(() => prefs.isFavorite(7)).thenReturn(true);
      expect(controller.isFavorite(7), isTrue);
    });

    test('favoriteIds exposes the service-backed RxSet', () {
      final set = <int>{1, 2}.obs;
      when(() => prefs.favoriteIds).thenReturn(set);
      expect(controller.favoriteIds, set);
    });
  });

  group('HomeController.navigateToCompetitionDetails', () {
    test('records the view before navigation', () async {
      when(() => prefs.recordView(any())).thenAnswer((_) async {});

      await controller.navigateToCompetitionDetails(c(55));

      verify(() => prefs.recordView(55)).called(1);
    });
  });
}
