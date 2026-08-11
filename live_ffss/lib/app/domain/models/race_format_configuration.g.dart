// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_format_configuration.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceFormatConfigurationImpl _$$RaceFormatConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceFormatConfigurationImpl(
      id: (json['id'] as num).toInt(),
      competitionId: (json['competitionId'] as num?)?.toInt() ?? 0,
      disciplineId: (json['disciplineId'] as num?)?.toInt() ?? 0,
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
      details: (json['details'] as List<dynamic>?)
              ?.map((e) => RaceFormatDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RaceFormatDetail>[],
    );

Map<String, dynamic> _$$RaceFormatConfigurationImplToJson(
        _$RaceFormatConfigurationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'competitionId': instance.competitionId,
      'disciplineId': instance.disciplineId,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'gender': instance.gender,
      'genderLabel': instance.genderLabel,
      'discipline': instance.discipline,
      'categories': instance.categories,
      'details': instance.details,
    };
