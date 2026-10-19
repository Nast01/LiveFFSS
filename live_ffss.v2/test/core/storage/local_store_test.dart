import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss_v2/core/config/app_environment.dart';
import 'package:live_ffss_v2/core/errors/app_exception.dart';
import 'package:live_ffss_v2/core/storage/local_store.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage storage;

  setUp(() {
    storage = _MockSecureStorage();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((_) async => 'v');
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async {});
  });

  test('en production, la clé est lue telle quelle', () async {
    final store = SecureLocalStore(storage, AppEnvironment.production);

    expect(await store.read('favorite_competitions'), 'v');
    verify(() => storage.read(key: 'favorite_competitions')).called(1);
  });

  test('en développement, la clé porte le préfixe dev_', () async {
    final store = SecureLocalStore(storage, AppEnvironment.development);

    await store.write('favorite_competitions', '[1]');

    verify(
      () => storage.write(key: 'dev_favorite_competitions', value: '[1]'),
    ).called(1);
  });

  test('une clé globale n\'est jamais préfixée', () async {
    final store = SecureLocalStore(storage, AppEnvironment.development);

    await store.read('language');

    verify(() => storage.read(key: 'language')).called(1);
  });

  test('une clé de suivis porte le préfixe dev_ en développement', () async {
    final store = SecureLocalStore(storage, AppEnvironment.development);

    await store.read('follows_1416');

    verify(() => storage.read(key: 'dev_follows_1416')).called(1);
  });

  group('une erreur de la plateforme devient une StorageException', () {
    final platformError = PlatformException(code: 'KeystoreError');

    test('à la lecture', () async {
      when(() => storage.read(key: any(named: 'key'))).thenThrow(platformError);
      final store = SecureLocalStore(storage, AppEnvironment.production);

      expect(() => store.read('k'), throwsA(isA<StorageException>()));
    });

    test("à l'écriture", () async {
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(platformError);
      final store = SecureLocalStore(storage, AppEnvironment.production);

      expect(() => store.write('k', 'v'), throwsA(isA<StorageException>()));
    });

    test('à la suppression', () async {
      when(
        () => storage.delete(key: any(named: 'key')),
      ).thenThrow(platformError);
      final store = SecureLocalStore(storage, AppEnvironment.production);

      expect(() => store.delete('k'), throwsA(isA<StorageException>()));
    });
  });
}
