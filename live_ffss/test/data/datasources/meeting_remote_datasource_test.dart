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

      final query = verify(() => http.post(any(),
          query: captureAny(named: 'query'))).captured.single as Map;
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

      final query = verify(() => http.post(any(),
          query: captureAny(named: 'query'))).captured.single as Map;
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
}
