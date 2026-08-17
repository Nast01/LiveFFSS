import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements ClubRemoteDataSource {}

AthleteDto _athlete(int id, int clubId, String clubLabel) => AthleteDto(
      id: id,
      firstName: 'A$id',
      lastName: 'B$id',
      gender: 'M',
      year: 2000,
      isValid: true,
      clubId: clubId,
      clubLabel: clubLabel,
    );

void main() {
  late _MockDataSource ds;
  late ClubRepository repo;

  ClubDto makeDto(int id, String name) => ClubDto(id: id, name: name);

  setUp(() {
    ds = _MockDataSource();
    repo = ClubRepositoryImpl(ds);
  });

  group('ClubRepository.getClubs', () {
    test('forwards competitionId and maps DTOs to domain', () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => [
            makeDto(1, 'Alpha'),
            makeDto(2, 'Bravo'),
          ]);

      final list = await repo.getClubs(42);

      expect(list.length, 2);
      expect(list.first.name, 'Alpha');
      expect(list.first.athletes, isEmpty);
      verify(() => ds.getClubs(42)).called(1);
    });

    test('splits the FFSS bucket organisme into its member clubs', () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => [
            makeDto(1, 'Alpha'),
            ClubDto(
              id: ffssBucketOrganismeId,
              name: 'FFSS',
              athletes: [
                _athlete(10, 800, 'Guest Alpha'),
                _athlete(11, 900, 'Guest Bravo'),
              ],
            ),
          ]);

      final list = await repo.getClubs(42);

      expect(list.map((c) => c.id), [1, 800, 900]);
    });
  });

  group('ClubRepository.getClubDetail', () {
    test('forwards clubId and maps DTO to domain', () async {
      when(() => ds.getClubDetail(any()))
          .thenAnswer((_) async => makeDto(7, 'Solo'));

      final club = await repo.getClubDetail(7);

      expect(club.id, 7);
      expect(club.name, 'Solo');
      verify(() => ds.getClubDetail(7)).called(1);
    });

    test('picks the requested club when the payload is the FFSS bucket',
        () async {
      when(() => ds.getClubDetail(any())).thenAnswer((_) async => ClubDto(
            id: ffssBucketOrganismeId,
            name: 'FFSS',
            athletes: [
              _athlete(10, 800, 'Guest Alpha'),
              _athlete(11, 900, 'Guest Bravo'),
            ],
          ));

      final club = await repo.getClubDetail(900);

      expect(club.id, 900);
      expect(club.name, 'Guest Bravo');
    });

    test('falls back to the first split club when none matches', () async {
      when(() => ds.getClubDetail(any())).thenAnswer((_) async => ClubDto(
            id: ffssBucketOrganismeId,
            name: 'FFSS',
            athletes: [_athlete(10, 800, 'Guest Alpha')],
          ));

      final club = await repo.getClubDetail(ffssBucketOrganismeId);

      expect(club.id, 800);
    });
  });

  group('ClubRepository.getClubDetails', () {
    test('resolves each id once, deduping and dropping non-positive ids',
        () async {
      when(() => ds.getClubDetail(any())).thenAnswer((i) async => makeDto(
          i.positionalArguments.first as int,
          'Club ${i.positionalArguments.first}'));

      final byId = await repo.getClubDetails([7, 7, 9, 0, -1]);

      expect(byId.keys.toList()..sort(), [7, 9]);
      expect(byId[7]!.name, 'Club 7');
      verify(() => ds.getClubDetail(7)).called(1);
      verify(() => ds.getClubDetail(9)).called(1);
      verifyNever(() => ds.getClubDetail(0));
    });

    test('is best-effort: a failing club is skipped, the others resolve',
        () async {
      when(() => ds.getClubDetail(7))
          .thenThrow(const NetworkException('offline'));
      when(() => ds.getClubDetail(9))
          .thenAnswer((_) async => makeDto(9, 'Club 9'));

      final byId = await repo.getClubDetails([7, 9]);

      expect(byId.keys, [9]);
    });

    test('an empty request makes no call', () async {
      final byId = await repo.getClubDetails(const []);

      expect(byId, isEmpty);
      verifyNever(() => ds.getClubDetail(any()));
    });
  });

  group('ClubRepository.getAthleteClubs', () {
    Athlete domainAthlete(int id, int clubId) => Athlete(
          id: id,
          licenseeNumber: 'L$id',
          firstName: 'A$id',
          lastName: 'B$id',
          gender: Gender.male,
          year: 2000,
          nationalityCode: '',
          nationality: '',
          isValid: true,
          clubId: clubId,
        );

    test('resolves an athlete the club list never named, via their clubId',
        () async {
      // The regression this guards: three clubmates in a heat, one logo. The
      // list named only the first, so only the first was ever resolved.
      when(() => ds.getClubs(any())).thenAnswer((_) async => [
            ClubDto(id: 7, name: 'Nice', athletes: [_athlete(1, 7, 'Nice')]),
          ]);
      when(() => ds.getClubDetail(7)).thenAnswer(
        (_) async => ClubDto(id: 7, name: 'Nice', logoUrl: 'https://logo/7'),
      );

      final byAthlete = await repo.getAthleteClubs(
        42,
        [domainAthlete(1, 7), domainAthlete(2, 7), domainAthlete(3, 7)],
      );

      expect(byAthlete.keys, [1, 2, 3]);
      expect(byAthlete.values.map((c) => c.logoUrl),
          everyElement('https://logo/7'));
    });

    test('fetches each club once however many athletes it fields', () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => const []);
      when(() => ds.getClubDetail(7))
          .thenAnswer((_) async => ClubDto(id: 7, name: 'Nice'));

      await repo
          .getAthleteClubs(42, [domainAthlete(1, 7), domainAthlete(2, 7)]);

      verify(() => ds.getClubDetail(7)).called(1);
    });

    test('an athlete with no club is absent rather than wrongly resolved',
        () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => const []);

      final byAthlete = await repo.getAthleteClubs(42, [domainAthlete(1, 0)]);

      expect(byAthlete, isEmpty);
      verifyNever(() => ds.getClubDetail(any()));
    });

    test('keeps resolving from clubIds when the club list call fails',
        () async {
      when(() => ds.getClubs(any())).thenThrow(const NetworkException('boom'));
      when(() => ds.getClubDetail(7)).thenAnswer(
        (_) async => ClubDto(id: 7, name: 'Nice', logoUrl: 'https://logo/7'),
      );

      final byAthlete = await repo.getAthleteClubs(42, [domainAthlete(1, 7)]);

      expect(byAthlete[1]?.logoUrl, 'https://logo/7');
    });

    test('a failed detail leaves the name the list gave', () async {
      when(() => ds.getClubs(any())).thenAnswer((_) async => [
            ClubDto(id: 7, name: 'Nice', athletes: [_athlete(1, 7, 'Nice')]),
          ]);
      when(() => ds.getClubDetail(7)).thenThrow(const NetworkException('boom'));

      final byAthlete = await repo.getAthleteClubs(42, [domainAthlete(1, 7)]);

      expect(byAthlete[1]?.name, 'Nice');
      expect(byAthlete[1]?.logoUrl, isNull);
    });
  });
}
