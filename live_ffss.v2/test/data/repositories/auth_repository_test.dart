import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late AuthRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = AuthRepositoryImpl(http);
  });

  group('requestToken', () {
    test('envoie les identifiants dans l\'adresse et rend le jeton', () async {
      when(() => http.post(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => {'token': 'abc', 'expiration': '2026-10-19 10:00:00'},
      );

      expect(await repository.requestToken(' jdupont ', 'secret'), 'abc');

      verify(
        () => http.post(
          'requestToken',
          query: {'login': 'jdupont', 'password': 'secret'},
        ),
      ).called(1);
    });

    test('une réponse sans jeton est un refus', () async {
      when(
        () => http.post(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => {'success': true, 'message': 'ok'});

      expect(
        () => repository.requestToken('jdupont', 'secret'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('me', () {
    test('lit le nom et le type du compte', () async {
      when(() => http.get('me')).thenAnswer(
        (_) async => {
          'success': true,
          'label': 'DUPONT Jean',
          'type': 'licencie',
          'data': {'nom': 'DUPONT', 'prenom': 'Jean', 'role': 'user'},
        },
      );

      expect(
        await repository.me(),
        const Account(label: 'DUPONT Jean', type: 'licencie'),
      );
    });

    test('le compte anonyme est refusé', () async {
      when(
        () => http.get('me'),
      ).thenAnswer((_) async => {'label': 'Utilisateur Anonyme'});

      expect(() => repository.me(), throwsA(isA<AuthException>()));
    });

    test('une réponse sans nom est refusée', () async {
      when(() => http.get('me')).thenAnswer((_) async => {'success': true});

      expect(() => repository.me(), throwsA(isA<AuthException>()));
    });
  });

  group('competitionRoles', () {
    test('lit les rôles dans data', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': ['public', 'licencie', 'officiel'],
            'officiel': {'niveau': 'B', 'principal': false},
          },
        },
      );

      expect(await repository.competitionRoles(1416), [
        'public',
        'licencie',
        'officiel',
      ]);
    });

    test('lit aussi les rôles servis sans enveloppe (sans session)', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'roles': ['public'],
        },
      );

      expect(await repository.competitionRoles(1416), ['public']);
    });

    test('sans rôle lisible : public', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': [3, null],
          },
        },
      );

      expect(await repository.competitionRoles(1416), ['public']);
    });
  });
}
