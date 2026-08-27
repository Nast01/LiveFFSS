import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';

/// On-device store for a competition's authored programme. One JSON blob per
/// competition, keyed `programme_<competitionId>`. The single source of truth
/// while FFSS write endpoints are undocumented.
class ProgrammeService extends GetxService {
  ProgrammeService(this._storage);

  final FlutterSecureStorage _storage;
  final Rxn<CompetitionProgramme> current = Rxn<CompetitionProgramme>();

  // Reads and writes of the one blob must not reorder: a load() re-reads
  // storage and overwrites current.value wholesale, and race_course_controller
  // deliberately does not await its save() calls (result entry must feel
  // instant). Without a queue, popping out of a scored course and opening the
  // next race within the window of that unawaited write can seat
  // current.value on the pre-write blob, and the next save() would persist
  // that stale blob back over the just-recorded result.
  //
  // [_current] holds the in-flight operation, if any, and clears itself once
  // it settles — rather than a future that stays chained forever. That keeps
  // an uncontended call's storage access synchronous (issued the moment the
  // method is called, same as a bare unqueued call), and only makes a call
  // wait when something genuinely is still in flight.
  Future<void>? _current;

  Future<void> _enqueue(Future<void> Function() op) {
    final waitFor = _current;
    final future = waitFor == null ? op() : waitFor.then((_) => op());
    _current = future;
    future.whenComplete(() {
      if (identical(_current, future)) _current = null;
    });
    return future;
  }

  static String _key(int competitionId) => 'programme_$competitionId';

  Future<void> load(int competitionId) => _enqueue(() async {
        final raw = await _storage.read(key: _key(competitionId));
        current.value = _decode(raw, competitionId);
      });

  Future<void> save(CompetitionProgramme programme) {
    // Set synchronously, outside the queue: the surgical merge callers do
    // (read current.value right back out after calling save()) depends on
    // seeing the new value immediately, not after the write completes.
    current.value = programme;
    return _enqueue(() => _storage.write(
          key: _key(programme.competitionId),
          value: jsonEncode(programme.toJson()),
        ));
  }

  /// Returns the next local id and advances the counter in [current]. The
  /// caller persists the bump with a subsequent [save].
  int allocateId() {
    final p = current.value!;
    current.value = p.copyWith(nextLocalId: p.nextLocalId + 1);
    return p.nextLocalId;
  }

  CompetitionProgramme _decode(String? raw, int competitionId) {
    if (raw == null || raw.isEmpty) {
      return CompetitionProgramme(competitionId: competitionId);
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CompetitionProgramme.fromJson(json);
    } catch (_) {
      // Corrupt payload — treat as absent; the next save self-heals.
      return CompetitionProgramme(competitionId: competitionId);
    }
  }
}
