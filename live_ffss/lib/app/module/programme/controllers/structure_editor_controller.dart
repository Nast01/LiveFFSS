import 'package:get/get.dart';
import 'package:live_ffss/app/data/services/programme_service.dart';
import 'package:live_ffss/app/domain/models/competition_programme.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_race.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/structure_generator.dart';

class StructureEditorArgs {
  const StructureEditorArgs({
    required this.competitionId,
    required this.raceId,
    required this.categoryId,
    required this.raceLabel,
    required this.categoryLabel,
    required this.entryCount,
  });

  final int competitionId;
  final int raceId;
  final int categoryId;
  final String raceLabel;
  final String categoryLabel;
  final int entryCount;
}

class StructureEditorController extends GetxController {
  StructureEditorController(this._programme);

  final ProgrammeService _programme;

  final Rxn<EventStructure> structure = Rxn<EventStructure>();
  late StructureEditorArgs _args;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is StructureEditorArgs) start(arg);
  }

  /// Loads the stored structure for this épreuve × category, or seeds an empty
  /// one carrying the event labels and the default spots-per-race.
  void start(StructureEditorArgs args) {
    _args = args;
    structure.value = _stored() ??
        EventStructure(
          raceId: args.raceId,
          categoryId: args.categoryId,
          raceLabel: args.raceLabel,
          categoryLabel: args.categoryLabel,
        );
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

  void setSpotsPerRace(int spots) {
    if (spots < 1) return;
    _commit(structure.value!.copyWith(spotsPerRace: spots));
  }

  void addLevel(RoundType type) {
    final s = structure.value!;
    _commit(s.copyWith(levels: [...s.levels, RoundLevel(type: type)]));
  }

  void removeLevel(int levelIndex) {
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
        .where((s) => !(s.raceId == updated.raceId &&
            s.categoryId == updated.categoryId))
        .toList();
    _programme.save(p.copyWith(structures: [...others, updated]));
  }
}
