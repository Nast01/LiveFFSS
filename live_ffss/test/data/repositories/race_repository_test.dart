import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/race_remote_datasource.dart';
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
}
