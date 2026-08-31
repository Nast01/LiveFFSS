// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lane.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LaneImpl _$$LaneImplFromJson(Map<String, dynamic> json) => _$LaneImpl(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      entry: json['entry'] == null
          ? null
          : Entry.fromJson(json['entry'] as Map<String, dynamic>),
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LaneImplToJson(_$LaneImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'label': instance.label,
      'entry': instance.entry,
      'result': instance.result,
    };
