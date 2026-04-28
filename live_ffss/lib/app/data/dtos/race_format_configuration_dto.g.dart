// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_format_configuration_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceFormatConfigurationDtoImpl _$$RaceFormatConfigurationDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceFormatConfigurationDtoImpl(
      id: (json['Id'] as num).toInt(),
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      gender: json['Genre'] as String,
      genderLabel: json['genreLabel'] as String,
      discipline:
          DisciplineDto.fromJson(json['Discipline'] as Map<String, dynamic>),
      categories: (_readCategories(json, 'categories') as List<dynamic>?)
              ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CategoryDto>[],
    );

Map<String, dynamic> _$$RaceFormatConfigurationDtoImplToJson(
        _$RaceFormatConfigurationDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'Genre': instance.gender,
      'genreLabel': instance.genderLabel,
      'Discipline': instance.discipline,
      'categories': instance.categories,
    };
