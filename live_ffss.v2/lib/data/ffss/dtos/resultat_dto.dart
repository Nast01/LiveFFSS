// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss_v2/data/ffss/dtos/json_readers.dart';

part 'resultat_dto.freezed.dart';
part 'resultat_dto.g.dart';

/// FFSS sert l'id d'un objet tantôt en `Id`, tantôt en `id`, parfois les deux
/// dans le même objet.
Object? _readAnyId(Map<dynamic, dynamic> json, String key) =>
    readInt(json, 'Id') ?? readInt(json, 'id');

@freezed
abstract class ResultatDto with _$ResultatDto {
  const factory ResultatDto({
    @JsonKey(name: 'Id', readValue: _readAnyId) int? id,
    @JsonKey(name: 'Temps', readValue: readInt) int? time,
    @JsonKey(name: 'TempsLive1', readValue: readInt) int? chrono1,
    @JsonKey(name: 'TempsLive2', readValue: readInt) int? chrono2,
    @JsonKey(name: 'TempsLive3', readValue: readInt) int? chrono3,
    @JsonKey(name: 'Rang', readValue: readInt) int? rank,
    @JsonKey(name: 'Statut', readValue: readInt) int? status,
    @JsonKey(name: 'complement') Object? complement,
    @JsonKey(name: 'points', readValue: readInt) int? points,
    @JsonKey(name: 'engagement', readValue: readMap) ResultatRefDto? entry,
    @JsonKey(name: 'serie', readValue: readMap) ResultatRefDto? series,
  }) = _ResultatDto;

  factory ResultatDto.fromJson(Map<String, dynamic> json) =>
      _$ResultatDtoFromJson(json);
}

/// L'engagement ou la série d'un résultat : seul l'id compte.
@freezed
abstract class ResultatRefDto with _$ResultatRefDto {
  const factory ResultatRefDto({
    @JsonKey(name: 'Id', readValue: _readAnyId) int? id,
  }) = _ResultatRefDto;

  factory ResultatRefDto.fromJson(Map<String, dynamic> json) =>
      _$ResultatRefDtoFromJson(json);
}
