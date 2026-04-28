// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_format_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceFormatDetailDtoImpl _$$RaceFormatDetailDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceFormatDetailDtoImpl(
      id: (json['id'] as num).toInt(),
      order: (json['ordre'] as num).toInt(),
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      levelLabel: json['niveauLabel'] as String,
      level: json['niveau'] as String,
      numberOfRun: (json['nbCourses'] as num).toInt(),
      qualificationMethod: json['logiqueQualification'] as String,
      qualificationMethodLabel: json['logiqueQualificationLabel'] as String,
      spotsPerRace: (json['nbPlaceParCourse'] as num).toInt(),
      qualifyingSpots: (json['nbPlaceQualificative'] as num).toInt(),
    );

Map<String, dynamic> _$$RaceFormatDetailDtoImplToJson(
        _$RaceFormatDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordre': instance.order,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'niveauLabel': instance.levelLabel,
      'niveau': instance.level,
      'nbCourses': instance.numberOfRun,
      'logiqueQualification': instance.qualificationMethod,
      'logiqueQualificationLabel': instance.qualificationMethodLabel,
      'nbPlaceParCourse': instance.spotsPerRace,
      'nbPlaceQualificative': instance.qualifyingSpots,
    };
