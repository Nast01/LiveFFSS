import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/core/config/app_environment.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:mocktail/mocktail.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockStorage storage;
  late ProgrammeService service;

  setUpAll(() => registerFallbackValue(''));

  setUp(() {
    storage = _MockStorage();
    service = ProgrammeService(storage);
  });

  group('load', () {
    test('creates an empty programme when storage is empty', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => null);

      await service.load(42);

      expect(
          service.current.value, const CompetitionProgramme(competitionId: 42));
    });

    test('decodes an existing programme', () async {
      const stored = CompetitionProgramme(competitionId: 42, nextLocalId: 9);
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => jsonEncode(stored.toJson()));

      await service.load(42);

      expect(service.current.value, stored);
    });

    test('falls back to an empty programme on a corrupt payload', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => 'not json');

      await service.load(42);

      expect(
          service.current.value, const CompetitionProgramme(competitionId: 42));
    });
  });

  group('save', () {
    test('writes the JSON and updates current', () async {
      when(() =>
              storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((_) async {});
      const p = CompetitionProgramme(competitionId: 42, nextLocalId: 3);

      await service.save(p);

      expect(service.current.value, p);
      verify(() =>
              storage.write(key: 'programme_42', value: jsonEncode(p.toJson())))
          .called(1);
    });
  });

  group('queued saves', () {
    test(
        'a failed write does not skip the write queued behind it, and each '
        'call reports its own outcome', () async {
      var writes = 0;
      String? lastValue;
      when(() =>
              storage.write(key: any(named: 'key'), value: any(named: 'value')))
          .thenAnswer((invocation) async {
        writes++;
        lastValue = invocation.namedArguments[#value] as String;
        // Only the first write fails — the second must still reach storage
        // rather than being skipped because the one ahead of it in the
        // queue rejected.
        if (writes == 1) throw Exception('disk full');
      });
      const a = CompetitionProgramme(competitionId: 42, nextLocalId: 1);
      const b = CompetitionProgramme(competitionId: 42, nextLocalId: 2);

      final first = service.save(a);
      final second = service.save(b);

      await expectLater(first, throwsException);
      await second;

      expect(writes, 2);
      expect(lastValue, jsonEncode(b.toJson()));
    });
  });

  group('allocateId', () {
    test('returns the current id and bumps the counter', () async {
      when(() => storage.read(key: 'programme_42'))
          .thenAnswer((_) async => null);
      await service.load(42);

      final first = service.allocateId();
      final second = service.allocateId();

      expect(first, 1);
      expect(second, 2);
      expect(service.current.value!.nextLocalId, 3);
    });
  });

  group('clearEverything', () {
    // La porte de sortie quand le stockage d'un appareil a derive de FFSS.
    // Depuis le cloisonnement par environnement, elle ne prend plus que les
    // cles de l'environnement courant : effacer la production ne doit pas
    // emporter le developpement, ni la langue, ni le choix d'endpoint.
    test('ne supprime que les cles de la production', () async {
      when(() => storage.readAll()).thenAnswer((_) async => {
            'token': 'T',
            'user': '{}',
            'programme_42': '{}',
            'dev_token': 'D',
            'dev_programme_42': '{}',
            'language': 'fr',
            'api_environment': 'production',
          });
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      when(() => storage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);
      final service = ProgrammeService(storage);
      await service.load(42);

      await service.clearEverything();

      verify(() => storage.delete(key: 'token')).called(1);
      verify(() => storage.delete(key: 'user')).called(1);
      verify(() => storage.delete(key: 'programme_42')).called(1);
      verifyNever(() => storage.delete(key: 'dev_token'));
      verifyNever(() => storage.delete(key: 'dev_programme_42'));
      verifyNever(() => storage.delete(key: 'language'));
      verifyNever(() => storage.delete(key: 'api_environment'));
      expect(service.current.value, isNull);
    });

    test('ne supprime que les cles du developpement', () async {
      when(() => storage.readAll()).thenAnswer((_) async => {
            'token': 'T',
            'dev_token': 'D',
            'language': 'fr',
          });
      when(() => storage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});
      final service = ProgrammeService(
        storage,
        environment: AppEnvironment.development,
      );

      await service.clearEverything();

      verify(() => storage.delete(key: 'dev_token')).called(1);
      verifyNever(() => storage.delete(key: 'token'));
      verifyNever(() => storage.delete(key: 'language'));
    });

    test('prefixe la cle du programme', () async {
      when(() => storage.read(key: 'dev_programme_42'))
          .thenAnswer((_) async => null);
      final service = ProgrammeService(
        storage,
        environment: AppEnvironment.development,
      );

      await service.load(42);

      verify(() => storage.read(key: 'dev_programme_42')).called(1);
    });
  });
}
