// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveResultImpl _$$LiveResultImplFromJson(Map<String, dynamic> json) =>
    _$LiveResultImpl(
      id: (json['id'] as num).toInt(),
      number: json['number'] as String? ?? '',
      entry: json['entry'] == null
          ? null
          : Entry.fromJson(json['entry'] as Map<String, dynamic>),
      result: json['result'] == null
          ? null
          : Result.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LiveResultImplToJson(_$LiveResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'entry': instance.entry,
      'result': instance.result,
    };
