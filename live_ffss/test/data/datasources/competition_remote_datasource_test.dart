import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';
import 'package:live_ffss/app/core/enum/enum.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/datasources/competition_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements HttpClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  late _MockHttp http;
  late CompetitionRemoteDataSource ds;

  setUp(() {
    http = _MockHttp();
    ds = CompetitionRemoteDataSourceImpl(http);
    when(() => http.get(any(), query: any(named: 'query')))
        .thenAnswer((_) async => {'data': []});
  });

  group('CompetitionRemoteDataSourceImpl.getCompetitions', () {
    test('without endDate omits "fin" from the query map', () async {
      await ds.getCompetitions(
        season: '2025-2026',
        startDate: '2025-09-29',
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        page: 1,
        pageSize: 10,
      );

      final captured = verify(() => http.get(
            ApiEndpoints.competitionList,
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['debut'], '2025-09-29');
      expect(captured.containsKey('fin'), isFalse);
    });

    test('with endDate sends "fin" in the query map', () async {
      await ds.getCompetitions(
        season: '2025-2026',
        startDate: '2026-04-27',
        endDate: '2026-05-03',
        type: CompetitionType.mixte,
        visibility: CompetitionVisibility.passed,
        page: 1,
        pageSize: 10,
      );

      final captured = verify(() => http.get(
            ApiEndpoints.competitionList,
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;

      expect(captured['debut'], '2026-04-27');
      expect(captured['fin'], '2026-05-03');
    });
  });
}
