// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryDtoImpl _$$CategoryDtoImplFromJson(Map<String, dynamic> json) =>
    _$CategoryDtoImpl(
      id: (json['Id'] as num).toInt(),
      name: json['Nom'] as String,
      ageMin: (json['AgeMin'] as num?)?.toInt(),
      ageMax: (json['AgeMax'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CategoryDtoImplToJson(_$CategoryDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'AgeMin': instance.ageMin,
      'AgeMax': instance.ageMax,
    };
