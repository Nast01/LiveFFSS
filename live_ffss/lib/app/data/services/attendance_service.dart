import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/attendance_status.dart';

/// Marshalling presence, kept on the device only — the FFSS API has no
/// presence endpoint, so two phones marshalling the same race do not see each
/// other's pointing.
///
/// Scoped per race: an athlete engaged in three races is pointed separately for
/// each, which is how marshalling works (it happens before every race).
class AttendanceService extends GetxService {
  AttendanceService(this._storage);

  static const _key = 'race_attendance';

  /// Sliding cap. Races are held newest-touched first, so going past this drops
  /// the least recently pointed one.
  static const _raceCap = 100;

  final FlutterSecureStorage _storage;

  /// Newest-touched first — the list order IS the eviction order.
  final List<_RaceAttendance> _races = [];

  /// Serialises writes. Two saves racing (the RFID scan fires them back to
  /// back) could otherwise complete out of order and leave a stale payload
  /// on disk.
  Future<void> _writeQueue = Future.value();

  Future<AttendanceService> init() async {
    _races
      ..clear()
      ..addAll(await _read());
    return this;
  }

  Map<int, AttendanceStatus> forRace(int raceId) {
    for (final race in _races) {
      if (race.raceId == raceId) return Map.of(race.statuses);
    }
    return const {};
  }

  Future<void> save(int raceId, Map<int, AttendanceStatus> statuses) {
    _races.removeWhere((r) => r.raceId == raceId);
    // An empty map means nothing is pointed any more: drop the race instead of
    // holding an empty entry that would still count against the cap.
    if (statuses.isNotEmpty) {
      _races.insert(0, _RaceAttendance(raceId, Map.of(statuses)));
      if (_races.length > _raceCap) {
        _races.removeRange(_raceCap, _races.length);
      }
    }
    return _enqueueWrite(_encode(_races));
  }

  Future<void> _enqueueWrite(String payload) {
    _writeQueue =
        _writeQueue.then((_) => _storage.write(key: _key, value: payload));
    return _writeQueue;
  }

  static String _encode(List<_RaceAttendance> races) => jsonEncode([
        for (final race in races)
          {
            'race': race.raceId,
            'athletes': {
              for (final entry in race.statuses.entries)
                '${entry.key}': entry.value.storageValue,
            },
          },
      ]);

  Future<List<_RaceAttendance>> _read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final entry in decoded.whereType<Map<String, dynamic>>())
          _RaceAttendance(
            entry['race'] as int,
            {
              for (final athlete
                  in (entry['athletes'] as Map<String, dynamic>).entries)
                int.parse(athlete.key):
                    attendanceStatusFromStorage(athlete.value),
            },
          ),
      ];
    } catch (_) {
      // Corrupt or unexpected payload — treat as absent; the next save heals it.
      return const [];
    }
  }
}

class _RaceAttendance {
  _RaceAttendance(this.raceId, this.statuses);

  final int raceId;
  final Map<int, AttendanceStatus> statuses;
}
