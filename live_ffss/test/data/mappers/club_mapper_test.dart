import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';
import 'package:live_ffss/app/data/mappers/club_mapper.dart';
import 'package:live_ffss/app/domain/models/club.dart';

void main() {
  group('ClubMapper', () {
    test('maps a full ClubDto to Club', () {
      const dto = ClubDto(
        id: 42,
        name: 'CN Marseille',
        shortName: 'CNM',
        logoUrl: 'https://example.test/logo.png',
        capUrl: 'https://example.test/cap.png',
      );

      final club = dto.toDomain();

      expect(club.id, 42);
      expect(club.name, 'CN Marseille');
      expect(club.shortName, 'CNM');
      expect(club.logoUrl, 'https://example.test/logo.png');
      expect(club.capUrl, 'https://example.test/cap.png');
      expect(club.athletes, isEmpty);
      expect(club.referees, isEmpty);
    });

    test('maps a sparse ClubDto (only required fields)', () {
      const dto = ClubDto(id: 1, name: 'Bare Club');

      final club = dto.toDomain();

      expect(club.id, 1);
      expect(club.name, 'Bare Club');
      expect(club.shortName, isNull);
      expect(club.logoUrl, isNull);
      expect(club.capUrl, isNull);
    });
  });

  group('ClubMapper back-injects club into nested members', () {
    test('each athlete carries a back-ref to its parent club', () {
      const dto = ClubDto(
        id: 7,
        name: 'CN Lyon',
        athletes: [
          AthleteDto(
            id: 100,
            firstName: 'Jean',
            lastName: 'Dupont',
            gender: 'M',
            year: 2005,
            isValid: true,
          ),
          AthleteDto(
            id: 101,
            firstName: 'Anne',
            lastName: 'Martin',
            gender: 'F',
            year: 2007,
            isValid: true,
          ),
        ],
      );

      final club = dto.toDomain();

      expect(club.athletes, hasLength(2));
      for (final a in club.athletes) {
        expect(a.club, isNotNull);
        expect(a.club!.id, 7);
        expect(a.club!.name, 'CN Lyon');
      }
    });

    test('referees also get the club back-ref', () {
      const dto = ClubDto(
        id: 9,
        name: 'CN Nice',
        referees: [
          RefereeDto(
            id: 200,
            firstName: 'Paul',
            lastName: 'Durand',
            gender: 'M',
            year: 1980,
            level: 'A',
            levelMax: 'A',
            isValid: true,
          ),
        ],
      );

      final club = dto.toDomain();

      expect(club.referees.single.club, isNotNull);
      expect(club.referees.single.club!.id, 9);
    });

    test('back-ref club is lightweight: no nested athletes/referees', () {
      // Prevents a Club -> Athlete -> Club -> Athlete -> ... memory cycle
      // when serializing or debugging.
      const dto = ClubDto(
        id: 7,
        name: 'CN Lyon',
        athletes: [
          AthleteDto(
            id: 100,
            firstName: 'X',
            lastName: 'Y',
            gender: 'M',
            year: 2005,
            isValid: true,
          ),
        ],
      );

      final back = dto.toDomain().athletes.single.club!;

      expect(back.athletes, isEmpty);
      expect(back.referees, isEmpty);
    });
  });

  group('ClubMapper.toDomainClubs splits the FFSS bucket organisme', () {
    AthleteDto athlete(int id, {int clubId = 0, String clubLabel = ''}) =>
        AthleteDto(
          id: id,
          firstName: 'A$id',
          lastName: 'B$id',
          gender: 'M',
          year: 2000,
          isValid: true,
          clubId: clubId,
          clubLabel: clubLabel,
        );

    RefereeDto referee(
      int id, {
      bool isGuest = false,
      int clubId = 0,
      String clubLabel = '',
      int refereeClubId = 0,
      String refereeClubLabel = '',
    }) =>
        RefereeDto(
          id: id,
          firstName: 'R$id',
          lastName: 'S$id',
          gender: 'M',
          year: 1980,
          level: 'A',
          levelMax: 'A',
          isValid: true,
          isGuest: isGuest,
          clubId: clubId,
          clubLabel: clubLabel,
          refereeClubId: refereeClubId,
          refereeClubLabel: refereeClubLabel,
        );

    test('a regular club yields exactly itself', () {
      final dto = ClubDto(
        id: 42,
        name: 'CN Marseille',
        logoUrl: 'https://example.test/logo.png',
        athletes: [athlete(1, clubId: 999, clubLabel: 'Ignored')],
      );

      final clubs = dto.toDomainClubs();

      expect(clubs, hasLength(1));
      expect(clubs.single.id, 42);
      expect(clubs.single.name, 'CN Marseille');
      expect(clubs.single.logoUrl, 'https://example.test/logo.png');
      expect(clubs.single.athletes, hasLength(1));
    });

    test('bucket athletes are grouped by their own club', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        athletes: [
          athlete(1, clubId: 800, clubLabel: 'Guest Alpha'),
          athlete(2, clubId: 900, clubLabel: 'Guest Bravo'),
          athlete(3, clubId: 800, clubLabel: 'Guest Alpha'),
        ],
      );

      final clubs = dto.toDomainClubs();

      expect(clubs.map((c) => c.id), [800, 900]);
      expect(clubs.first.name, 'Guest Alpha');
      expect(clubs.first.athletes.map((a) => a.id), [1, 3]);
      expect(clubs.last.athletes.map((a) => a.id), [2]);
      expect(clubs.first.athletes.first.club!.id, 800);
    });

    test('a non-guest officiel resolves via idOfficielClub', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        referees: [
          referee(
            10,
            clubId: 800,
            clubLabel: 'Attached Club',
            refereeClubId: 700,
            refereeClubLabel: 'Licensed Club',
          ),
        ],
      );

      final club = dto.toDomainClubs().single;

      expect(club.id, 700);
      expect(club.name, 'Licensed Club');
      expect(club.referees.single.club!.id, 700);
    });

    test('a guest officiel resolves via idClub', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        referees: [
          referee(
            10,
            isGuest: true,
            clubId: 800,
            clubLabel: 'Guest Alpha',
            refereeClubId: 700,
            refereeClubLabel: 'Licensed Club',
          ),
        ],
      );

      final club = dto.toDomainClubs().single;

      expect(club.id, 800);
      expect(club.name, 'Guest Alpha');
    });

    test('split clubs do not inherit the bucket logo/cap/short name', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        shortName: 'FFSS',
        logoUrl: 'https://example.test/ffss-logo.png',
        capUrl: 'https://example.test/ffss-cap.png',
        athletes: [athlete(1, clubId: 800, clubLabel: 'Guest Alpha')],
      );

      final club = dto.toDomainClubs().single;

      expect(club.shortName, isNull);
      expect(club.logoUrl, isNull);
      expect(club.capUrl, isNull);
    });

    test('members with no resolvable club stay under the bucket identity', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        logoUrl: 'https://example.test/ffss-logo.png',
        athletes: [
          athlete(1, clubId: 800, clubLabel: 'Guest Alpha'),
          athlete(2),
          athlete(3, clubId: 900),
          athlete(4, clubLabel: 'No id'),
        ],
      );

      final clubs = dto.toDomainClubs();

      expect(clubs.map((c) => c.id), [800, ffssBucketOrganismeId]);
      final leftovers = clubs.last;
      expect(leftovers.name, 'FFSS');
      expect(leftovers.athletes.map((a) => a.id), [2, 3, 4]);
      // The leftover group IS the FFSS organisme, so it keeps its branding.
      expect(leftovers.logoUrl, 'https://example.test/ffss-logo.png');
    });

    test('split clubs are flagged as guests, regular clubs are not', () {
      final regular = ClubDto(
        id: 42,
        name: 'CN Marseille',
        athletes: [athlete(1, clubId: 800, clubLabel: 'Ignored')],
      );
      final bucket = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        athletes: [
          athlete(1, clubId: 800, clubLabel: 'Guest Alpha'),
          athlete(2),
        ],
      );

      expect(regular.toDomainClubs().single.isGuest, isFalse);

      final split = bucket.toDomainClubs();
      expect(split.first.isGuest, isTrue);
      // The leftover group IS the FFSS organisme, not a guest club.
      expect(split.last.id, ffssBucketOrganismeId);
      expect(split.last.isGuest, isFalse);
    });

    test('an empty bucket yields the bucket itself', () {
      const dto = ClubDto(id: ffssBucketOrganismeId, name: 'FFSS');

      final clubs = dto.toDomainClubs();

      expect(clubs, hasLength(1));
      expect(clubs.single.id, ffssBucketOrganismeId);
      expect(clubs.single.name, 'FFSS');
    });

    test('toDomain on a bucket returns the first split club', () {
      final dto = ClubDto(
        id: ffssBucketOrganismeId,
        name: 'FFSS',
        athletes: [
          athlete(1, clubId: 800, clubLabel: 'Guest Alpha'),
          athlete(2, clubId: 900, clubLabel: 'Guest Bravo'),
        ],
      );

      expect(dto.toDomain().id, 800);
    });
  });

  group('ClubX', () {
    test('hasLogo is true for non-empty logoUrl', () {
      const club = Club(id: 1, name: 'X', logoUrl: 'https://x');
      expect(club.hasLogo, isTrue);
    });

    test('hasLogo is false for null or empty logoUrl', () {
      expect(const Club(id: 1, name: 'X').hasLogo, isFalse);
      expect(const Club(id: 1, name: 'X', logoUrl: '').hasLogo, isFalse);
    });

    test('hasCap mirrors hasLogo for capUrl', () {
      expect(const Club(id: 1, name: 'X', capUrl: 'https://c').hasCap, isTrue);
      expect(const Club(id: 1, name: 'X').hasCap, isFalse);
    });
  });
}
