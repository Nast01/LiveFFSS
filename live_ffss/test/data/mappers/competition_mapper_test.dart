import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/competition_dto.dart';
import 'package:live_ffss/app/data/mappers/competition_mapper.dart';
import 'package:live_ffss/app/domain/models/competition.dart';

void main() {
  group('CompetitionMapper', () {
    test('maps a fully-populated CompetitionDto to Competition', () {
      const dto = CompetitionDto(
        id: 42,
        name: 'Coupe de France',
        beginDate: '2026-05-01T00:00:00.000Z',
        endDate: '2026-05-03T00:00:00.000Z',
        beginEntryLimitDate: '2026-04-01T00:00:00.000Z',
        endEntryLimitDate: '2026-04-25T00:00:00.000Z',
        location: 'Marseille',
        statusCode: 1,
        statusLabel: 'Open',
        description: 'Annual cup',
        speciality: 2,
        specialityLabel: 'Pool',
        typeWater: 'eau-plate',
        typePool: '50m',
        typeChrono: 'Electronic',
        isEligibleToNationalRecord: true,
        numberOfLanes: 8,
        organisme: CompetitionOrganismeDto(
          id: 7,
          organizerName: 'FFSS',
          clubFullName: 'CN Marseille',
          shortName: 'CNM',
          logoUrl: 'https://example.test/logo.png',
          capUrl: 'https://example.test/cap.png',
        ),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 3,
        levelLabel: 'National',
        refereePrincipal: 'Jean Dupont',
      );

      final c = dto.toDomain();

      expect(c.id, 42);
      expect(c.name, 'Coupe de France');
      expect(c.beginDate, DateTime.utc(2026, 5, 1));
      expect(c.endDate, DateTime.utc(2026, 5, 3));
      expect(c.beginEntryLimitDate, DateTime.utc(2026, 4, 1));
      expect(c.endEntryLimitDate, DateTime.utc(2026, 4, 25));
      expect(c.location, 'Marseille');
      expect(c.statusCode, 1);
      expect(c.statusLabel, 'Open');
      expect(c.organizer, 'FFSS');
      expect(c.organizerClub.id, 7);
      expect(c.organizerClub.name, 'CN Marseille');
      expect(c.organizerClub.shortName, 'CNM');
      expect(c.organizerClub.logoUrl, 'https://example.test/logo.png');
      expect(c.numberOfLanes, 8);
      expect(c.refereePrincipal, 'Jean Dupont');
    });

    test('handles null optional dates and missing numberOfLanes', () {
      const dto = CompetitionDto(
        id: 1,
        name: 'Sparse',
        beginDate: null,
        endDate: null,
        statusCode: 0,
        statusLabel: 'Pending',
        speciality: 0,
        specialityLabel: 'None',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: CompetitionOrganismeDto(id: 1, organizerName: 'X'),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

      final c = dto.toDomain();

      expect(c.beginDate, isNull);
      expect(c.endDate, isNull);
      expect(c.numberOfLanes, 0);
      expect(c.organizerClub.name, ''); // clubFullName is null -> empty string
      expect(c.refereePrincipal, isNull);
    });

    test('organizerClub.name uses clubFullName when present, otherwise empty',
        () {
      const dto = CompetitionDto(
        id: 1,
        name: 'X',
        statusCode: 0,
        statusLabel: '',
        speciality: 0,
        specialityLabel: '',
        typeWater: '',
        typePool: '',
        typeChrono: '',
        isEligibleToNationalRecord: false,
        organisme: CompetitionOrganismeDto(
          id: 1,
          organizerName: 'Org Label',
          clubFullName: 'Real Club Name',
        ),
        hasBegun: false,
        hasResult: false,
        hasPassed: false,
        level: 0,
        levelLabel: '',
      );

      final c = dto.toDomain();
      expect(c.organizerClub.name, 'Real Club Name');
    });
  });
}
