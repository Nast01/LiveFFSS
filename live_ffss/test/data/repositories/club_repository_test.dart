import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/club_remote_datasource.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';
import 'package:live_ffss/app/data/repositories/club_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements ClubRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late ClubRepository repo;

  ClubDto makeDto(int id, String name) =>
      ClubDto(id: id, name: name);

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
  });
}
