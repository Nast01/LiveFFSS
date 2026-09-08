import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/event_structure.dart';
import 'package:live_ffss/app/domain/models/programme_site.dart';

part 'competition_programme.freezed.dart';
part 'competition_programme.g.dart';

@freezed
class CompetitionProgramme with _$CompetitionProgramme {
  const factory CompetitionProgramme({
    required int competitionId,
    // Monotonic counter for local entity ids (races, sites). Starts at 1.
    @Default(1) int nextLocalId,
    @Default(<ProgrammeSite>[]) List<ProgrammeSite> sites,
    @Default(<EventStructure>[]) List<EventStructure> structures,
  }) = _CompetitionProgramme;

  factory CompetitionProgramme.fromJson(Map<String, dynamic> json) =>
      _$CompetitionProgrammeFromJson(json);
}
