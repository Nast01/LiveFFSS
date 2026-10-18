import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/results_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late ResultsRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = ResultsRepositoryImpl(http);
  });

  test('getEvents demande les épreuves de la compétition', () async {
    when(
      () => http.get('competition/epreuve', query: {'evenement': 1416}),
    ).thenAnswer((_) async => fixture('epreuves_1416'));

    final events = await repository.getEvents(1416);

    expect(events, hasLength(60));
  });

  test('getEventSeries demande les séries de l\'épreuve', () async {
    when(
      () => http.get('competition/serie', query: {'epreuve': 36073}),
    ).thenAnswer((_) async => fixture('serie_epreuve_36073'));

    final series = await repository.getEventSeries(36073);

    expect(series, hasLength(22));
  });

  test('getParticipants lit la route de la compétition', () async {
    when(
      () => http.get('competition/evenement/1416/participants'),
    ).thenAnswer((_) async => fixture('participants_1416'));

    final participants = await repository.getParticipants(1416);

    expect(participants, hasLength(19));
  });

  test('une ligne mal typée ou non objet est écartée seule', () async {
    when(() => http.get('competition/serie', query: {'epreuve': 7})).thenAnswer(
      (_) async => {
        'data': [
          {
            'Id': 1,
            'Numero': 1,
            'Nom': 'Série 1',
            'epreuve': {'Id': 7},
          },
          {'Id': 2, 'Nom': 123},
          'pas un objet',
          {'Id': 3, 'Numero': 3},
        ],
      },
    );

    final series = await repository.getEventSeries(7);

    expect(series.map((s) => s.id), [1, 3]);
    expect(series.last.eventId, 7);
  });

  test('un corps sans liste donne une liste vide', () async {
    when(
      () => http.get(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'data': <String, dynamic>{}});

    expect(await repository.getEvents(1), isEmpty);
  });

  test('AppException est propagée', () async {
    when(
      () => http.get(any(), query: any(named: 'query')),
    ).thenThrow(const NetworkException('hors ligne'));

    expect(repository.getEvents(1), throwsA(isA<AppException>()));
  });
}
