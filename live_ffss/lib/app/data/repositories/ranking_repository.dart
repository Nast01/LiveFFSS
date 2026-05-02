import 'package:live_ffss/app/data/datasources/ranking_remote_datasource.dart';
import 'package:live_ffss/app/domain/models/club_ranking.dart';
import 'package:live_ffss/app/domain/models/individual_ranking.dart';
import 'package:live_ffss/app/domain/models/relay_ranking.dart';

abstract class RankingRepository {
  Future<List<ClubRanking>> getClubRankings(int competitionId);
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId);
  Future<List<RelayRanking>> getRelayRankings(int competitionId);
}

/// Temporary passthrough: returns domain types directly because
/// [RankingRemoteDataSource] is a stub returning empty domain lists.
///
/// When the FFSS backend lands, the data source will return DTOs;
/// add `lib/app/data/mappers/ranking_*_mapper.dart` and map here
/// before returning. See CLAUDE.md "Known gaps".
class RankingRepositoryImpl implements RankingRepository {
  RankingRepositoryImpl(this._dataSource);

  final RankingRemoteDataSource _dataSource;

  @override
  Future<List<ClubRanking>> getClubRankings(int competitionId) =>
      _dataSource.getClubRankings(competitionId);

  @override
  Future<List<IndividualRanking>> getIndividualRankings(int competitionId) =>
      _dataSource.getIndividualRankings(competitionId);

  @override
  Future<List<RelayRanking>> getRelayRankings(int competitionId) =>
      _dataSource.getRelayRankings(competitionId);
}
