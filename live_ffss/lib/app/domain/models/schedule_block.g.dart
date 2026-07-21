// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_block.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleBlockImpl _$$ScheduleBlockImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleBlockImpl(
      id: (json['id'] as num).toInt(),
      siteId: (json['siteId'] as num).toInt(),
      day: DateTime.parse(json['day'] as String),
      order: (json['order'] as num).toInt(),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 10,
      raceId: (json['raceId'] as num?)?.toInt(),
      manualLabel: json['manualLabel'] as String? ?? '',
    );

Map<String, dynamic> _$$ScheduleBlockImplToJson(_$ScheduleBlockImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'siteId': instance.siteId,
      'day': instance.day.toIso8601String(),
      'order': instance.order,
      'durationMinutes': instance.durationMinutes,
      'raceId': instance.raceId,
      'manualLabel': instance.manualLabel,
    };
