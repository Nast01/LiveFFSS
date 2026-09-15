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

  group('CompetitionRemoteDataSourceImpl.getParticipants', () {
    test('calls the event route with the id and maps the participants',
        () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'data': [
                  {'Id': 7, 'Nom': 'DUPONT', 'Dossard': '12'},
                ]
              });

      final dtos = await ds.getParticipants(42);

      verify(() => http.get('competition/evenement/42/participants',
          query: any(named: 'query'))).called(1);
      expect(dtos.single.id, 7);
      expect(dtos.single.orderNumber, 12);
    });

    test('a response without data yields an empty list', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => <String, dynamic>{});

      expect(await ds.getParticipants(42), isEmpty);
    });
  });
}
