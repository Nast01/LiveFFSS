import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/race_format_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/race_format_configuration_dto.dart';
import 'package:live_ffss/app/data/dtos/discipline_dto.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RaceFormatRemoteDataSource {}

void main() {
  late _MockDataSource dataSource;
  late RaceFormatRepository repository;

  setUp(() {
    dataSource = _MockDataSource();
    repository = RaceFormatRepositoryImpl(dataSource);
  });

  RaceFormatConfigurationDto dto(int id) => RaceFormatConfigurationDto(
        id: id,
        competitionId: 1451,
        disciplineId: 13,
        gender: 'F',
        label: 'D$id',
        fullLabel: 'D$id',
        genderLabel: 'Dames',
        discipline: const DisciplineDto(
          id: '13',
          name: 'Surfski',
          speciality: 1,
          specialityLabel: 'Côtier',
        ),
      );

  List<RaceFormatConfigurationDto> page(int from, int count) =>
      [for (var i = 0; i < count; i++) dto(from + i)];

  // FFSS serves this list 30 rows at a time. A competition with 69
  // déroulements handed back only the first 30, so every one past the
  // thirtieth showed as absent in the app while sitting on the federal site.
  group('getRaceFormats pages until the server runs out', () {
    test('follows the window until a short page ends it', () async {
      when(() => dataSource.getRaceFormats(1451, start: 0, length: 100))
          .thenAnswer((_) async => page(1, 100));
      when(() => dataSource.getRaceFormats(1451, start: 100, length: 100))
          .thenAnswer((_) async => page(101, 40));

      final all = await repository.getRaceFormats(1451);

      expect(all, hasLength(140));
      verify(() => dataSource.getRaceFormats(1451, start: 0, length: 100))
          .called(1);
      verify(() => dataSource.getRaceFormats(1451, start: 100, length: 100))
          .called(1);
    });

    test('a single short page is one call, not two', () async {
      when(() => dataSource.getRaceFormats(1451, start: 0, length: 100))
          .thenAnswer((_) async => page(1, 69));

      final all = await repository.getRaceFormats(1451);

      expect(all, hasLength(69));
      verify(() => dataSource.getRaceFormats(1451, start: 0, length: 100))
          .called(1);
      // A short page means the end; asking for the next one would be a wasted
      // round trip on every single load.
      verifyNever(
          () => dataSource.getRaceFormats(1451, start: 100, length: 100));
    });

    test('an empty first page returns nothing and stops', () async {
      when(() => dataSource.getRaceFormats(1451, start: 0, length: 100))
          .thenAnswer((_) async => []);

      expect(await repository.getRaceFormats(1451), isEmpty);
    });
  });
}
