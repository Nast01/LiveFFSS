import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
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
