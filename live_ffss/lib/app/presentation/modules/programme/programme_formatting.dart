import 'package:get/get.dart';
import 'package:live_ffss/app/domain/models/athlete.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';
import 'package:live_ffss/app/domain/models/schedule_planner.dart';
import 'package:live_ffss/app/presentation/modules/competitions/race_formatting.dart';

/// How an épreuve × category is named wherever it appears — the overview list
/// and the editor share this so the two headings cannot drift apart.
String structureTitle({
  required String raceLabel,
  required Gender gender,
  required String categoryLabel,
}) =>
    [
      raceLabel,
      if (gender != Gender.unknown) gender.label,
      categoryLabel,
    ].where((part) => part.isNotEmpty).join(' · ');

extension ScheduleItemFormatting on ScheduleItem {
  String get label =>
      '$raceLabel · $categoryLabel · ${roundType.labelKey.tr} $number';
}

extension RoundTypeFormatting on RoundType {
  String get labelKey => switch (this) {
        RoundType.serie => 'round_serie',
        RoundType.quart => 'round_quart',
        RoundType.demi => 'round_demi',
        RoundType.finale => 'round_finale',
        RoundType.unknown => 'round_unknown',
      };
}

extension EventStructureFormatting on EventStructure {
  List<RoundType> get chain => levels.map((l) => l.type).toList();
  bool get isDefined => levels.isNotEmpty;

  /// The whole chain on one line: "3 séries ×8 (4 qual.) → 1 finale ×8". Shown
  /// above a single round so the structure stays readable without walking the
  /// rounds one by one. Empty for a structure with no round.
  String get chainSummary => levels.map((l) {
        final qualifiers = l.qualifiersPerRace > 0
            ? ' (${l.qualifiersPerRace} ${'qualified_short'.tr})'
            : '';
        return '${l.races.length} ${l.type.labelKey.tr.toLowerCase()} '
            '×${spotsForLevel(l)}$qualifiers';
      }).join(' → ');
}
