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

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    repo = _MockRepo();
    controller = CompetitionDetailClubsController(repo);
    when(() => repo.getClubDetails(any()))
        .thenAnswer((_) async => <int, Club>{});
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

  group('CompetitionDetailClubsController club images', () {
    // The competition's `organismes` endpoint carries no logo/bonnet at all —
    // only `organisme/:id` does — so the tab has to backfill them.
    test('backfills clubs the list returned without an image', () async {
      when(() => repo.getClubs(any()))
          .thenAnswer((_) async => [c(1, 'Alpha'), c(2, 'Bravo')]);
      when(() => repo.getClubDetails(any())).thenAnswer((_) async => {
            1: const Club(id: 1, name: 'Alpha', logoUrl: 'https://x/logo.png'),
          });

      await controller.loadClubs(99);
      await pumpEventQueue();

      expect(controller.allClubs.first.logoUrl, 'https://x/logo.png');
      expect(controller.filteredClubs.first.logoUrl, 'https://x/logo.png');
    });

    test('the backfill keeps members the detail endpoint does not return',
        () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            Club(id: 1, name: 'Alpha', athletes: [athlete('Alice', 'Doe')]),
          ]);
      when(() => repo.getClubDetails(any())).thenAnswer((_) async => {
            1: const Club(
              id: 1,
              name: 'Alpha',
              logoUrl: 'https://x/logo.png',
              capUrl: 'https://x/cap.png',
            ),
          });

      await controller.loadClubs(99);
      await pumpEventQueue();

      final club = controller.allClubs.single;
      expect(club.logoUrl, 'https://x/logo.png');
      expect(club.capUrl, 'https://x/cap.png');
      expect(club.athletes, hasLength(1));
    });

    test('clubs that already carry an image are not refetched', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            const Club(id: 1, name: 'Alpha', logoUrl: 'https://x/logo.png'),
            const Club(id: 2, name: 'Bravo', capUrl: 'https://x/cap.png'),
            c(3, 'Charlie'),
          ]);

      await controller.loadClubs(99);
      await pumpEventQueue();

      final requested =
          verify(() => repo.getClubDetails(captureAny())).captured.single;
      expect((requested as Iterable<int>).toList(), [3]);
    });

    test('guest clubs are never fetched: their id is not an FFSS organisme',
        () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [
            c(1, 'Alpha'),
            const Club(id: 800, name: 'Guest Alpha', isGuest: true),
          ]);

      await controller.loadClubs(99);
      await pumpEventQueue();

      final requested =
          verify(() => repo.getClubDetails(captureAny())).captured.single;
      expect((requested as Iterable<int>).toList(), [1]);
    });

    test('a backfill with only guest clubs makes no call at all', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async =>
          [const Club(id: 800, name: 'Guest Alpha', isGuest: true)]);

      await controller.loadClubs(99);
      await pumpEventQueue();

      verifyNever(() => repo.getClubDetails(any()));
    });

    test('a failed backfill leaves the list untouched', () async {
      when(() => repo.getClubs(any())).thenAnswer((_) async => [c(1, 'Alpha')]);
      when(() => repo.getClubDetails(any()))
          .thenThrow(const NetworkException('offline'));

      await controller.loadClubs(99);
      await pumpEventQueue();

      expect(controller.allClubs.single.logoUrl, isNull);
      expect(controller.hasError.value, isFalse);
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
