import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/network/http_client.dart';
import 'package:live_ffss/app/data/datasources/meeting_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttp extends Mock implements HttpClient {}

void main() {
  late _MockHttp http;
  late MeetingRemoteDataSource ds;

  setUp(() {
    http = _MockHttp();
    ds = MeetingRemoteDataSourceImpl(http);
  });

  group('getMeetings', () {
    // FFSS serves this list 30 rows at a time when no window is asked for.
    // Reading only the first page made every réunion past the thirtieth
    // look absent from the app while it sat plainly on the federal site.
    test('demande la fenêtre qu on lui donne', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': <dynamic>[]});

      await ds.getMeetings(1451, start: 30, length: 30);

      verify(() => http.get('competition/1451/reunion',
          query: {'start': 30, 'length': 30})).called(1);
    });

    test('decode le payload en une liste de MeetingDto', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'success': true,
                'data': [
                  {
                    'Id': 12,
                    'Nom': 'Réunion 1',
                    'Description': '',
                    'Jour': '2026-05-01',
                    'Debut': '08:00',
                    'Fin': '18:00',
                  },
                ],
              });

      final list = await ds.getMeetings(1337, start: 0, length: 100);

      verify(() => http.get('competition/1337/reunion',
          query: {'start': 0, 'length': 100})).called(1);
      expect(list.single.id, 12);
      expect(list.single.name, 'Réunion 1');
    });

    test('un tableau vide donne une liste vide', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': []});

      expect(await ds.getMeetings(1337, start: 0, length: 100), isEmpty);
    });
  });

  group('getRuns', () {
    test('demande la fenêtre qu on lui donne', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': <dynamic>[]});

      await ds.getRuns(66, start: 0, length: 100);

      verify(() => http.get('competition/reunion/creneau/66/course',
          query: {'start': 0, 'length': 100})).called(1);
    });

    test('decode le payload en une liste de RunDto', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'success': true,
                'data': [
                  {
                    'id': 5,
                    'Nom': 'Série 1',
                    'label': 'S1',
                    'fullLabel': 'Série 1 - Surfski',
                    'statut': 0,
                    'statutLabel': 'En attente',
                    'site': 'Plage',
                    'debut': '08:00',
                    'fin': '08:10',
                  },
                ],
              });

      final list = await ds.getRuns(66, start: 0, length: 100);

      expect(list.single.id, 5);
      expect(list.single.name, 'Série 1');
    });

    test('un tableau vide donne une liste vide', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'data': []});

      expect(await ds.getRuns(66, start: 0, length: 100), isEmpty);
    });
  });

  group('submitMeeting', () {
    test('crée une réunion avec un id vide et rend l id assigné', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 78});

      final id = await ds.submitMeeting(
        competitionId: 1451,
        name: 'Samedi 12 septembre 2026',
        description: '',
        dayIso: '2026-09-12',
        beginTime: '08:00',
        endTime: '18:00',
      );

      expect(id, 78);
      final query = verify(() => http.post('competition/1451/reunion/submit',
          query: captureAny(named: 'query'))).captured.single;
      expect(query, {
        'id': '',
        'nom': 'Samedi 12 septembre 2026',
        'description': '',
        'jour': '2026-09-12',
        'debut': '08:00',
        'fin': '18:00',
      });
    });

    test('porte l id quand la réunion existe déjà', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 78});

      await ds.submitMeeting(
        competitionId: 1451,
        id: 78,
        name: 'Samedi 12 septembre 2026',
        description: '',
        dayIso: '2026-09-12',
        beginTime: '08:00',
        endTime: '11:20',
      );

      final query =
          verify(() => http.post(any(), query: captureAny(named: 'query')))
              .captured
              .single as Map;
      expect(query['id'], '78');
    });

    test('un refus rend 0 plutôt qu un id inventé', () async {
      when(() => http.post(any(), query: any(named: 'query'))).thenAnswer(
          (_) async => {'success': false, 'message': 'Jour invalide'});

      final id = await ds.submitMeeting(
        competitionId: 1451,
        name: 'x',
        description: '',
        dayIso: '2026-09-12',
        beginTime: '08:00',
        endTime: '18:00',
      );

      expect(id, 0);
    });
  });

  group('submitSlot', () {
    test('un item manuel part sans partie', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 66});

      final id = await ds.submitSlot(
        meetingId: 78,
        name: 'Accueil des clubs',
        beginTime: '08:00',
        endTime: '08:10',
      );

      expect(id, 66);
      final query = verify(() => http.post(
          'competition/reunion/78/creneau/submit',
          query: captureAny(named: 'query'))).captured.single;
      // An empty `partie` is what distinguishes an informational item from
      // an event's round — verified in production, the response then shows
      // partie: null.
      expect(query, {
        'id': '',
        'nom': 'Accueil des clubs',
        'debut': '08:00',
        'fin': '08:10',
        'partie': '',
      });
    });

    test('un tour d épreuve porte l id de sa partie', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 67});

      await ds.submitSlot(
        meetingId: 78,
        name: 'Séries - Surfski - Dames - Junior',
        beginTime: '08:10',
        endTime: '08:20',
        raceFormatDetailId: 39,
      );

      final query =
          verify(() => http.post(any(), query: captureAny(named: 'query')))
              .captured
              .single as Map;
      expect(query['partie'], '39');
    });

    test('un refus rend 0 plutôt qu un id inventé', () async {
      when(() => http.post(any(), query: any(named: 'query'))).thenAnswer(
          (_) async => {'success': false, 'message': 'Créneau invalide'});

      final id = await ds.submitSlot(
        meetingId: 78,
        name: 'x',
        beginTime: '08:00',
        endTime: '08:10',
      );

      expect(id, 0);
    });
  });

  group('deleteSlot', () {
    test('supprimer un créneau', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      expect(await ds.deleteSlot(66), isTrue);
      verify(() => http.post('competition/reunion/creneau/66/delete'))
          .called(1);
    });
  });

  group('submitLane', () {
    test('sends engagement verbatim', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'id': 5});

      await ds.submitLane(runId: 9, number: 3, engagement: '0');

      final query = verify(() => http.post(
            'competition/reunion/creneau/course/9/place/submit',
            query: captureAny(named: 'query'),
          )).captured.single as Map<String, dynamic>;
      expect(query['engagement'], '0');
      expect(query['numero'], '3');
      expect(query['id'], '');
    });

    test('an empty engagement stays empty — it frees the spot', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'id': 5});

      await ds.submitLane(runId: 9, number: 3, engagement: '', id: 41);

      final query =
          verify(() => http.post(any(), query: captureAny(named: 'query')))
              .captured
              .single as Map<String, dynamic>;
      expect(query['engagement'], '');
      expect(query['id'], '41');
    });
  });

  group('deleteLane', () {
    test('la suppression cible la place, pas la course', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      expect(await ds.deleteLane(6), isTrue);
      verify(() => http.post(
          'competition/reunion/creneau/course/place/6/delete',
          query: any(named: 'query'))).called(1);
    });
  });

  group('getLaneDetail', () {
    // Seule cette route montre qui occupe une place : l'arbre reunion sert
    // `engagement: null` même quand elle est prise (vérifié le 2026-09-03).
    test('lit une place sur la route de détail, pas dans l arbre', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'success': true,
                'data': {
                  'id': 287,
                  'Numero': 1,
                  'engagement': {
                    'id': 590956,
                    'athletes': [
                      {'Id': 661534},
                    ],
                  },
                },
              });

      final detail = await ds.getLaneDetail(287);

      expect(detail.id, 287);
      expect(detail.seat?.entryId, 590956);
      verify(() => http.get('competition/reunion/creneau/course/place/287',
          query: any(named: 'query'))).called(1);
    });
  });

  group('submitRun', () {
    // Vérifié en production le 2026-09-01, après correction fédérale de la
    // route : `nom`, `debut`, `fin`, `site` et `statut` font tous l'aller-
    // retour. Sans `nom`, le serveur répond « Le nom de la course est
    // obligatoire ».
    test('une course part avec son nom, ses heures, son site et son statut',
        () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 24});

      final id = await ds.submitRun(
        slotId: 75,
        name: 'Demie 1 - Surfski - Messieurs - Junior',
        beginTime: '08:00',
        endTime: '08:10',
        site: 'OCEAN 1',
      );

      expect(id, 24);
      final query = verify(() => http.post(
          'competition/reunion/creneau/75/course/submit',
          query: captureAny(named: 'query'))).captured.single;
      expect(query, {
        'id': '',
        'nom': 'Demie 1 - Surfski - Messieurs - Junior',
        'debut': '08:00',
        'fin': '08:10',
        'site': 'OCEAN 1',
        // 0 = en attente : une course naît avant d'être courue.
        'statut': '0',
      });
    });

    test('un id renseigné met à jour la course existante', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 24});

      await ds.submitRun(
        slotId: 75,
        name: 'ZZ',
        beginTime: '09:00',
        endTime: '09:10',
        site: '',
        id: 24,
      );

      final query =
          verify(() => http.post(any(), query: captureAny(named: 'query')))
              .captured
              .single as Map;
      expect(query['id'], '24');
    });

    test('une réponse sans id vaut échec', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      expect(
        await ds.submitRun(
            slotId: 75, name: 'ZZ', beginTime: '', endTime: '', site: ''),
        0,
      );
    });
  });

  group('submitHeat et submitResult', () {
    // Vérifié en production le 2026-09-04. Une `serie` s'accroche à l'épreuve,
    // pas à la course ; c'est `course/submit` qui porte ensuite le lien.
    test('une série part avec son épreuve, son nom et son numéro', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 94369});

      final id = await ds.submitHeat(raceId: 37962, name: 'Demie 1', number: 1);

      expect(id, 94369);
      final query = verify(() => http.post('competition/serie/submit',
          query: captureAny(named: 'query'))).captured.single as Map;
      expect(query['epreuve'], '37962');
      expect(query['nom'], 'Demie 1');
      expect(query['numero'], '1');
    });

    // `statut` : 0 = OK, 1 = DQ, 2 = forfait — relevé en sondant la route.
    // `place` est ce qui rattache le résultat au couloir.
    test('un résultat porte sa série, son engagement, sa place et son rang',
        () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 566546});

      final id = await ds.submitResult(
        heatId: 94369,
        entryId: 590956,
        laneId: 379,
        rank: 2,
        status: 1,
        complement: 'DSQ',
      );

      expect(id, 566546);
      final query = verify(() => http.post('competition/resultat/submit',
          query: captureAny(named: 'query'))).captured.single as Map;
      expect(query['serie'], '94369');
      expect(query['engagement'], '590956');
      expect(query['place'], '379');
      expect(query['rang'], '2');
      expect(query['statut'], '1');
      expect(query['complement'], 'DSQ');
    });

    // Un forfait ou un disqualifié ne prend pas de place : envoyer un rang
    // le ferait apparaître au classement.
    test('sans rang, le champ part vide', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true, 'id': 1});

      await ds.submitResult(
          heatId: 1, entryId: 2, laneId: 3, rank: null, status: 2);

      final query =
          verify(() => http.post(any(), query: captureAny(named: 'query')))
              .captured
              .single as Map;
      expect(query['rang'], '');
      expect(query['complement'], '');
    });

    test('les résultats d une série se relisent', () async {
      when(() => http.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {
                'success': true,
                'data': [
                  {
                    'Id': 1,
                    'Rang': 2,
                    'isDisqualifie': true,
                    'complement': 'DSQ',
                    'engagement': {'Id': 590956},
                  },
                ],
              });

      final rows = await ds.getHeatResults(94369);

      expect(rows.single.rank, 2);
      expect(rows.single.isDisqualified, isTrue);
      expect(rows.single.complement, 'DSQ');
      expect(rows.single.entry?.id, 590956);
      verify(() => http.get('competition/resultat',
          query: {'serie': 94369, 'start': 0, 'length': 200})).called(1);
    });
  });

  group('deleteRun', () {
    test('la suppression cible la course, pas le créneau', () async {
      when(() => http.post(any(), query: any(named: 'query')))
          .thenAnswer((_) async => {'success': true});

      expect(await ds.deleteRun(24), isTrue);
      verify(() => http.post('competition/reunion/creneau/course/24/delete',
          query: any(named: 'query'))).called(1);
    });
  });

  group('deleteMeeting', () {
    test('posts to competition/reunion/:id/delete and returns success',
        () async {
      when(() => http.post('competition/reunion/77/delete'))
          .thenAnswer((_) async => {'success': true});

      final deleted = await ds.deleteMeeting(77);

      expect(deleted, isTrue);
      verify(() => http.post('competition/reunion/77/delete')).called(1);
    });

    test('returns false when FFSS reports a failure', () async {
      when(() => http.post(any()))
          .thenAnswer((_) async => {'success': false, 'message': 'Nope'});

      expect(await ds.deleteMeeting(77), isFalse);
    });
  });
}
