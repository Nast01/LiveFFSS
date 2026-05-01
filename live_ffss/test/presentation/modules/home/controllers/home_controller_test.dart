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
    registerFallbackValue(DateTime(2000));
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
    when(() => repo.getCompetitionsForRange(
          from: any(named: 'from'),
          to: any(named: 'to'),
        )).thenAnswer((_) async => <Competition>[]);
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

    test('temporal=thisWeek reads from thisWeekCompetitions cache', () {
      controller.competitions.value = [c(1), c(2)];
      controller.thisWeekCompetitions.value = [c(10), c(20)];
      // Fill cache so setTemporal does not auto-fetch.
      controller.setTemporal(TemporalFilter.thisWeek);

      final result = controller.filteredCompetitions.map((x) => x.id).toList();
      expect(result, [10, 20]);
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
      controller.thisWeekCompetitions.value = [
        c(1, typeWater: 'Eau-plate'),
        c(2, typeWater: 'Côtier'),
        c(3, typeWater: 'Eau-plate'),
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

  group('HomeController.setTemporal lazy fetch', () {
    test('thisWeek triggers loadThisWeek when cache is empty', () async {
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => [c(7)]);

      controller.setTemporal(TemporalFilter.thisWeek);
      // Drain the microtask queue so the fire-and-forget loadThisWeek future
      // initiated by setTemporal can resolve before we assert on its effect.
      await Future<void>.delayed(Duration.zero);

      expect(controller.thisWeekCompetitions.map((x) => x.id), [7]);
      verify(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).called(1);
    });

    test('thisWeek does not re-fetch when cache is non-empty', () {
      controller.thisWeekCompetitions.value = [c(1)];
      controller.setTemporal(TemporalFilter.thisWeek);

      verifyNever(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ));
    });

    test('thisWeek does not re-fetch when hasErrorThisWeek is true', () {
      controller.hasErrorThisWeek.value = true;
      controller.setTemporal(TemporalFilter.thisWeek);

      verifyNever(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ));
    });
  });

  group('HomeController.loadThisWeek', () {
    test('on success populates cache and clears loading + error flags',
        () async {
      controller.hasErrorThisWeek.value = true; // ensure it gets cleared
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((_) async => [c(1), c(2)]);

      final future = controller.loadThisWeek();
      expect(controller.isLoadingThisWeek.value, isTrue);
      await future;

      expect(controller.thisWeekCompetitions.map((x) => x.id), [1, 2]);
      expect(controller.isLoadingThisWeek.value, isFalse);
      expect(controller.hasErrorThisWeek.value, isFalse);
    });

    test('calls repo with Monday and Sunday of current week', () async {
      DateTime? capturedFrom;
      DateTime? capturedTo;
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenAnswer((invocation) async {
        capturedFrom = invocation.namedArguments[#from] as DateTime;
        capturedTo = invocation.namedArguments[#to] as DateTime;
        return <Competition>[];
      });

      await controller.loadThisWeek();

      expect(capturedFrom, isNotNull);
      expect(capturedTo, isNotNull);
      expect(capturedFrom!.weekday, DateTime.monday);
      expect(capturedTo!.weekday, DateTime.sunday);
      expect(capturedTo!.difference(capturedFrom!).inDays, 6);
    });

    test('on AppException sets hasErrorThisWeek and clears loading', () async {
      when(() => repo.getCompetitionsForRange(
            from: any(named: 'from'),
            to: any(named: 'to'),
          )).thenThrow(const NetworkException('offline'));

      await controller.loadThisWeek();

      expect(controller.hasErrorThisWeek.value, true);
      expect(controller.isLoadingThisWeek.value, false);
      expect(controller.thisWeekCompetitions, isEmpty);
    });
  });

  group('HomeController.refreshAfterLogout extended', () {
    test('clears thisWeekCompetitions and resets hasErrorThisWeek', () {
      when(() => repo.getAllCompetitions(
            type: any(named: 'type'),
            visibility: any(named: 'visibility'),
          )).thenAnswer((_) async => <Competition>[]);
      controller.thisWeekCompetitions.value = [c(1), c(2)];
      controller.hasErrorThisWeek.value = true;

      controller.refreshAfterLogout();

      expect(controller.thisWeekCompetitions, isEmpty);
      expect(controller.hasErrorThisWeek.value, false);
    });
  });
}
