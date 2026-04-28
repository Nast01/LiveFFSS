// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotDtoImpl _$$SlotDtoImplFromJson(Map<String, dynamic> json) =>
    _$SlotDtoImpl(
      id: (json['id'] as num).toInt(),
      name: json['Nom'] as String,
      beginHour: json['Debut'] as String,
      endHour: json['Fin'] as String,
      raceFormatDetail: json['partie'] == null
          ? null
          : RaceFormatDetailDto.fromJson(
              json['partie'] as Map<String, dynamic>),
      runs: (json['courses'] as List<dynamic>?)
              ?.map((e) => RunDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RunDto>[],
    );

Map<String, dynamic> _$$SlotDtoImplToJson(_$SlotDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Nom': instance.name,
      'Debut': instance.beginHour,
      'Fin': instance.endHour,
      'partie': instance.raceFormatDetail,
      'courses': instance.runs,
    };
