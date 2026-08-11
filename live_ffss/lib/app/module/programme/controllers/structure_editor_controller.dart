import 'package:get/get.dart';
import 'package:live_ffss/app/core/errors/app_exception.dart';
import 'package:live_ffss/app/data/repositories/race_format_repository.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';
import 'package:live_ffss/app/presentation/shared/ui_message.dart';

class StructureEditorArgs {
  const StructureEditorArgs({
    required this.competitionId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
    this.gender = Gender.unknown,
    this.defaultSpotsPerRace = defaultPoolSpotsPerRace,
    this.serverDetails = const [],
  });

  final int competitionId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;

  /// Carried for the heading only: [EventStructure] has no gender of its own,
  /// yet the editor must be titled exactly like the row it was opened from.
  final Gender gender;

  /// Heat size for a structure that does not exist yet — 16 coastal, 8 pool.
  /// Only seeds a new structure; a stored one keeps whatever was authored.
  final int defaultSpotsPerRace;

  /// Rounds FFSS already holds for this épreuve × category. When present they
  /// seed a brand-new structure, which beats guessing from the entry count.
  final List<RaceFormatDetail> serverDetails;
}

class StructureEditorController extends GetxController {
  StructureEditorController(this._programme, this._raceFormatRepo);

  final ProgrammeService _programme;
  final RaceFormatRepository _raceFormatRepo;

  final Rxn<EventStructure> structure = Rxn<EventStructure>();

  /// True while a round is being deleted on the FFSS server.
  final RxBool isDeletingLevel = false.obs;
  final Rxn<UiMessage> message = Rxn<UiMessage>();
  late StructureEditorArgs _args;

  Gender get gender => _args.gender;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is StructureEditorArgs) start(arg);
  }

  @override
  void onReady() {
    super.onReady();
    seedFromServerIfNeeded();
  }

  /// Loads the stored structure for this épreuve × category, or an empty one
  /// carrying the labels and the speciality's default race size.
  ///
  /// Reads only. Seeding from the server deliberately does NOT happen here:
  /// allocating ids and persisting both write to the shared [ProgrammeService],
  /// which the structure overview observes — doing that while this route builds
  /// would mark a mounted widget dirty mid-build. See [seedFromServerIfNeeded].
  void start(StructureEditorArgs args) {
    _args = args;
    structure.value = _stored() ??
        EventStructure(
          raceId: args.raceId,
          categoryId: args.categoryId,
          raceLabel: args.raceLabel,
          categoryLabel: args.categoryLabel,
          spotsPerRace: args.defaultSpotsPerRace,
        );
  }

  /// Adopts the rounds FFSS declares whenever this structure holds none —
  /// whether it is brand new or had all of its rounds removed. Called from
  /// [onReady], i.e. after the first frame.
  ///
  /// The guard is "no rounds", not "never stored": a structure emptied by the
  /// operator used to stay empty for good, with no way to pull the server ones
  /// back. Authored rounds are still never overwritten — that is what makes the
  /// local copy authoritative. The result is persisted at once so the ids just
  /// allocated are not handed out twice.
  /// Whether FFSS declares any round for this épreuve × category — drives
  /// whether re-importing is offered at all.
  bool get hasServerRounds => _args.serverDetails.isNotEmpty;

  /// Replaces the local rounds with the ones FFSS declares, discarding whatever
  /// was authored — including any heats drawn into the replaced races.
  ///
  /// This is the deliberate opposite of [seedFromServerIfNeeded], which never
  /// touches existing rounds. Purely local: nothing is sent to the server, we
  /// only adopt what it already holds. The view confirms before calling it.
  void reimportFromServer() {
    if (!hasServerRounds || structure.value == null) return;
    _commit(structure.value!.copyWith(
      levels: buildLevelsFromDetails(
        details: _args.serverDetails,
        allocateId: _programme.allocateId,
      ),
    ));
    message.value = const UiMessageSuccess('round_reimport_done');
  }

  void seedFromServerIfNeeded() {
    final current = structure.value;
    if (current == null ||
        current.levels.isNotEmpty ||
        _args.serverDetails.isEmpty) {
      return;
    }
    _commit(current.copyWith(
      levels: buildLevelsFromDetails(
        details: _args.serverDetails,
        allocateId: _programme.allocateId,
      ),
    ));
  }

  void proposeDefault() {
    final s = structure.value!;
    final levels = buildDefaultLevels(
      entryCount: _args.entryCount,
      spotsPerRace: s.spotsPerRace,
      allocateId: _programme.allocateId,
    );
    _commit(s.copyWith(levels: levels));
  }

  /// Sets the race size of one round. Changing it does NOT recompute the
  /// levels — `proposeDefault` is the explicit way to do that.
  void setLevelSpotsPerRace(int levelIndex, int spots) {
    if (spots < 1) return;
    final levels = [...structure.value!.levels];
    levels[levelIndex] = levels[levelIndex].copyWith(spotsPerRace: spots);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void addLevel(RoundType type) {
    final s = structure.value!;
    _commit(s.copyWith(levels: [
      ...s.levels,
      // A new round inherits the structure's default size rather than 0, so it
      // shows a real number straight away.
      RoundLevel(type: type, spotsPerRace: s.spotsPerRace),
    ]));
  }

  /// Removes a round. When it came from FFSS (it carries a `serverId`), the
  /// server copy is deleted first and the round is kept on failure — leaving a
  /// round the operator believes gone still defined on a shared server would be
  /// worse than refusing the action. A hand-added round has nothing to call.
  Future<void> removeLevel(int levelIndex) async {
    final level = structure.value!.levels[levelIndex];
    if (level.serverId > 0) {
      isDeletingLevel.value = true;
      bool deleted;
      try {
        deleted = await _raceFormatRepo.deleteRaceFormatDetail(level.serverId);
      } on AppException {
        deleted = false;
      } finally {
        isDeletingLevel.value = false;
      }
      if (!deleted) {
        message.value = const UiMessageError('round_delete_failed');
        return;
      }
    }
    final levels = [...structure.value!.levels]..removeAt(levelIndex);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setRaceCount(int levelIndex, int count) {
    if (count < 0) return;
    final levels = [...structure.value!.levels];
    final level = levels[levelIndex];
    final races = [...level.races];
    while (races.length < count) {
      races.add(ProgrammeRace(
        id: _programme.allocateId(),
        number: races.length + 1,
      ));
    }
    if (races.length > count) races.removeRange(count, races.length);
    levels[levelIndex] = level.copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setQualifiers(int levelIndex, int qualifiers) {
    if (qualifiers < 0) return;
    final levels = [...structure.value!.levels];
    levels[levelIndex] =
        levels[levelIndex].copyWith(qualifiersPerRace: qualifiers);
    _commit(structure.value!.copyWith(levels: levels));
  }

  void setWiring(int levelIndex, int raceId, List<int> sourceRaceIds) {
    final levels = [...structure.value!.levels];
    final races = levels[levelIndex]
        .races
        .map((r) =>
            r.id == raceId ? r.copyWith(sourceRaceIds: sourceRaceIds) : r)
        .toList();
    levels[levelIndex] = levels[levelIndex].copyWith(races: races);
    _commit(structure.value!.copyWith(levels: levels));
  }

  EventStructure? _stored() {
    final structures = _programme.current.value?.structures ?? const [];
    for (final s in structures) {
      if (s.raceId == _args.raceId && s.categoryId == _args.categoryId) {
        return s;
      }
    }
    return null;
  }

  /// Sets the reactive structure and persists it into the programme, replacing
  /// any prior structure for this épreuve × category.
  void _commit(EventStructure updated) {
    structure.value = updated;
    final p = _programme.current.value ??
        CompetitionProgramme(competitionId: _args.competitionId);
    final others = p.structures
        .where((s) =>
            !(s.raceId == updated.raceId && s.categoryId == updated.categoryId))
        .toList();
    _programme.save(p.copyWith(structures: [...others, updated]));
  }
}
