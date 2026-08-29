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
}
