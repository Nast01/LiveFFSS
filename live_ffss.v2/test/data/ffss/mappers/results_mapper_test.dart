import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/participant_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/serie_results_dto.dart';
import 'package:live_ffss_v2/data/ffss/mappers/results_mapper.dart';
import 'package:live_ffss_v2/domain/event_results.dart';
import 'package:live_ffss_v2/domain/gender.dart';

import '../../../support/fixtures.dart';

List<Map<String, dynamic>> rows(String name) =>
    (fixture(name)['data'] as List<dynamic>).cast<Map<String, dynamic>>();

List<EventSeries> seriesOf(String name) => [
  for (final row in rows(name)) ?SerieResultsDto.fromJson(row).toDomain(),
];

void main() {
  group('épreuves', () {
    final events = [
      for (final row in rows('epreuves_1416'))
        ?EpreuveDto.fromJson(row).toDomain(),
    ];

    test('60 épreuves, une par catégorie', () {
      expect(events, hasLength(60));
    });

    test('le 200 m obstacles Femme Cadet', () {
      final event = events.firstWhere((e) => e.id == 36073);
      expect(event.disciplineId, 24);
      expect(event.disciplineName, '200m Obstacles');
      expect(event.gender, Gender.female);
      expect(event.categoryName, 'Cadet');
      expect(event.teamSize, 1);
      expect(event.isRelay, isFalse);
    });

    test('le relais 4 x 50 m est un relais', () {
      expect(events.firstWhere((e) => e.id == 36087).isRelay, isTrue);
    });

    test('une épreuve sans catégorie ou sans genre est écartée', () {
      expect(const EpreuveDto(id: 1, gender: 'F').toDomain(), isNull);
      expect(
        const EpreuveDto(
          id: 1,
          categories: [EpreuveCategorieDto(id: 2, name: 'Cadet')],
        ).toDomain(),
        isNull,
      );
    });
  });

  group('séries', () {
    test('le 200 m obstacles Femme Cadet : 22 séries', () {
      final series = seriesOf('serie_epreuve_36073');
      expect(series, hasLength(22));
      final first = series.firstWhere((s) => s.id == 94894);
      expect(first.number, 1);
      expect(first.eventId, 36073);
      expect(first.start, DateTime(2026, 3, 27, 8));
      expect(first.results, hasLength(5));
      final result = first.results.first;
      expect(result.time, 16330);
      expect(result.status, 0);
      expect(result.categoryName, 'Cadet');
      expect(result.complement, '');
      expect(result.club, result.athletes.first.club);
    });

    test('une série qui ne démarre pas n\'a pas d\'heure', () {
      final series = seriesOf('serie_epreuve_36073');
      expect(series.firstWhere((s) => s.id == 91065).start, isNull);
    });

    test('un relais : quatre athlètes par résultat', () {
      final results = [
        for (final s in seriesOf('serie_epreuve_36087')) ...s.results,
      ];
      expect(results, isNotEmpty);
      expect(results.first.athletes, hasLength(4));
    });

    test('un résultat sans engagement ou sans id est écarté', () {
      const noEntry = ResultatSerieDto(id: 1);
      const noId = ResultatSerieDto(entry: EngagementResultDto(id: 2));
      expect(noEntry.toDomain(5), isNull);
      expect(noId.toDomain(5), isNull);
    });

    test(
      'un temps nul ou négatif devient nul ; l\'épreuve vient de la série',
      () {
        const dto = ResultatSerieDto(
          id: 1,
          time: 0,
          entry: EngagementResultDto(id: 2, club: ' Club '),
        );
        final result = dto.toDomain(5)!;
        expect(result.time, isNull);
        expect(result.eventId, 5);
        expect(result.club, 'Club');
      },
    );
  });

  group('participants', () {
    final participants = [
      for (final row in rows('participants_1416'))
        ?ParticipantDto.fromJson(row).toDomain(),
    ];

    test('19 participants avec leurs engagements', () {
      expect(participants, hasLength(19));
      final first = participants.first;
      expect(first.entries, isNotEmpty);
      expect(first.entries.first.eventId, 36087);
      expect(first.entries.first.categoryName, 'Open');
      expect(first.gender, Gender.male);
      expect(first.isGuest, isFalse);
    });
  });

  group('lignes illisibles et cas limites', () {
    Map<String, dynamic> result(int id, {Object? athletes, int statut = 0}) => {
      'Id': id,
      'Statut': statut,
      'Temps': 1000,
      'complement': 'Q',
      'Athletes': athletes ?? <Object?>[],
      'engagement': {'Id': id + 100, 'IdEpreuve': 5, 'clubLabel': 'Club E'},
    };

    test(
      'le club vide du premier athlète retombe sur celui de l\'engagement',
      () {
        final dto = ResultatSerieDto.fromJson(
          result(
            1,
            athletes: [
              {'Id': 9, 'label': 'A', 'clubLabel': ''},
            ],
          ),
        );
        expect(dto.toDomain(5)!.club, 'Club E');
      },
    );

    test('un résultat mal typé est écarté seul', () {
      final series = SerieResultsDto.fromJson({
        'Id': 1,
        'epreuve': {'Id': 5},
        'resultats': [
          result(1),
          {'Id': 2, 'Statut': 'x', 'Temps': {}},
          'pas un objet',
          result(3),
        ],
      }).toDomain()!;
      expect(series.results.map((r) => r.id), [1, 3]);
    });

    test('un athlète mal typé est écarté seul', () {
      final series = SerieResultsDto.fromJson({
        'Id': 1,
        'epreuve': {'Id': 5},
        'resultats': [
          result(
            1,
            athletes: [
              {'Id': 9, 'label': 123},
              {'Id': 10, 'label': 'B'},
            ],
          ),
        ],
      }).toDomain()!;
      expect(series.results.single.athletes.map((a) => a.id), [10]);
    });

    test('un engagement mal typé est écarté seul', () {
      final participant = ParticipantDto.fromJson({
        'Id': 1,
        'engagements': [
          {
            'id': 1,
            'epreuve': {'Id': 7, 'categories': 'x'},
          },
          {
            'id': 2,
            'epreuve': {'Id': 7},
          },
        ],
      }).toDomain()!;
      expect(participant.entries.map((e) => e.entryId), [2]);
    });

    test('statut, complément et invité sont lus', () {
      final r = ResultatSerieDto.fromJson(
        result(
          1,
          statut: 3,
          athletes: [
            {'Id': 9, 'label': 'A', 'isInvite': true},
          ],
        ),
      ).toDomain(5)!;
      expect(r.status, 3);
      expect(r.complement, 'Q');
      expect(r.athletes.single.isGuest, isTrue);
    });

    test('une heure de début illisible laisse la série sans heure', () {
      final series = SerieResultsDto.fromJson({
        'Id': 1,
        'Debut': 'pas une date',
        'epreuve': {'Id': 5},
      }).toDomain()!;
      expect(series.start, isNull);
    });

    test('une épreuve sans discipline est écartée', () {
      expect(
        const EpreuveDto(
          id: 1,
          gender: 'F',
          categories: [EpreuveCategorieDto(id: 2, name: 'Cadet')],
        ).toDomain(),
        isNull,
      );
    });
  });
}
