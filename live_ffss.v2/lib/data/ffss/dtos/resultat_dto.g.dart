// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resultat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ResultatDto _$ResultatDtoFromJson(Map<String, dynamic> json) => _ResultatDto(
  id: (_readAnyId(json, 'Id') as num?)?.toInt(),
  time: (readInt(json, 'Temps') as num?)?.toInt(),
  chrono1: (readInt(json, 'TempsLive1') as num?)?.toInt(),
  chrono2: (readInt(json, 'TempsLive2') as num?)?.toInt(),
  chrono3: (readInt(json, 'TempsLive3') as num?)?.toInt(),
  rank: (readInt(json, 'Rang') as num?)?.toInt(),
  status: (readInt(json, 'Statut') as num?)?.toInt(),
  complement: json['complement'],
  points: (readInt(json, 'points') as num?)?.toInt(),
  entry: readMap(json, 'engagement') == null
      ? null
      : ResultatRefDto.fromJson(
          readMap(json, 'engagement') as Map<String, dynamic>,
        ),
  series: readMap(json, 'serie') == null
      ? null
      : ResultatRefDto.fromJson(readMap(json, 'serie') as Map<String, dynamic>),
);

Map<String, dynamic> _$ResultatDtoToJson(_ResultatDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Temps': instance.time,
      'TempsLive1': instance.chrono1,
      'TempsLive2': instance.chrono2,
      'TempsLive3': instance.chrono3,
      'Rang': instance.rank,
      'Statut': instance.status,
      'complement': instance.complement,
      'points': instance.points,
      'engagement': instance.entry,
      'serie': instance.series,
    };

_ResultatRefDto _$ResultatRefDtoFromJson(Map<String, dynamic> json) =>
    _ResultatRefDto(id: (_readAnyId(json, 'Id') as num?)?.toInt());

Map<String, dynamic> _$ResultatRefDtoToJson(_ResultatRefDto instance) =>
    <String, dynamic>{'Id': instance.id};
