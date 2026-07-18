// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_placement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RacePlacementImpl _$$RacePlacementImplFromJson(Map<String, dynamic> json) =>
    _$RacePlacementImpl(
      siteId: (json['siteId'] as num).toInt(),
      beginHour: DateTime.parse(json['beginHour'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$$RacePlacementImplToJson(_$RacePlacementImpl instance) =>
    <String, dynamic>{
      'siteId': instance.siteId,
      'beginHour': instance.beginHour.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
    };
