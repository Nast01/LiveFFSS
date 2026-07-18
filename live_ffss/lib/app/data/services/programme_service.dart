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

  static String _key(int competitionId) => 'programme_$competitionId';

  Future<void> load(int competitionId) async {
    final raw = await _storage.read(key: _key(competitionId));
    current.value = _decode(raw, competitionId);
  }

  Future<void> save(CompetitionProgramme programme) async {
    current.value = programme;
    await _storage.write(
      key: _key(programme.competitionId),
      value: jsonEncode(programme.toJson()),
    );
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
