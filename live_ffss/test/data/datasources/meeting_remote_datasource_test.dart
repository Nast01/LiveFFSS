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
}
