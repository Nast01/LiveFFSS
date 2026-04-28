// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotImpl _$$SlotImplFromJson(Map<String, dynamic> json) => _$SlotImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      beginHour: DateTime.parse(json['beginHour'] as String),
      endHour: DateTime.parse(json['endHour'] as String),
      raceFormatDetail: json['raceFormatDetail'] == null
          ? null
          : RaceFormatDetail.fromJson(
              json['raceFormatDetail'] as Map<String, dynamic>),
      runs: (json['runs'] as List<dynamic>?)
              ?.map((e) => Run.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Run>[],
    );

Map<String, dynamic> _$$SlotImplToJson(_$SlotImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'beginHour': instance.beginHour.toIso8601String(),
      'endHour': instance.endHour.toIso8601String(),
      'raceFormatDetail': instance.raceFormatDetail,
      'runs': instance.runs,
    };
