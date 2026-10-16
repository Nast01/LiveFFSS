import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

Map<String, dynamic> reunion(
  int id, {
  String day = '2026-03-27',
  String start = '06:45',
}) => {
  'Id': id,
  'Nom': 'Réunion $id',
  'Jour': day,
  'Debut': start,
  'Fin': '11:30',
  'creneaus': [
    {
      'id': id * 10,
      'Nom': 'Créneau',
      'courses': [
        {
          'id': id * 100,
          'Nom': 'Série 1',
          'statut': 2,
          'debut': '06:54',
          'fin': '06:58',
        },
      ],
    },
  ],
};

void main() {
  late _MockHttpClient http;
  late MeetingRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = MeetingRepositoryImpl(http);
  });

  test(
    'appelle la route des réunions de la compétition, avec une fenêtre',
    () async {
      when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => {
          'data': [reunion(1)],
        },
      );

      await repository.getMeetings(1453);

      final query =
          verify(
                () => http.get(
                  'competition/1453/reunion',
                  query: captureAny(named: 'query'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(query, {'start': 0, 'length': MeetingRepositoryImpl.pageSize});
    },
  );

  test(
    'lit les courses portées par la réponse, sans appel par créneau',
    () async {
      when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => {
          'data': [reunion(1)],
        },
      );

      final meetings = await repository.getMeetings(1453);

      expect(meetings.single.items.single.heats.single.id, 100);
      verify(() => http.get(any(), query: any(named: 'query'))).called(1);
    },
  );

  test('pagine les réunions et les trie par jour puis par heure', () async {
    final full = [
      for (var i = 1; i <= MeetingRepositoryImpl.pageSize; i++)
        reunion(i, day: '2026-03-28'),
    ];
    var call = 0;
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer((
      _,
    ) async {
      call++;
      return {
        'data': call == 1
            ? full
            : [
                reunion(999, day: '2026-03-27', start: '13:55'),
                reunion(998, day: '2026-03-27'),
              ],
      };
    });

    final meetings = await repository.getMeetings(1453);

    expect(meetings.length, MeetingRepositoryImpl.pageSize + 2);
    expect(meetings.first.id, 998);
    expect(meetings[1].id, 999);
  });

  test(
    'une entrée non-objet ne fait pas passer une page pleine pour la dernière',
    () async {
      final full = <Object?>[
        'corrompue',
        for (var i = 2; i <= MeetingRepositoryImpl.pageSize; i++) reunion(i),
      ];
      var call = 0;
      when(() => http.get(any(), query: any(named: 'query'))).thenAnswer((
        _,
      ) async {
        call++;
        return {
          'data': call == 1 ? full : [reunion(999)],
        };
      });

      final meetings = await repository.getMeetings(1453);

      expect(call, 2);
      expect(meetings.any((m) => m.id == 999), isTrue);
    },
  );

  test('une réunion illisible est écartée, les autres restent', () async {
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => {
        'data': [
          {...reunion(1), 'Jour': null},
          reunion(2),
        ],
      },
    );

    final meetings = await repository.getMeetings(1453);

    expect([for (final m in meetings) m.id], [2]);
  });

  test('une réunion au mauvais type est écartée seule', () async {
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => {
        'data': [
          {...reunion(1), 'Nom': 123},
          reunion(2),
        ],
      },
    );

    final meetings = await repository.getMeetings(1453);

    expect([for (final m in meetings) m.id], [2]);
  });
}
