import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/competition_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

Map<String, dynamic> row(int id, {String start = '2026-10-20'}) => {
  'Id': id,
  'Nom': 'Compétition $id',
  'Debut': start,
  'Specialite': 2,
};

void main() {
  late _MockHttpClient http;
  late CompetitionRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = CompetitionRepositoryImpl(http);
  });

  void answerPages(List<List<Object?>> pages) {
    var call = 0;
    when(
      () => http.get(any(), query: any(named: 'query')),
    ).thenAnswer((_) async => {'data': pages[call++]});
  }

  group('getCompetitionsFrom', () {
    test(
      'envoie debut, le type 3 (toutes spécialités) et la fenêtre',
      () async {
        answerPages([
          [row(1)],
        ]);

        await repository.getCompetitionsFrom(DateTime(2026, 10, 3));

        final query =
            verify(
                  () => http.get(
                    'competition/evenement',
                    query: captureAny(named: 'query'),
                  ),
                ).captured.single
                as Map<String, dynamic>;
        expect(query, {
          'debut': '2026-10-03',
          'type': 3,
          'start': 0,
          'length': CompetitionRepositoryImpl.pageSize,
        });
      },
    );

    test('lit la page suivante tant qu\'une page est pleine', () async {
      final full = [
        for (var i = 0; i < CompetitionRepositoryImpl.pageSize; i++) row(i),
      ];
      answerPages([
        full,
        [row(1000)],
      ]);

      final result = await repository.getCompetitionsFrom(
        DateTime(2026, 10, 3),
      );

      expect(result.length, CompetitionRepositoryImpl.pageSize + 1);
      final starts = verify(
        () => http.get(any(), query: captureAny(named: 'query')),
      ).captured.map((q) => (q as Map<String, dynamic>)['start']).toList();
      expect(starts, [0, CompetitionRepositoryImpl.pageSize]);
    });

    test(
      'une entrée non-objet dans une page pleine ne la fait pas passer pour la dernière',
      () async {
        final full = <Object?>[
          'x',
          for (var i = 1; i < CompetitionRepositoryImpl.pageSize; i++) row(i),
        ];
        answerPages([
          full,
          [row(1000)],
        ]);

        final result = await repository.getCompetitionsFrom(
          DateTime(2026, 10, 3),
        );

        expect(result.length, CompetitionRepositoryImpl.pageSize);
        verify(() => http.get(any(), query: any(named: 'query'))).called(2);
      },
    );

    test(
      'compte les lignes brutes, pas les lignes retenues, pour paginer',
      () async {
        // Une page pleine dont une ligne est écartée par le mapper reste pleine :
        // s'arrêter là perdrait la page suivante.
        final full = [
          {'Id': null},
          for (var i = 1; i < CompetitionRepositoryImpl.pageSize; i++) row(i),
        ];
        answerPages([full, <Map<String, dynamic>>[]]);

        final result = await repository.getCompetitionsFrom(
          DateTime(2026, 10, 3),
        );

        expect(result.length, CompetitionRepositoryImpl.pageSize - 1);
        verify(() => http.get(any(), query: any(named: 'query'))).called(2);
      },
    );

    test(
      'une ligne au mauvais type est écartée seule, les autres restent',
      () async {
        answerPages([
          [
            row(1),
            {'Id': 2, 'Nom': 123, 'Debut': '2026-10-20'},
            row(3),
          ],
        ]);

        final result = await repository.getCompetitionsFrom(
          DateTime(2026, 10, 3),
        );

        expect([for (final c in result) c.id], [1, 3]);
      },
    );

    test('data absent : liste vide', () async {
      when(
        () => http.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      expect(
        await repository.getCompetitionsFrom(DateTime(2026, 10, 3)),
        isEmpty,
      );
    });

    test('une erreur réseau remonte telle quelle', () async {
      when(
        () => http.get(any(), query: any(named: 'query')),
      ).thenThrow(const NetworkException('offline'));

      expect(
        () => repository.getCompetitionsFrom(DateTime(2026, 10, 3)),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('search', () {
    test('envoie la recherche nettoyée, sans date, une seule page', () async {
      answerPages([
        [row(1)],
      ]);

      await repository.search('  girard ');

      final query =
          verify(
                () => http.get(
                  'competition/evenement',
                  query: captureAny(named: 'query'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(query, {
        'search': 'girard',
        'type': 3,
        'start': 0,
        'length': CompetitionRepositoryImpl.searchLimit,
      });
    });

    test('trie de la plus récente à la plus ancienne', () async {
      answerPages([
        [row(1, start: '2025-05-01'), row(2, start: '2026-03-27')],
      ]);

      final result = await repository.search('france');

      expect([for (final c in result) c.id], [2, 1]);
    });

    test('une recherche vide n\'appelle pas l\'API', () async {
      expect(await repository.search('   '), isEmpty);
      verifyNever(() => http.get(any(), query: any(named: 'query')));
    });
  });
}
