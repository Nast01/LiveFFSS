import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/network/http_client.dart';
import 'package:live_ffss_v2/data/repositories/auth_repository.dart';
import 'package:live_ffss_v2/domain/account.dart';
import 'package:live_ffss_v2/domain/competition_roles.dart';
import 'package:mocktail/mocktail.dart';

import '../../support/fixtures.dart';

class _MockHttpClient extends Mock implements HttpClient {}

void main() {
  late _MockHttpClient http;
  late AuthRepositoryImpl repository;

  setUp(() {
    http = _MockHttpClient();
    repository = AuthRepositoryImpl(http);
  });

  group('requestToken', () {
    test(
      'envoie les identifiants dans le formulaire, pas dans l\'adresse',
      () async {
        when(
          () => http.post(
            any(),
            query: any(named: 'query'),
            form: any(named: 'form'),
          ),
        ).thenAnswer(
          (_) async => {'token': 'abc', 'expiration': '2026-10-19 10:00:00'},
        );

        expect(await repository.requestToken(' jdupont ', 'secret'), 'abc');

        final captured = verify(
          () => http.post(
            'requestToken',
            query: captureAny(named: 'query'),
            form: captureAny(named: 'form'),
          ),
        ).captured;
        expect(captured[0], isNull);
        expect(captured[1], {'login': 'jdupont', 'password': 'secret'});
      },
    );

    test('une réponse sans jeton est un refus', () async {
      when(
        () => http.post(any(), form: any(named: 'form')),
      ).thenAnswer((_) async => {'success': true, 'message': 'ok'});

      expect(
        () => repository.requestToken('jdupont', 'secret'),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('me', () {
    test('lit le nom, le type et le rôle du compte', () async {
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
        const Account(label: 'DUPONT Jean', type: 'licencie', role: 'user'),
      );
    });

    test('compte admin (fixture de la recette) : isAdmin', () async {
      when(() => http.get('me')).thenAnswer((_) async => fixture('me_admin'));

      final account = await repository.me();

      expect(account.role, 'admin');
      expect(account.type, 'organisme');
      expect(account.isAdmin, isTrue);
    });

    test('licencié : pas admin', () async {
      when(() => http.get('me')).thenAnswer(
        (_) async => {
          'label': 'DUPONT Jean',
          'type': 'licencie',
          'data': {'role': 'user'},
        },
      );

      expect((await repository.me()).isAdmin, isFalse);
    });

    test('sans rôle lisible : rôle nul, pas admin', () async {
      when(() => http.get('me')).thenAnswer(
        (_) async => {'label': 'DUPONT Jean', 'type': 'licencie', 'data': []},
      );

      final account = await repository.me();

      expect(account.role, isNull);
      expect(account.isAdmin, isFalse);
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
    test('lit les rôles détaillés (fixture de la recette)', () async {
      when(
        () => http.get('competition/evenement/1416/me'),
      ).thenAnswer((_) async => fixture('evenement_me_1416'));

      final roles = await repository.competitionRoles(1416);

      expect(roles.roles, [
        'public',
        'licencie',
        'officiel',
        'referent_sportif',
      ]);
      expect(roles.licenseeId, 1326);
      expect(roles.official?.level, 'B');
      expect(roles.official?.levelLabel, 'B - Juge de virage/obstacles');
      expect(roles.official?.principal, isFalse);
      expect(roles.refereeClubs, [
        const ClubRef(
          id: 15,
          label: "Les Dauphins du Frontonnais et de l'Union",
        ),
      ]);
      expect(roles.isOfficial, isTrue);
    });

    test('admin : isAdmin', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': ['public', 'admin'],
          },
        },
      );

      expect((await repository.competitionRoles(1416)).isAdmin, isTrue);
    });

    test('des rôles qui ne sont pas une liste valent public', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': {'0': 'admin'},
            'licencie': {'id': 1326},
          },
        },
      );

      final roles = await repository.competitionRoles(1416);

      expect(roles.roles, ['public']);
      expect(roles.isAdmin, isFalse);
      expect(roles.licenseeId, 1326);
    });

    test('un objet officiel mal typé est ignoré seul', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': ['public', 'officiel'],
            'licencie': {'id': '1326'},
            'officiel': {'niveau': 3, 'principal': 'oui'},
            'referent_sportif': [
              {'id': 15, 'label': 'Club'},
              'texte',
              {'id': 'x'},
            ],
          },
        },
      );

      final roles = await repository.competitionRoles(1416);

      expect(roles.roles, ['public', 'officiel']);
      expect(roles.official, isNull);
      expect(roles.licenseeId, 1326);
      expect(roles.refereeClubs, [const ClubRef(id: 15, label: 'Club')]);
    });

    test('id de club servi en chaîne, principal absent : gardés', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': ['public', 'officiel'],
            'officiel': {'niveau': 'B'},
            'referent_sportif': [
              {'id': '15', 'label': 'Club'},
            ],
          },
        },
      );

      final roles = await repository.competitionRoles(1416);

      expect(roles.official?.level, 'B');
      expect(roles.official?.principal, isFalse);
      expect(roles.refereeClubs, [const ClubRef(id: 15, label: 'Club')]);
    });

    test('licencie et officiel servis en [] (objet vide de PHP)', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': ['public', 'licencie'],
            'licencie': <Object?>[],
            'officiel': <Object?>[],
            'referent_sportif': <Object?>[],
          },
        },
      );

      final roles = await repository.competitionRoles(1416);

      expect(roles.roles, ['public', 'licencie']);
      expect(roles.licenseeId, isNull);
      expect(roles.official, isNull);
      expect(roles.refereeClubs, isEmpty);
    });

    test('lit aussi les rôles servis sans enveloppe (sans session)', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'roles': ['public'],
        },
      );

      expect((await repository.competitionRoles(1416)).roles, ['public']);
    });

    test('sans rôle lisible : public', () async {
      when(() => http.get('competition/evenement/1416/me')).thenAnswer(
        (_) async => {
          'data': {
            'roles': [3, null],
          },
        },
      );

      expect((await repository.competitionRoles(1416)).roles, ['public']);
    });
  });
}
