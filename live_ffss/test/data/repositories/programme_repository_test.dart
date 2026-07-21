import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/datasources/programme_remote_datasource.dart';
import 'package:live_ffss/app/data/repositories/programme_repository.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

void main() {
  test('push is not implemented until FFSS documents the endpoints', () {
    final repo = ProgrammeRepositoryImpl(ProgrammeRemoteDataSourceImpl());
    expect(
      () => repo.push(const CompetitionProgramme(competitionId: 1)),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
