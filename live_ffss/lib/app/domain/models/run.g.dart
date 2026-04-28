// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunImpl _$$RunImplFromJson(Map<String, dynamic> json) => _$RunImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      status: $enumDecode(_$RunStatusEnumMap, json['status']),
      statusLabel: json['statusLabel'] as String,
      site: json['site'] as String,
      beginTime: DateTime.parse(json['beginTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      heat: json['heat'] == null
          ? null
          : Heat.fromJson(json['heat'] as Map<String, dynamic>),
      liveResults: (json['liveResults'] as List<dynamic>?)
              ?.map((e) => LiveResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LiveResult>[],
    );

Map<String, dynamic> _$$RunImplToJson(_$RunImpl instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'status': _$RunStatusEnumMap[instance.status]!,
      'statusLabel': instance.statusLabel,
      'site': instance.site,
      'beginTime': instance.beginTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'heat': instance.heat,
      'liveResults': instance.liveResults,
    };

const _$RunStatusEnumMap = {
  RunStatus.waiting: 'waiting',
  RunStatus.marshalling: 'marshalling',
  RunStatus.inProgress: 'inProgress',
  RunStatus.finished: 'finished',
  RunStatus.unknown: 'unknown',
};
