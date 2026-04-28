import 'package:freezed_annotation/freezed_annotation.dart';

part 'race_format_detail.freezed.dart';
part 'race_format_detail.g.dart';

@freezed
class RaceFormatDetail with _$RaceFormatDetail {
  const factory RaceFormatDetail({
    required int id,
    required int order,
    required String label,
    required String fullLabel,
    required String levelLabel,
    required String level,
    required int numberOfRun,
    required String qualificationMethod,
    required String qualificationMethodLabel,
    required int spotsPerRace,
    required int qualifyingSpots,
  }) = _RaceFormatDetail;

  factory RaceFormatDetail.fromJson(Map<String, dynamic> json) =>
      _$RaceFormatDetailFromJson(json);
}
