import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/datasources/race_format_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements HttpClient {}

void main() {
  late _MockHttp http;
  late RaceFormatRemoteDataSource ds;

  setUp(() {
    http = _MockHttp();
    ds = RaceFormatRemoteDataSourceImpl(http);
  });

  group('getRaceFormats', () {
    // FFSS serves this list 30 rows at a time when no window is asked for.
    // Reading only the first page made every déroulement past the thirtieth
    // look absent from the app while it sat plainly on the federal site.
    test('asks for the window it was given', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': <dynamic>[]});

      await ds.getRaceFormats(1451, start: 30, length: 30);

      verify(() => http.get('competition/1451/deroulement',
          query: {'start': 30, 'length': 30})).called(1);
    });

    test('hits competition/<id>/deroulement and decodes the payload', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'success': true,
                'data': [
                  {
                    'Id': 365,
                    'IdEvenement': 1337,
                    'IdDiscipline': 13,
                    'Genre': 'F',
                    'label': 'Paddle Board - Femme',
                    'fullLabel': 'Paddle Board - Femme - Minime',
                    'genreLabel': 'Femme',
                    'Discipline': {
                      'Id': 13,
                      'Nom': 'Paddle Board',
                      'specialite': 1,
                      'specialiteLabel': 'Côtier',
                    },
                    'categories': [
                      {
                        'Id': 821,
                        'IdCategorie': 10,
                        'categorie': {
                          'Id': 10,
                          'Nom': 'Minime',
                          'AgeMin': 13,
                          'AgeMax': 14,
                        },
                      },
                    ],
                    'parties': [
                      {
                        'id': 32,
                        'ordre': 1,
                        'label': 'Demi-finale - Minime',
                        'fullLabel': 'PB - F - Demi-finale - Minime',
                        'niveauLabel': 'Demi-finale',
                        'niveau': 'semi',
                        'nbCourses': 2,
                        'logiqueQualification': 'none',
                        'logiqueQualificationLabel': 'N/A',
                        'nbPlaceParCourse': 18,
                        'nbPlaceQualificative': 0,
                      },
                      {
                        'id': 33,
                        'ordre': 2,
                        'label': 'Finale - Minime',
                        'fullLabel': 'PB - F - Finale - Minime',
                        'niveauLabel': 'Finale',
                        'niveau': 'final',
                        'nbCourses': 1,
                        'logiqueQualification': 'course',
                        'logiqueQualificationLabel': 'Par course',
                        'nbPlaceParCourse': 16,
                        'nbPlaceQualificative': 8,
                      },
                    ],
                  },
                ],
              });

      final list = await ds.getRaceFormats(1337, start: 0, length: 100);

      verify(() => http.get('competition/1337/deroulement',
          query: {'start': 0, 'length': 100})).called(1);
      final dto = list.single;
      expect(dto.id, 365);
      expect(dto.competitionId, 1337);
      expect(dto.disciplineId, 13);
      expect(dto.gender, 'F');
      // The real category id lives under `categorie`, not on the join row.
      expect(dto.categories.single.id, 10);
      expect(dto.details.map((d) => d.level), ['semi', 'final']);
      expect(dto.details.map((d) => d.spotsPerRace), [18, 16]);
      expect(dto.details.map((d) => d.numberOfRun), [2, 1]);
      expect(dto.details.last.qualifyingSpots, 8);
    });

    test('an empty data array yields an empty list', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': []});

      expect(await ds.getRaceFormats(1337, start: 0, length: 100), isEmpty);
    });
  });

  group('submitRaceFormat', () {
    test('sends an empty id and PHP array notation for the categories',
        () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 366});

      final id = await ds.submitRaceFormat(
        competitionId: 1337,
        disciplineId: 8,
        gender: 'H',
        categoryIds: [10, 24],
      );

      expect(id, 366);
      final captured = verify(() => http.post(
            'competition/1337/deroulement/submit',
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;
      expect(captured['id'], '');
      expect(captured['discipline'], 8);
      expect(captured['genre'], 'H');
      expect(captured['categories[]'], [10, 24]);
    });

    test('an existing id is sent through, which updates instead of creating',
        () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 362});

      await ds.submitRaceFormat(
        competitionId: 1337,
        disciplineId: 5,
        gender: 'H',
        categoryIds: [10],
        id: 362,
      );

      final captured = verify(() => http.post(
            any(),
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;
      expect(captured['id'], '362');
    });

    test('a failed call reports 0 rather than a bogus id', () async {
      when(() => http.post(any(), query: any(named: 'query'))).thenAnswer(
          (_) async => {'success': false, 'message': 'Discipline absente'});

      final id = await ds.submitRaceFormat(
        competitionId: 1337,
        disciplineId: 99,
        gender: 'H',
        categoryIds: [10],
      );

      expect(id, 0);
    });
  });

  group('deleteRaceFormat', () {
    test('posts to the delete route, which carries no competition', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      final ok = await ds.deleteRaceFormat(362);

      expect(ok, isTrue);
      verify(() => http.post('competition/deroulement/362/delete')).called(1);
    });

    test('reports failure when the API says so', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': false});

      expect(await ds.deleteRaceFormat(362), isFalse);
    });
  });

  group('deleteRaceFormatDetail', () {
    test('posts to the partie route, which takes the partie id', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      final ok = await ds.deleteRaceFormatDetail(32);

      expect(ok, isTrue);
      // Note the extra `partie` segment: this is not the déroulement route.
      verify(() => http.post('competition/deroulement/partie/32/delete'))
          .called(1);
    });

    test('reports failure when the API says so', () async {
      when(() => http.post(any(), query: any(named: 'query'))).thenAnswer(
          (_) async => {'success': false, 'message': 'Partie introuvable'});

      expect(await ds.deleteRaceFormatDetail(32), isFalse);
    });
  });
}
