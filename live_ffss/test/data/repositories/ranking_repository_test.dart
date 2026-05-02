import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/ranking_repository.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements RankingRemoteDataSource {}

void main() {
  late _MockDataSource ds;
  late RankingRepository repo;

  setUp(() {
    ds = _MockDataSource();
    repo = RankingRepositoryImpl(ds);
  });

  group('RankingRepository.getClubRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        ClubRanking(position: 1, clubName: 'Alpha', points: 100),
        ClubRanking(position: 2, clubName: 'Bravo', points: 80),
      ];
      when(() => ds.getClubRankings(any())).thenAnswer((_) async => expected);

      final result = await repo.getClubRankings(42);

      expect(result, expected);
      verify(() => ds.getClubRankings(42)).called(1);
    });

    test('returns empty when data source returns empty', () async {
      when(() => ds.getClubRankings(any()))
          .thenAnswer((_) async => const <ClubRanking>[]);

      final result = await repo.getClubRankings(7);

      expect(result, isEmpty);
    });
  });

  group('RankingRepository.getIndividualRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        IndividualRanking(
          position: 1,
          athleteFirstName: 'Alice',
          athleteLastName: 'Doe',
          clubName: 'Alpha',
          points: 200,
        ),
      ];
      when(() => ds.getIndividualRankings(any()))
          .thenAnswer((_) async => expected);

      final result = await repo.getIndividualRankings(42);

      expect(result, expected);
      verify(() => ds.getIndividualRankings(42)).called(1);
    });
  });

  group('RankingRepository.getRelayRankings', () {
    test('forwards competitionId and returns the data source result',
        () async {
      const expected = [
        RelayRanking(
          position: 1,
          clubName: 'Alpha',
          teamName: 'Alpha A',
          points: 150,
        ),
      ];
      when(() => ds.getRelayRankings(any()))
          .thenAnswer((_) async => expected);

      final result = await repo.getRelayRankings(42);

      expect(result, expected);
      verify(() => ds.getRelayRankings(42)).called(1);
    });
  });
}
