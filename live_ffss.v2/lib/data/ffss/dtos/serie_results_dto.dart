// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/epreuve_dto.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'serie_results_dto.freezed.dart';
part 'serie_results_dto.g.dart';

/// Une série de `competition/serie?epreuve=` avec ses résultats. Aucun champ
/// `Licencie` : les données personnelles ne sont pas lues.
@freezed
abstract class SerieResultsDto with _$SerieResultsDto {
  const factory SerieResultsDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Numero', readValue: readInt) int? number,
    @JsonKey(name: 'Nom') String? name,
    @JsonKey(name: 'Debut') String? start,
    @JsonKey(name: 'epreuve', readValue: readMap) EpreuveDto? event,
    // Lignes brutes : le mapper décode chacune seule, pour qu'une ligne mal
    // typée n'emporte pas la série.
    @JsonKey(name: 'resultats') @Default(<Object?>[]) List<Object?> results,
  }) = _SerieResultsDto;

  factory SerieResultsDto.fromJson(Map<String, dynamic> json) =>
      _$SerieResultsDtoFromJson(json);
}

@freezed
abstract class ResultatSerieDto with _$ResultatSerieDto {
  const factory ResultatSerieDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'Statut', readValue: readInt) int? status,
    @JsonKey(name: 'Temps', readValue: readInt) int? time,
    @JsonKey(name: 'complement') String? complement,
    @JsonKey(name: 'Athletes') @Default(<Object?>[]) List<Object?> athletes,
    @JsonKey(name: 'engagement', readValue: readMap) EngagementResultDto? entry,
  }) = _ResultatSerieDto;

  factory ResultatSerieDto.fromJson(Map<String, dynamic> json) =>
      _$ResultatSerieDtoFromJson(json);
}

@freezed
abstract class AthleteResultDto with _$AthleteResultDto {
  const factory AthleteResultDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'label') String? label,
    @JsonKey(name: 'sexe') String? gender,
    @JsonKey(name: 'clubLabel') String? club,
    @JsonKey(name: 'nationaliteCode') String? nationality,
    @JsonKey(name: 'isInvite') bool? isGuest,
  }) = _AthleteResultDto;

  factory AthleteResultDto.fromJson(Map<String, dynamic> json) =>
      _$AthleteResultDtoFromJson(json);
}

@freezed
abstract class EngagementResultDto with _$EngagementResultDto {
  const factory EngagementResultDto({
    @JsonKey(name: 'Id', readValue: readInt) int? id,
    @JsonKey(name: 'IdEpreuve', readValue: readInt) int? eventId,
    @JsonKey(name: 'categorie', readValue: readMap)
    EngagementCategorieDto? category,
    @JsonKey(name: 'clubLabel') String? club,
  }) = _EngagementResultDto;

  factory EngagementResultDto.fromJson(Map<String, dynamic> json) =>
      _$EngagementResultDtoFromJson(json);
}

@freezed
abstract class EngagementCategorieDto with _$EngagementCategorieDto {
  const factory EngagementCategorieDto({@JsonKey(name: 'Nom') String? name}) =
      _EngagementCategorieDto;

  factory EngagementCategorieDto.fromJson(Map<String, dynamic> json) =>
      _$EngagementCategorieDtoFromJson(json);
}
