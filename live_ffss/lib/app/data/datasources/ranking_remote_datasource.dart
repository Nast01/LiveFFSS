import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

abstract class RankingRemoteDataSource {
  Future<List<ClubRanking>> getClubRankings(int competitionId);
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId);
  Future<List<RelayRanking>> getRelayRankings(int competitionId);
}

/// Stub implementation: returns empty lists for all three rankings.
///
/// FFSS rankings endpoints are not documented yet (see CLAUDE.md "Known
/// gaps"). The Points tab UI is built around the EmptyState path — when the
/// backend lands, swap this stub for a real HTTP-backed impl that maps DTOs
/// to the three domain models. The repository, controller, view, and tests
/// stay as-is.
class RankingRemoteDataSourceImpl implements RankingRemoteDataSource {
  RankingRemoteDataSourceImpl();

  @override
  Future<List<ClubRanking>> getClubRankings(int competitionId) async =>
      const <ClubRanking>[];

  @override
  Future<List<IndividualRanking>> getIndividualRankings(
    int competitionId,
  ) async =>
      const <IndividualRanking>[];

  @override
  Future<List<RelayRanking>> getRelayRankings(int competitionId) async =>
      const <RelayRanking>[];
}
