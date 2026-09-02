// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AthleteEntryDtoImpl _$$AthleteEntryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$AthleteEntryDtoImpl(
      category: json['categorie'] == null
          ? null
          : EntryCategoryDto.fromJson(
              json['categorie'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AthleteEntryDtoImplToJson(
        _$AthleteEntryDtoImpl instance) =>
    <String, dynamic>{
      'categorie': instance.category,
    };

_$EntryCategoryDtoImpl _$$EntryCategoryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$EntryCategoryDtoImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['label'] as String? ?? '',
    );

Map<String, dynamic> _$$EntryCategoryDtoImplToJson(
        _$EntryCategoryDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.name,
    };
