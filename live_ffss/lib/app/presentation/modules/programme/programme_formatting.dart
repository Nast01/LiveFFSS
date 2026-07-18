import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/race_placement.dart';
import 'package:live_ffss/app/domain/models/round_level.dart';

extension RacePlacementFormatting on RacePlacement {
  DateTime get endHour => beginHour.add(Duration(minutes: durationMinutes));
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
}
