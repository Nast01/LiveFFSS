// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_format_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceFormatConfigurationImpl _$$RaceFormatConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceFormatConfigurationImpl(
      id: (json['id'] as num).toInt(),
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      gender: json['gender'] as String,
      genderLabel: json['genderLabel'] as String,
      discipline:
          Discipline.fromJson(json['discipline'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Category>[],
    );

Map<String, dynamic> _$$RaceFormatConfigurationImplToJson(
        _$RaceFormatConfigurationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'gender': instance.gender,
      'genderLabel': instance.genderLabel,
      'discipline': instance.discipline,
      'categories': instance.categories,
    };
