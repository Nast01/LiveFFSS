import 'package:live_ffss/app/data/dtos/live_result_dto.dart';

abstract class ResultRemoteDataSource {
  Future<List<LiveResultDto>> getRunResults(int runId);
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings);
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times);
  Future<bool> withdrawAthlete({required int athleteId, required int runId});
}

class ResultRemoteDataSourceImpl implements ResultRemoteDataSource {
  ResultRemoteDataSourceImpl();

  @override
  Future<List<LiveResultDto>> getRunResults(int runId) {
    throw UnimplementedError(
      'getRunResults: backend endpoint not documented. '
      'Legacy SlotController._loadRunResultsFromApi was a TODO stub. '
      'Wire when FFSS API surface is clarified.',
    );
  }

  @override
  Future<bool> updateBeachRankings(int runId, Map<int, int> rankings) {
    throw UnimplementedError('updateBeachRankings: backend endpoint TBD');
  }

  @override
  Future<bool> updateSwimmingTimes(int runId, Map<int, List<String>> times) {
    throw UnimplementedError('updateSwimmingTimes: backend endpoint TBD');
  }

  @override
  Future<bool> withdrawAthlete({required int athleteId, required int runId}) {
    throw UnimplementedError('withdrawAthlete: backend endpoint TBD');
  }
}
