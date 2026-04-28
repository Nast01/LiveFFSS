import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/result_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/result_repository.dart';

void main() {
  late ResultRepository repo;

  setUp(() {
    repo = ResultRepositoryImpl(ResultRemoteDataSourceImpl());
  });

  test('getRunResults throws UnimplementedError', () {
    expect(repo.getRunResults(1), throwsA(isA<UnimplementedError>()));
  });

  test('updateBeachRankings throws UnimplementedError', () {
    expect(repo.updateBeachRankings(1, {}),
        throwsA(isA<UnimplementedError>()));
  });

  test('updateSwimmingTimes throws UnimplementedError', () {
    expect(repo.updateSwimmingTimes(1, {}),
        throwsA(isA<UnimplementedError>()));
  });

  test('withdrawAthlete throws UnimplementedError', () {
    expect(repo.withdrawAthlete(athleteId: 1, runId: 1),
        throwsA(isA<UnimplementedError>()));
  });
}
