// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatImpl _$$HeatImplFromJson(Map<String, dynamic> json) => _$HeatImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      done: json['done'] as bool,
      number: (json['number'] as num).toInt(),
    );

Map<String, dynamic> _$$HeatImplToJson(_$HeatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'done': instance.done,
      'number': instance.number,
    };
