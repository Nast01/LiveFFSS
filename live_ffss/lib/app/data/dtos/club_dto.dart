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
    @JsonKey(name: 'NomCompletOrga') @Default('') String name,
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
