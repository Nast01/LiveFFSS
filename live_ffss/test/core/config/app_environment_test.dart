import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('porte les deux endpoints FFSS', () {
      expect(AppEnvironment.production.endpoint, 'https://ffss.fr/api/v1.0/');
      expect(
        AppEnvironment.development.endpoint,
        'https://site.ffss.io/api/v1.0/',
      );
    });

    test('la production est l\'environnement non prefixe', () {
      expect(AppEnvironment.production.storagePrefix, '');
      expect(AppEnvironment.development.storagePrefix, 'dev_');
    });

    test('fromName decode le nom de l\'enum, et rien d\'autre', () {
      expect(
          AppEnvironment.fromName('development'), AppEnvironment.development);
      expect(AppEnvironment.fromName('production'), AppEnvironment.production);
      expect(AppEnvironment.fromName('staging'), isNull);
      expect(AppEnvironment.fromName(null), isNull);
    });
  });

  group('AppEnvironment.resolve', () {
    test('une build release est la production, quoi qu\'il soit stocke', () {
      expect(
        AppEnvironment.resolve(
          isDebug: false,
          stored: AppEnvironment.development,
        ),
        AppEnvironment.production,
      );
    });

    test('en debug, le choix memorise l\'emporte sur le dart-define', () {
      expect(
        AppEnvironment.resolve(
          isDebug: true,
          stored: AppEnvironment.production,
          dartDefine: 'development',
        ),
        AppEnvironment.production,
      );
    });

    test('le dart-define s\'applique quand rien n\'est memorise', () {
      expect(
        AppEnvironment.resolve(isDebug: true, dartDefine: 'production'),
        AppEnvironment.production,
      );
    });

    test('un dart-define inconnu retombe sur le defaut au lieu de lever', () {
      expect(
        AppEnvironment.resolve(isDebug: true, dartDefine: 'staging'),
        AppEnvironment.development,
      );
    });

    test('en debug, sans rien, le defaut est le developpement', () {
      expect(AppEnvironment.resolve(isDebug: true), AppEnvironment.development);
    });
  });

  group('AppEnvironment.owner', () {
    test('les cles globales n\'appartiennent a personne', () {
      expect(AppEnvironment.owner('language'), isNull);
      expect(AppEnvironment.owner('api_environment'), isNull);
    });

    test('une cle prefixee dev_ appartient au developpement', () {
      expect(AppEnvironment.owner('dev_token'), AppEnvironment.development);
      expect(
        AppEnvironment.owner('dev_programme_42'),
        AppEnvironment.development,
      );
    });

    test('toute autre cle appartient a la production', () {
      expect(AppEnvironment.owner('token'), AppEnvironment.production);
      expect(AppEnvironment.owner('programme_42'), AppEnvironment.production);
      expect(
        AppEnvironment.owner('favorite_competitions'),
        AppEnvironment.production,
      );
    });
  });
}
