// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatDtoImpl _$$HeatDtoImplFromJson(Map<String, dynamic> json) =>
    _$HeatDtoImpl(
      id: (json['Id'] as num).toInt(),
      name: json['Nom'] as String,
      done: json['Fini'] as bool,
      number: (_readNumber(json, 'Numero') as num).toInt(),
    );

Map<String, dynamic> _$$HeatDtoImplToJson(_$HeatDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Fini': instance.done,
      'Numero': instance.number,
    };
