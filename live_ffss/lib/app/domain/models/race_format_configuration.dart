import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';
import 'package:live_ffss/app/domain/models/race_format_detail.dart';

part 'race_format_configuration.freezed.dart';
part 'race_format_configuration.g.dart';

@freezed
class RaceFormatConfiguration with _$RaceFormatConfiguration {
  const factory RaceFormatConfiguration({
    required int id,
    @Default(0) int competitionId,
    // (disciplineId, gender) + a category is what identifies the épreuve this
    // configuration belongs to — Race ids live in a different namespace.
    @Default(0) int disciplineId,
    required String label,
    required String fullLabel,
    required String gender,
    required String genderLabel,
    required Discipline discipline,
    @Default(<Category>[]) List<Category> categories,
    /// Rounds already defined server-side, ordered. Used to seed the local
    /// structure instead of the flat 8/16 default.
    @Default(<RaceFormatDetail>[]) List<RaceFormatDetail> details,
  }) = _RaceFormatConfiguration;

  factory RaceFormatConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatConfigurationFromJson(json);
}
