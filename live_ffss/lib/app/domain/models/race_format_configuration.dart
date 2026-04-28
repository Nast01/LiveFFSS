import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/domain/models/category.dart';
import 'package:live_ffss/app/domain/models/discipline.dart';

part 'race_format_configuration.freezed.dart';
part 'race_format_configuration.g.dart';

@freezed
class RaceFormatConfiguration with _$RaceFormatConfiguration {
  const factory RaceFormatConfiguration({
    required int id,
    required String label,
    required String fullLabel,
    required String gender,
    required String genderLabel,
    required Discipline discipline,
    @Default(<Category>[]) List<Category> categories,
  }) = _RaceFormatConfiguration;

  factory RaceFormatConfiguration.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatConfigurationFromJson(json);
}
