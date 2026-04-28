import 'package:live_ffss/app/data/datasources/result_remote_datasource.dart';
import 'package:live_ffss/app/data/mappers/live_result_mapper.dart';
import 'package:live_ffss/app/domain/models/live_result.dart';

abstract class ResultRepository {
  Future<List<LiveResult>> getRunResults(int runId);
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings);
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times);
  Future<bool> withdrawAthlete({required int athleteId, required int runId});
}

class ResultRepositoryImpl implements ResultRepository {
  ResultRepositoryImpl(this._dataSource);
  final ResultRemoteDataSource _dataSource;

  @override
  Future<List<LiveResult>> getRunResults(int runId) async {
    // TODO(post-batch-6): wire to FFSS backend once endpoint is documented.
    // Legacy code called _apiService.getRunResults() which never existed.
    final dtos = await _dataSource.getRunResults(runId);
    return dtos.map((d) => d.toDomain()).toList();
  }

  @override
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings) async =>
      _dataSource.updateBeachRankings(runId, rankings);

  @override
  Future<bool> updateSwimmingTimes(
          int runId, Map<int, List<String>> times) async =>
      _dataSource.updateSwimmingTimes(runId, times);

  @override
  Future<bool> withdrawAthlete(
          {required int athleteId, required int runId}) async =>
      _dataSource.withdrawAthlete(athleteId: athleteId, runId: runId);
}
