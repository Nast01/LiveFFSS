import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/result_repository.dart';
import 'package:live_ffss_v2/domain/race_result.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late ResultRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = ResultRepositoryImpl(http);
  });

  const result = RaceResult(
    id: 572548,
    seriesId: 94894,
    entryId: 566311,
    time: 17577,
    chronos: [17500, null, 17600],
    rank: 3,
    status: 1,
    complement: '12',
    points: 8,
  );

  Map<String, dynamic> submitted() =>
      verify(
            () => http.post(
              'competition/resultat/submit',
              query: captureAny(named: 'query'),
            ),
          ).captured.single
          as Map<String, dynamic>;

  test('submit envoie tous les champs dans l\'adresse, sans corps', () async {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'success': true, 'id': 572548});

    final id = await repository.submit(result);

    expect(id, 572548);
    expect(submitted(), {
      'id': 572548,
      'serie': 94894,
      'engagement': 566311,
      'temps': 17577,
      'tempsLive1': '17500',
      'tempsLive2': '',
      'tempsLive3': '17600',
      'rang': 3,
      'statut': 1,
      'complement': '12',
      'points': 8,
    });
    verifyNever(
      () => http.post(
        any(),
        query: any(named: 'query'),
        body: any(named: 'body'),
      ),
    );
  });

  test('une création n\'envoie pas d\'id', () async {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'success': true, 'id': 9});

    final id = await repository.submit(
      const RaceResult(seriesId: 1, entryId: 2),
    );

    expect(id, 9);
    final query = submitted();
    expect(query.containsKey('id'), false);
    expect(query.containsKey('temps'), false);
    expect(query.containsKey('rang'), false);
    expect(query.containsKey('points'), false);
    expect(query['tempsLive1'], '');
    expect(query['statut'], 0);
  });

  test('un refus de HttpClient remonte tel quel', () async {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenThrow(const ApiException('refusé'));

    expect(
      repository.submit(result),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', 'refusé'),
      ),
    );
  });

  test('une réponse sans id lève ApiException', () async {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'success': true});

    expect(repository.submit(result), throwsA(isA<ApiException>()));
  });

  test('un résultat à chronos hors de trois entrées part complet', () async {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'success': true, 'id': 1});

    await repository.submit(result.copyWith(chronos: [5]));

    final query = submitted();
    expect(query['tempsLive1'], '5');
    expect(query['tempsLive2'], '');
    expect(query['tempsLive3'], '');
  });

  test(
    'temps, rang et points nuls sont omis, le statut toujours envoyé',
    () async {
      when(
        () => http.post(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => {'success': true, 'id': 1});

      await repository.submit(
        result.copyWith(time: null, rank: null, points: null, status: 0),
      );

      final query = submitted();
      expect(query.containsKey('temps'), false);
      expect(query.containsKey('rang'), false);
      expect(query.containsKey('points'), false);
      expect(query['statut'], 0);
    },
  );

  Map<String, dynamic> data(Map<String, dynamic> extra) => {
    'data': {
      'Id': 1,
      'Statut': 0,
      'engagement': {'Id': 2},
      'serie': {'Id': 3},
      ...extra,
    },
  };

  for (final bad in <String, Object>{
    'Temps': '17577.0',
    'Rang': 'abc',
    'points': 8.5,
  }.entries) {
    test('getResult rend null si ${bad.key} est illisible', () async {
      when(
        () => http.get(any()),
      ).thenAnswer((_) async => data({bad.key: bad.value}));

      expect(await repository.getResult(1), isNull);
    });
  }

  test('Temps, Rang et points absents restent nuls', () async {
    when(() => http.get(any())).thenAnswer((_) async => data({'Temps': null}));

    final r = await repository.getResult(1);

    expect(r!.time, isNull);
    expect(r.rank, isNull);
    expect(r.points, isNull);
    expect(isValidatedByJudge(r), false);
  });

  test('complement : chaîne ou entier exact, le reste est vide', () async {
    Future<String> read(Object? value) async {
      when(
        () => http.get(any()),
      ).thenAnswer((_) async => data({'complement': value}));
      return (await repository.getResult(1))!.complement;
    }

    expect(await read('12'), '12');
    expect(await read(12), '12');
    expect(await read(12.0), '12');
    expect(await read(12.5), '');
    expect(await read(<Object?>[]), '');
    expect(await read(false), '');
    expect(await read(<String, Object?>{'a': 1}), '');
    expect(await read(null), '');
  });

  test('getHeatChronos reste tolérant là où getResult refuse', () async {
    final row = {
      'Id': 1,
      'Statut': 0,
      'Temps': 'abc',
      'TempsLive1': 100,
      'engagement': {'Id': 11},
      'serie': {'Id': 3},
    };
    when(() => http.get(any())).thenAnswer(
      (_) async => {
        'data': {
          'resultats': [row],
          ...row,
        },
      },
    );

    expect(await repository.getHeatChronos(3), {
      11: [100, null, null],
    });
    expect(await repository.getResult(1), isNull);
  });

  test('getResult lit les champs et lit 0 comme pas de chrono', () async {
    when(() => http.get(any())).thenAnswer(
      (_) async => {
        'data': {
          'id': 572548,
          'Id': 572548,
          'Temps': '17577',
          'TempsLive1': 17500,
          'TempsLive2': 0,
          'TempsLive3': '17600',
          'Rang': 3,
          'Statut': 1,
          'complement': '12',
          'points': 8,
          'engagement': {'id': 566311, 'Id': 566311},
          'serie': {'Id': 94894},
        },
      },
    );

    final r = await repository.getResult(572548);

    verify(() => http.get('competition/resultat/572548')).called(1);
    expect(r, result);
  });

  test('getResult rend null sans statut', () async {
    when(() => http.get(any())).thenAnswer(
      (_) async => {
        'data': {
          'Id': 1,
          'engagement': {'Id': 2},
          'serie': {'Id': 3},
        },
      },
    );

    expect(await repository.getResult(1), isNull);
  });

  test(
    'getHeatChronos : chronos par engagement, lignes illisibles écartées',
    () async {
      when(() => http.get(any())).thenAnswer(
        (_) async => {
          'data': {
            'resultats': [
              {
                'Id': 1,
                'TempsLive1': 100,
                'TempsLive2': 0,
                'TempsLive3': 300,
                'engagement': {'Id': 11},
              },
              {'Id': 2, 'engagement': []},
              'x',
              {
                'Id': 3,
                'Temps': 'abc',
                'TempsLive1': {},
                'engagement': {'Id': 13},
              },
            ],
          },
        },
      );

      final chronos = await repository.getHeatChronos(94894);

      verify(() => http.get('competition/serie/94894')).called(1);
      expect(chronos, {
        11: [100, null, 300],
      });
    },
  );
}
