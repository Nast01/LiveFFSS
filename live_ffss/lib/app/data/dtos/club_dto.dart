// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/referee_dto.dart';

part 'club_dto.freezed.dart';
part 'club_dto.g.dart';

@freezed
class ClubDto with _$ClubDto {
  const factory ClubDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'label', readValue: _readClubLabel) @Default('') String name,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
    @JsonKey(name: 'athletes')
    @Default(<AthleteDto>[]) List<AthleteDto> athletes,
    @JsonKey(name: 'officiels')
    @Default(<RefereeDto>[]) List<RefereeDto> referees,
  }) = _ClubDto;

  factory ClubDto.fromJson(Map<String, dynamic> json) =>
      _$ClubDtoFromJson(json);
}

// Two FFSS endpoints return clubs with different name keys:
// - GET .../organismes (Clubs pill, doc says "label"): use `label`.
// - GET .../competition/evenement (home list, "organizerClub" embedded):
//   uses `NomCompletOrga` (legacy key, undocumented but observed in prod).
// Try `label` first, fall back to `NomCompletOrga`, ultimately default to ''.
Object? _readClubLabel(Map<dynamic, dynamic> map, String key) {
  final label = map['label'];
  if (label is String && label.isNotEmpty) return label;
  final legacy = map['NomCompletOrga'];
  if (legacy is String && legacy.isNotEmpty) return legacy;
  return '';
}
