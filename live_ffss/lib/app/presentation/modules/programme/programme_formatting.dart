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

  /// Names one course of the round rather than the round itself — « Demie »,
  /// not « Demies ». FFSS names its own courses this way, so a course created
  /// from here reads like one created on the federal site.
  String get singularLabelKey => '${labelKey}_one';
}

/// Names one course of a round, wherever it is shown or sent: on screen in the
/// draw and the Séries tab, and as the `nom` of the FFSS course itself.
///
/// The rank is dropped when the round runs a single course — « Série 2 » says
/// nothing when there is no série 1 to tell it from.
///
/// Finals are lettered instead, and keep their letter even alone: « Finale A »
/// announces that a B may exist, which « Finale » hides. Past the twenty-sixth
/// the rank takes over rather than inventing « AA » — no competition runs that
/// many, but nothing may come out blank.
String heatName(RoundType type, int index, int total) {
  final level = type.singularLabelKey.tr;
  if (type == RoundType.finale) {
    if (index < 26) {
      return '$level ${String.fromCharCode(65 + index)}';
    }
    return '$level ${index + 1}';
  }
  return total <= 1 ? level : '$level ${index + 1}';
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
