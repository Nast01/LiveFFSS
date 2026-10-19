import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/engagement_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late EngagementRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = EngagementRepositoryImpl(http);
  });

  void answer(Map<String, dynamic> body) => when(
    () => http.post(any(), query: any(named: 'query')),
  ).thenAnswer((_) async => body);

  test('déclarer : forfait=1 dans l\'adresse, sans corps', () async {
    answer({'success': true, 'message': 'Engagement modifié'});

    await repository.setForfeit(565147, forfeit: true);

    verify(
      () => http.post(
        'competition/engagement/565147/submit',
        query: {'forfait': '1'},
      ),
    ).called(1);
    verifyNever(
      () => http.post(
        any(),
        query: any(named: 'query'),
        body: any(named: 'body'),
      ),
    );
    verifyNever(
      () => http.post(
        any(),
        query: any(named: 'query'),
        form: any(named: 'form'),
      ),
    );
  });

  test('annuler : forfait=0', () async {
    answer({'success': true});

    await repository.setForfeit(12, forfeit: false);

    verify(
      () => http.post(
        'competition/engagement/12/submit',
        query: {'forfait': '0'},
      ),
    ).called(1);
  });

  test('success: false lève ApiException avec le message du site', () {
    answer({'success': false, 'message': 'Accès refusé'});

    expect(
      repository.setForfeit(12, forfeit: true),
      throwsA(
        isA<ApiException>().having((e) => e.message, 'message', 'Accès refusé'),
      ),
    );
  });

  test('une AppException de HttpClient remonte telle quelle', () {
    when(
      () => http.post(any(), query: any(named: 'query')),
    ).thenThrow(const NetworkException('hors ligne'));

    expect(
      repository.setForfeit(12, forfeit: true),
      throwsA(isA<NetworkException>()),
    );
  });
}
