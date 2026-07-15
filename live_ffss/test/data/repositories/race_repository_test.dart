import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/dtos/entry_dto.dart';
import 'package:live_ffss/app/data/dtos/heat_dto.dart';
import 'package:live_ffss/app/data/dtos/race_dto.dart';
import 'package:live_ffss/app/data/repositories/race_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RaceRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late RaceRepository repo;

  RaceDto makeDto(int id, {String specLabel = 'Eau-plate'}) => RaceDto(
        id: id,
        disciplineId: 1,
        gender: 'M',
        discipline: RaceDisciplineDto(
          name: 'Race$id',
          nameEnglish: 'Race$id (en)',
          specialityId: 1,
          specialityLabel: specLabel,
        ),
      );

  setUp(() {
    ds = _MockDataSource();
    repo = RaceRepositoryImpl(ds);
  });

  group('RaceRepository.getRaces', () {
    test('forwards competitionId and maps DTOs to domain', () async {
      when(() => ds.getRaces(any())).thenAnswer((_) async => [
            makeDto(1),
            makeDto(2, specLabel: 'Côtier'),
          ]);

      final list = await repo.getRaces(42);

      expect(list.length, 2);
      expect(list.first.name, 'Race1');
      expect(list.last.specialityLabel, 'Côtier');
      verify(() => ds.getRaces(42)).called(1);
    });
  });

  group('RaceRepository.getHeats', () {
    test('forwards raceId and maps HeatDtos to domain Heats', () async {
      when(() => ds.getHeats(any())).thenAnswer((_) async => [
            const HeatDto(id: 1, name: 'S1', done: false, number: 1),
            const HeatDto(id: 2, name: 'S2', done: true, number: 2),
          ]);

      final heats = await repo.getHeats(77);

      expect(heats, hasLength(2));
      expect(heats.first.name, 'S1');
      expect(heats.last.done, isTrue);
      verify(() => ds.getHeats(77)).called(1);
    });
  });

  group('RaceRepository.getEntries', () {
    test('forwards raceId and maps EntryDtos to domain Entries', () async {
      when(() => ds.getEntries(any())).thenAnswer((_) async => [
            const EntryDto(
              id: 1,
              category: CategoryDto(id: 1, name: 'Senior'),
              organisme: ClubDto(id: 9, name: 'SC Marseille'),
              status: 1,
              statusLabel: 'Engagé',
              isForfeit: true,
            ),
          ]);

      final entries = await repo.getEntries(88);

      expect(entries, hasLength(1));
      expect(entries.single.organisme!.name, 'SC Marseille');
      expect(entries.single.isForfeit, isTrue);
      verify(() => ds.getEntries(88)).called(1);
    });
  });
}
