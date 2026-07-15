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
