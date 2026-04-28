// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_format_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceFormatDetailImpl _$$RaceFormatDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceFormatDetailImpl(
      id: (json['id'] as num).toInt(),
      order: (json['order'] as num).toInt(),
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      levelLabel: json['levelLabel'] as String,
      level: json['level'] as String,
      numberOfRun: (json['numberOfRun'] as num).toInt(),
      qualificationMethod: json['qualificationMethod'] as String,
      qualificationMethodLabel: json['qualificationMethodLabel'] as String,
      spotsPerRace: (json['spotsPerRace'] as num).toInt(),
      qualifyingSpots: (json['qualifyingSpots'] as num).toInt(),
    );

Map<String, dynamic> _$$RaceFormatDetailImplToJson(
        _$RaceFormatDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order': instance.order,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'levelLabel': instance.levelLabel,
      'level': instance.level,
      'numberOfRun': instance.numberOfRun,
      'qualificationMethod': instance.qualificationMethod,
      'qualificationMethodLabel': instance.qualificationMethodLabel,
      'spotsPerRace': instance.spotsPerRace,
      'qualifyingSpots': instance.qualifyingSpots,
    };
