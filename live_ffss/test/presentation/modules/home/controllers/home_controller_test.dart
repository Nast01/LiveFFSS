import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/core/services/language_service.dart';
import 'package:live_ffss/app/data/repositories/competition_repository.dart';
import 'package:live_ffss/app/data/services/user_service.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/competition.dart';
import 'package:live_ffss/app/module/home/controllers/home_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements CompetitionRepository {}

class _MockUserService extends Mock implements UserService {}

class _MockLanguageService extends Mock implements LanguageService {}

void main() {
  setUpAll(() {
    registerFallbackValue(CompetitionType.mixte);
    registerFallbackValue(CompetitionVisibility.incoming);
  });

  late _MockRepo repo;
  late _MockUserService users;
  late _MockLanguageService lang;
  late HomeController controller;

  Competition c(int id, {DateTime? begin}) => Competition(
        id: id,
        name: 'C$id',
        beginDate: begin,
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: '',
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
    repo = _MockRepo();
    users = _MockUserService();
    lang = _MockLanguageService();
    when(() => lang.currentLanguage).thenReturn('fr_FR'.obs);
    controller = HomeController(repo, users, lang);
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

  group('HomeController paging slice', () {
    test('carouselCompetitions returns at most first 5', () {
      controller.competitions
          .value = List.generate(8, (i) => c(i + 1));
      expect(controller.carouselCompetitions.length, 5);
      expect(controller.carouselCompetitions.first.id, 1);
    });

    test('listCompetitions returns the rest after first 5', () {
      controller.competitions
          .value = List.generate(8, (i) => c(i + 1));
      expect(controller.listCompetitions.length, 3);
      expect(controller.listCompetitions.first.id, 6);
    });

    test('listCompetitions is empty when fewer than 6 total', () {
      controller.competitions.value = List.generate(3, (i) => c(i + 1));
      expect(controller.listCompetitions, isEmpty);
    });

    test('loadMore increases displayedItems up to listCompetitions.length',
        () {
      controller.competitions
          .value = List.generate(20, (i) => c(i + 1));
      expect(controller.displayedItems.value, 3);
      controller.loadMore();
      expect(controller.displayedItems.value, 6);
    });
  });

  group('HomeController.setFilter', () {
    test('updates selectedFilter', () {
      controller.setFilter(HomeFilter.coastal);
      expect(controller.selectedFilter.value, HomeFilter.coastal);
    });
  });
}
