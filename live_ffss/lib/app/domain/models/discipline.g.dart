// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discipline.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisciplineImpl _$$DisciplineImplFromJson(Map<String, dynamic> json) =>
    _$DisciplineImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      speciality: (json['speciality'] as num).toInt(),
      specialityLabel: json['specialityLabel'] as String,
      distance: (json['distance'] as num?)?.toInt() ?? 0,
      numberOfAthletes: (json['numberOfAthletes'] as num?)?.toInt() ?? 0,
      isRelay: json['isRelay'] as bool? ?? false,
      hasTime: json['hasTime'] as bool? ?? false,
    );

Map<String, dynamic> _$$DisciplineImplToJson(_$DisciplineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'speciality': instance.speciality,
      'specialityLabel': instance.specialityLabel,
      'distance': instance.distance,
      'numberOfAthletes': instance.numberOfAthletes,
      'isRelay': instance.isRelay,
      'hasTime': instance.hasTime,
    };
