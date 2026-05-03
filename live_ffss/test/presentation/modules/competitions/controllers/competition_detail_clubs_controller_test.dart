import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/club.dart';
import 'package:live_ffss/app/domain/models/referee.dart';
import 'package:live_ffss/app/module/competitions/controllers/competition_detail_clubs_controller.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements ClubRepository {}

void main() {
  late _MockRepo repo;
  late CompetitionDetailClubsController controller;

  Club c(int id, String name) => Club(id: id, name: name);

  Athlete athlete(String first, String last) => Athlete(
        id: 0,
        licenseeNumber: '',
        firstName: first,
        lastName: last,
        gender: Gender.male,
        year: 0,
        nationalityCode: '',
        nationality: '',
        isValid: true,
        isLicensee: true,
        isGuest: false,
      );

  Referee referee(String first, String last) => Referee(
        id: 0,
        licenseeNumber: '',
        firstName: first,
        lastName: last,
        gender: Gender.male,
        year: 0,
        level: '',
        levelMax: '',
        nationalityCode: '',
        nationality: '',
        isValid: true,
        isLicensee: true,
        isGuest: false,
        isPrincipal: false,
        availabilities: const [],
      );

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailClubsController(repo);
  });

  group('CompetitionDetailClubsController.loadClubs', () {
    test('loads, sorts by name', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            c(1, 'Beta'),
            c(2, 'Alpha'),
          ]);

      await controller.loadClubs(99);

      expect(controller.allClubs.length, 2);
      expect(controller.allClubs.first.name, 'Alpha');
      expect(controller.filteredClubs.length, 2);
      expect(controller.isLoading.value, false);
      expect(controller.hasError.value, false);
    });

    test('on AppException sets hasError', () async {
      when(() => repo.getClubs(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.loadClubs(99);

      expect(controller.hasError.value, true);
      expect(controller.allClubs, isEmpty);
    });
  });

  group('CompetitionDetailClubsController.searchQuery', () {
    setUp(() {
      controller.allClubs.value = [
        Club(
          id: 1,
          name: 'Marseille',
          athletes: [athlete('Alice', 'Doe'), athlete('Bob', 'Smith')],
          referees: [referee('Carl', 'Jones')],
        ),
        Club(
          id: 2,
          name: 'Paris',
          athletes: [athlete('Diana', 'Lee')],
          referees: [referee('Bob', 'Adams')],
        ),
      ];
      controller.setSearchQuery('');
    });

    test('starts at empty string and includes all clubs', () {
      expect(controller.searchQuery.value, '');
      expect(controller.filteredClubs.length, 2);
    });

    test('empty query restores all clubs and all members', () {
      controller.setSearchQuery('Alice');
      controller.setSearchQuery('');
      expect(controller.filteredClubs.length, 2);
      expect(controller.filteredClubs[0].athletes.length, 2);
      expect(controller.filteredClubs[1].athletes.length, 1);
    });

    test('matches club name (case-insensitive) keeps all members', () {
      controller.setSearchQuery('paris');
      expect(controller.filteredClubs.length, 1);
      expect(controller.filteredClubs.first.name, 'Paris');
      expect(controller.filteredClubs.first.athletes.length, 1);
      expect(controller.filteredClubs.first.referees.length, 1);
    });

    test('matches athlete name narrows that club to matching athletes only',
        () {
      controller.setSearchQuery('alice');
      expect(controller.filteredClubs.length, 1);
      expect(controller.filteredClubs.first.name, 'Marseille');
      expect(controller.filteredClubs.first.athletes.length, 1);
      expect(controller.filteredClubs.first.athletes.first.firstName, 'Alice');
      expect(controller.filteredClubs.first.referees, isEmpty);
    });

    test('matches referee name narrows that club to matching referees only',
        () {
      controller.setSearchQuery('jones');
      expect(controller.filteredClubs.length, 1);
      expect(controller.filteredClubs.first.name, 'Marseille');
      expect(controller.filteredClubs.first.referees.length, 1);
      expect(controller.filteredClubs.first.referees.first.lastName, 'Jones');
      expect(controller.filteredClubs.first.athletes, isEmpty);
    });

    test('a name matching across multiple clubs returns each with that match',
        () {
      controller.setSearchQuery('Bob');
      expect(controller.filteredClubs.length, 2);
      expect(controller.filteredClubs[0].athletes.length, 1);
      expect(controller.filteredClubs[0].athletes.first.firstName, 'Bob');
      expect(controller.filteredClubs[1].referees.length, 1);
      expect(controller.filteredClubs[1].referees.first.firstName, 'Bob');
    });

    test('no match returns an empty list', () {
      controller.setSearchQuery('xyz');
      expect(controller.filteredClubs, isEmpty);
    });

    test('whitespace-only query is treated as empty', () {
      controller.setSearchQuery('   ');
      expect(controller.filteredClubs.length, 2);
    });
  });
}
