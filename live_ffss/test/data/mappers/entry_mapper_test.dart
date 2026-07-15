import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/mappers/entry_mapper.dart';

void main() {
  group('EntryMapper', () {
    test('maps a full engagement DTO to domain', () {
      const dto = EntryDto(
        id: 5,
        raceId: 88,
        category: CategoryDto(id: 2, name: 'Senior'),
        organismeId: 30,
        organisme: ClubDto(id: 30, name: 'SC Marseille', logoUrl: 'http://x/l.png'),
        status: 1,
        statusLabel: 'Engagé',
        isForfeit: true,
        athletes: [
          AthleteDto(
            id: 7,
            firstName: 'Jean',
            lastName: 'Dupont',
            year: 2001,
            performanceTime: 3421,
            performanceLabel: '34.21',
            clubId: 30,
            clubLabel: 'SC Marseille',
            isSubstitute: true,
          ),
        ],
      );

      final entry = dto.toDomain();

      expect(entry.id, 5);
      expect(entry.raceId, 88);
      expect(entry.category.name, 'Senior');
      expect(entry.organisme, isNotNull);
      expect(entry.organisme!.name, 'SC Marseille');
      expect(entry.organisme!.logoUrl, 'http://x/l.png');
      expect(entry.status, 1);
      expect(entry.statusLabel, 'Engagé');
      expect(entry.isForfeit, isTrue);

      final athlete = entry.athletes.single;
      expect(athlete.firstName, 'Jean');
      expect(athlete.performanceTime, 3421);
      expect(athlete.performanceLabel, '34.21');
      expect(athlete.clubLabel, 'SC Marseille');
      expect(athlete.isSubstitute, isTrue);
    });

    test('defaults organisme to null and forfeit to false when absent', () {
      const dto = EntryDto(
        id: 1,
        category: CategoryDto(id: 1, name: 'U12'),
        status: 0,
        statusLabel: '',
      );

      final entry = dto.toDomain();

      expect(entry.organisme, isNull);
      expect(entry.isForfeit, isFalse);
      expect(entry.athletes, isEmpty);
      expect(entry.entryTime, 0);
      expect(entry.entryTimeLabel, '');
    });

    test('parses the engagement JSON contract (French keys)', () {
      final dto = EntryDto.fromJson(const {
        'Id': 12,
        'IdEpreuve': 88,
        'categorie': {'Id': 2, 'Nom': 'Senior'},
        'IdOrganisme': 30,
        'Organisme': {'Id': 30, 'label': 'SC Marseille'},
        'Statut': 1,
        'statutLabel': 'Engagé',
        'forfait': true,
        'athletes': [
          {
            'Id': 7,
            'Prenom': 'Jean',
            'Nom': 'Dupont',
            'Annee': 2001,
            'Performance': 3421,
            'performanceLabel': '34.21',
            'idClub': 30,
            'clubLabel': 'SC Marseille',
            'isRemplacant': false,
          },
        ],
      });

      final entry = dto.toDomain();

      expect(entry.raceId, 88);
      expect(entry.organisme!.name, 'SC Marseille');
      expect(entry.isForfeit, isTrue);
      expect(entry.athletes.single.performanceLabel, '34.21');
    });
  });
}
