import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('production config has correct base URL and api version', () {
      const config = AppConfig.production();

      expect(config.baseUrl, 'https://ffss.fr');
      expect(config.apiVersion, 'api/v1.0');
    });

    test('two configs with same fields are equal', () {
      const a = AppConfig(baseUrl: 'https://x.test', apiVersion: 'v1');
      const b = AppConfig(baseUrl: 'https://x.test', apiVersion: 'v1');
      expect(a, b);
    });

    test('endpoint paths are exposed as static constants', () {
      expect(ApiEndpoints.requestToken, 'requestToken');
      expect(ApiEndpoints.me, 'me');
      expect(ApiEndpoints.competitionList, 'competition/evenement');
      expect(ApiEndpoints.clubDetail, 'organisme/:id');
    });

    test('replacePath substitutes :param tokens', () {
      final result = ApiEndpoints.replacePath(
          'organisme/:id/detail', {'id': '42'});
      expect(result, 'organisme/42/detail');
    });

    test('replacePath supports multiple substitutions', () {
      final result = ApiEndpoints.replacePath(
          ':a/:b', {'a': 'x', 'b': 'y'});
      expect(result, 'x/y');
    });
  });
}
