// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_structure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventStructureImpl _$$EventStructureImplFromJson(Map<String, dynamic> json) =>
    _$EventStructureImpl(
      raceId: (json['raceId'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      raceLabel: json['raceLabel'] as String,
      categoryLabel: json['categoryLabel'] as String,
      spotsPerRace: (json['spotsPerRace'] as num?)?.toInt() ?? 8,
      levels: (json['levels'] as List<dynamic>?)
              ?.map((e) => RoundLevel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RoundLevel>[],
    );

Map<String, dynamic> _$$EventStructureImplToJson(
        _$EventStructureImpl instance) =>
    <String, dynamic>{
      'raceId': instance.raceId,
      'categoryId': instance.categoryId,
      'raceLabel': instance.raceLabel,
      'categoryLabel': instance.categoryLabel,
      'spotsPerRace': instance.spotsPerRace,
      'levels': instance.levels.map((e) => e.toJson()).toList(),
    };
