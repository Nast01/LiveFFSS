import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_ffss/app/data/services/attendance_service.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUpAll(() => registerFallbackValue(''));

  late _MockSecureStorage storage;
  late AttendanceService service;

  /// Last value handed to `storage.write`, decoded.
  List<dynamic> lastWritten() {
    final captured = verify(
      () => storage.write(
        key: 'race_attendance',
        value: captureAny(named: 'value'),
      ),
    ).captured;
    return jsonDecode(captured.last as String) as List<dynamic>;
  }

  setUp(() {
    storage = _MockSecureStorage();
    service = AttendanceService(storage);
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
    when(() =>
            storage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
  });

  group('AttendanceService.init', () {
    test('reads stored races and exposes them per race', () async {
      when(() => storage.read(key: 'race_attendance')).thenAnswer(
        (_) async => jsonEncode([
          {
            'race': 10,
            'athletes': {'100': 'present', '101': 'absent'},
          },
          {
            'race': 20,
            'athletes': {'200': 'present'},
          },
        ]),
      );

      await service.init();

      expect(service.forRace(10), {
        100: AttendanceStatus.present,
        101: AttendanceStatus.absent,
      });
      expect(service.forRace(20), {200: AttendanceStatus.present});
    });

    test('a race that was never pointed reads as empty', () async {
      await service.init();

      expect(service.forRace(999), isEmpty);
    });

    test('a corrupt payload is treated as absent', () async {
      when(() => storage.read(key: 'race_attendance'))
          .thenAnswer((_) async => 'not json at all');

      await service.init();

      expect(service.forRace(10), isEmpty);
    });

    test('an unrecognised status degrades to waiting', () async {
      when(() => storage.read(key: 'race_attendance')).thenAnswer(
        (_) async => jsonEncode([
          {
            'race': 10,
            'athletes': {'100': 'checked_in', '101': 'present'},
          },
        ]),
      );

      await service.init();

      expect(service.forRace(10)[100], AttendanceStatus.waiting);
      expect(service.forRace(10)[101], AttendanceStatus.present);
    });
  });

  group('AttendanceService.save', () {
    test('round-trips a race and persists it', () async {
      await service.init();

      await service.save(10, {100: AttendanceStatus.present});

      expect(service.forRace(10), {100: AttendanceStatus.present});
      expect(lastWritten(), [
        {
          'race': 10,
          'athletes': {'100': 'present'},
        },
      ]);
    });

    test('replaces the previous statuses of that race', () async {
      await service.init();

      await service.save(
          10, {100: AttendanceStatus.present, 101: AttendanceStatus.absent});
      await service.save(10, {100: AttendanceStatus.absent});

      expect(service.forRace(10), {100: AttendanceStatus.absent});
    });

    test('moves the saved race to the front, leaving the others in order',
        () async {
      await service.init();

      await service.save(1, {1: AttendanceStatus.present});
      await service.save(2, {2: AttendanceStatus.present});
      await service.save(1, {1: AttendanceStatus.absent});

      final written = lastWritten();
      expect(written.map((e) => (e as Map)['race']), [1, 2]);
    });

    test('evicts the oldest race beyond the 100-race cap', () async {
      await service.init();

      for (var raceId = 1; raceId <= 101; raceId++) {
        await service.save(raceId, {raceId: AttendanceStatus.present});
      }

      expect(lastWritten(), hasLength(100));
      // Race 1 was the oldest touched, so it fell off the tail.
      expect(service.forRace(1), isEmpty);
      expect(service.forRace(2), isNotEmpty);
      expect(service.forRace(101), isNotEmpty);
    });

    test('an empty attendance map drops the race rather than storing nothing',
        () async {
      await service.init();
      await service.save(10, {100: AttendanceStatus.present});

      await service.save(10, {});

      expect(service.forRace(10), isEmpty);
      expect(lastWritten(), isEmpty);
    });

    test('concurrent saves are serialised so the last one wins on disk',
        () async {
      await service.init();

      // Not awaited individually: mimics the RFID scan firing several
      // saves back to back. Out-of-order writes would persist a stale state.
      final first = service.save(10, {100: AttendanceStatus.present});
      final second = service.save(10, {
        100: AttendanceStatus.present,
        101: AttendanceStatus.present,
      });
      await Future.wait([first, second]);

      expect(lastWritten(), [
        {
          'race': 10,
          'athletes': {'100': 'present', '101': 'present'},
        },
      ]);
    });
  });
}
