// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'place_dto.freezed.dart';
part 'place_dto.g.dart';

@freezed
abstract class PlaceDto with _$PlaceDto {
  const factory PlaceDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'Numero', readValue: readInt) int? lane,
    @JsonKey(name: 'engagement', readValue: readMap)
    PlaceEngagementDto? engagement,
    @JsonKey(name: 'resultat', readValue: readMap) PlaceResultDto? result,
  }) = _PlaceDto;

  factory PlaceDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceDtoFromJson(json);
}

@freezed
abstract class PlaceEngagementDto with _$PlaceEngagementDto {
  const factory PlaceEngagementDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'clubLabel') String? clubLabel,
    @JsonKey(name: 'isForfait') bool? isForfeit,
    @JsonKey(name: 'athletes')
    @Default(<PlaceAthleteDto>[])
    List<PlaceAthleteDto> athletes,
    @JsonKey(name: 'EpreuveCategorie', readValue: readMap)
    PlaceEpreuveCategorieDto? epreuveCategorie,
  }) = _PlaceEngagementDto;

  factory PlaceEngagementDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceEngagementDtoFromJson(json);
}

@freezed
abstract class PlaceAthleteDto with _$PlaceAthleteDto {
  const factory PlaceAthleteDto({
    @JsonKey(name: 'publicLabel') String? publicLabel,
  }) = _PlaceAthleteDto;

  factory PlaceAthleteDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceAthleteDtoFromJson(json);
}

@freezed
abstract class PlaceEpreuveCategorieDto with _$PlaceEpreuveCategorieDto {
  const factory PlaceEpreuveCategorieDto({
    @JsonKey(name: 'Categorie', readValue: readMap)
    PlaceCategorieDto? categorie,
    @JsonKey(name: 'Epreuve', readValue: readMap) PlaceEpreuveDto? epreuve,
  }) = _PlaceEpreuveCategorieDto;

  factory PlaceEpreuveCategorieDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceEpreuveCategorieDtoFromJson(json);
}

@freezed
abstract class PlaceCategorieDto with _$PlaceCategorieDto {
  const factory PlaceCategorieDto({@JsonKey(name: 'Nom') String? name}) =
      _PlaceCategorieDto;

  factory PlaceCategorieDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceCategorieDtoFromJson(json);
}

@freezed
abstract class PlaceEpreuveDto with _$PlaceEpreuveDto {
  const factory PlaceEpreuveDto({
    @JsonKey(name: 'Discipline', readValue: readMap)
    PlaceDisciplineDto? discipline,
  }) = _PlaceEpreuveDto;

  factory PlaceEpreuveDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceEpreuveDtoFromJson(json);
}

@freezed
abstract class PlaceDisciplineDto with _$PlaceDisciplineDto {
  const factory PlaceDisciplineDto({@JsonKey(name: 'isRelais') bool? isRelay}) =
      _PlaceDisciplineDto;

  factory PlaceDisciplineDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceDisciplineDtoFromJson(json);
}

@freezed
abstract class PlaceResultDto with _$PlaceResultDto {
  const factory PlaceResultDto({
    @JsonKey(name: 'id', readValue: readInt) int? id,
    @JsonKey(name: 'tempsLabel') String? time,
    @JsonKey(name: 'statutLabel') String? statusLabel,
    @JsonKey(name: 'rangLabel') String? rankLabel,
    @JsonKey(name: 'disqualificationCode') String? disqualificationCode,
    @JsonKey(name: 'isDisqualifie') bool? isDisqualified,
    @JsonKey(name: 'isRecord') bool? isRecord,
    @JsonKey(name: 'isRecordDeFrance') bool? isNationalRecord,
  }) = _PlaceResultDto;

  factory PlaceResultDto.fromJson(Map<String, dynamic> json) =>
      _$PlaceResultDtoFromJson(json);
}
