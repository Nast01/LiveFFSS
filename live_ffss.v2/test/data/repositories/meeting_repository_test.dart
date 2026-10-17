import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/meeting_repository.dart';
import 'package:live_ffss_v2/domain/gender.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

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

  /// Réponses par route : les réunions et les déroulements passent par deux
  /// listes paginées distinctes, que les tests comptent chacune.
  void stub({
    required Map<String, dynamic> Function(int call) reunions,
    Map<String, dynamic> Function(int call)? deroulements,
  }) {
    var reunionCalls = 0;
    var deroulementCalls = 0;
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer((
      invocation,
    ) async {
      final path = invocation.positionalArguments.first as String;
      if (path.endsWith('/deroulement')) {
        deroulementCalls++;
        return deroulements?.call(deroulementCalls) ??
            <String, dynamic>{'data': <Object?>[]};
      }
      reunionCalls++;
      return reunions(reunionCalls);
    });
  }

  Map<String, dynamic> one(Object? row) => {
    'data': [row],
  };

  setUp(() {
    http = _MockHttpClient();
    repository = MeetingRepositoryImpl(http);
  });

  test(
    'appelle la route des réunions de la compétition, avec une fenêtre',
    () async {
      stub(reunions: (_) => one(reunion(1)));

      await repository.getProgramme(1453);

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

  test('getProgramme lit réunions et déroulements de la compétition', () async {
    final deroulements = fixture('deroulement');
    stub(
      reunions: (_) => one({
        ...reunion(1416),
        'creneaus': [
          {
            'id': 10,
            'Nom': 'Créneau',
            'partie': {'id': 142},
            'courses': [
              {'id': 100, 'Nom': 'Série 1', 'statut': 2},
            ],
          },
        ],
      }),
      deroulements: (_) => deroulements,
    );

    final programme = await repository.getProgramme(1416);

    verify(
      () => http.get('competition/1416/reunion', query: any(named: 'query')),
    ).called(1);
    verify(
      () =>
          http.get('competition/1416/deroulement', query: any(named: 'query')),
    ).called(1);
    expect(programme.progressionOfStage(142)?.id, 501);
    final heat = programme.meetings.single.items.single.heats.single;
    expect(heat.raceName, '200m Obstacles');
    expect(heat.gender, Gender.female);
    expect(heat.raceId, 501);
  });

  test('déroulements en échec (AppException) : programme sans épreuves, '
      'pas d\'erreur', () async {
    when(() => http.get(any(), query: any(named: 'query'))).thenAnswer((
      invocation,
    ) async {
      final path = invocation.positionalArguments.first as String;
      if (path.endsWith('/deroulement')) {
        throw const NetworkException('hors ligne');
      }
      return one(reunion(1));
    });

    final programme = await repository.getProgramme(1453);

    expect(programme.progressions, isEmpty);
    expect(programme.meetings.single.id, 1);
  });

  test('déroulements vides : programme sans épreuves', () async {
    stub(reunions: (_) => one(reunion(1)));

    final programme = await repository.getProgramme(1453);

    expect(programme.progressions, isEmpty);
    expect(programme.meetings.single.items.single.heats.single.raceName, '');
  });

  test('un déroulement au mauvais type est écarté seul', () async {
    stub(
      reunions: (_) => one(reunion(1)),
      deroulements: (_) {
        final rows = fixture('deroulement')['data'] as List<dynamic>;
        return {
          'data': [
            {
              ...(rows.first as Map<String, dynamic>),
              'parties': ['corrompue'],
            },
            rows.last,
          ],
        };
      },
    );

    final programme = await repository.getProgramme(1453);

    expect(programme.progressions, isNotEmpty);
    expect(programme.progressions.any((p) => p.id == 501), isFalse);
  });

  test(
    'lit les courses portées par la réponse, sans appel par créneau',
    () async {
      stub(reunions: (_) => one(reunion(1)));

      final meetings = (await repository.getProgramme(1453)).meetings;

      expect(meetings.single.items.single.heats.single.id, 100);
      verify(
        () => http.get('competition/1453/reunion', query: any(named: 'query')),
      ).called(1);
      verify(
        () => http.get(
          'competition/1453/deroulement',
          query: any(named: 'query'),
        ),
      ).called(1);
    },
  );

  test('pagine les réunions et les trie par jour puis par heure', () async {
    final full = [
      for (var i = 1; i <= MeetingRepositoryImpl.pageSize; i++)
        reunion(i, day: '2026-03-28'),
    ];
    stub(
      reunions: (call) => {
        'data': call == 1
            ? full
            : [
                reunion(999, day: '2026-03-27', start: '13:55'),
                reunion(998, day: '2026-03-27'),
              ],
      },
    );

    final meetings = (await repository.getProgramme(1453)).meetings;

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
      var reunionCalls = 0;
      stub(
        reunions: (call) {
          reunionCalls = call;
          return {
            'data': call == 1 ? full : [reunion(999)],
          };
        },
      );

      final meetings = (await repository.getProgramme(1453)).meetings;

      expect(reunionCalls, 2);
      expect(meetings.any((m) => m.id == 999), isTrue);
    },
  );

  test('une réunion illisible est écartée, les autres restent', () async {
    stub(
      reunions: (_) => {
        'data': [
          {...reunion(1), 'Jour': null},
          reunion(2),
        ],
      },
    );

    final meetings = (await repository.getProgramme(1453)).meetings;

    expect([for (final m in meetings) m.id], [2]);
  });

  test('une réunion au mauvais type est écartée seule', () async {
    stub(
      reunions: (_) => {
        'data': [
          {...reunion(1), 'Nom': 123},
          reunion(2),
        ],
      },
    );

    final meetings = (await repository.getProgramme(1453)).meetings;

    expect([for (final m in meetings) m.id], [2]);
  });

  test('un serveur qui ignore start ne fait pas boucler : pages bornées, '
      'sans doublon', () async {
    final page = [
      for (var i = 1; i <= MeetingRepositoryImpl.pageSize; i++) reunion(i),
    ];
    stub(reunions: (_) => {'data': page});

    final meetings = (await repository.getProgramme(1453)).meetings;

    verify(
      () => http.get('competition/1453/reunion', query: any(named: 'query')),
    ).called(MeetingRepositoryImpl.maxPages);
    final ids = [for (final m in meetings) m.id];
    expect(ids.toSet().length, ids.length);
    expect(ids.length, MeetingRepositoryImpl.pageSize);
  });
}
