import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
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

      expect(service.current.value,
          const CompetitionProgramme(competitionId: 42));
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

      expect(service.current.value,
          const CompetitionProgramme(competitionId: 42));
    });
  });

  group('save', () {
    test('writes the JSON and updates current', () async {
      when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'))).thenAnswer((_) async {});
      const p = CompetitionProgramme(competitionId: 42, nextLocalId: 3);

      await service.save(p);

      expect(service.current.value, p);
      verify(() => storage.write(
          key: 'programme_42', value: jsonEncode(p.toJson()))).called(1);
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
}
