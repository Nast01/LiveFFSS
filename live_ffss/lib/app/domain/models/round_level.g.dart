// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round_level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoundLevelImpl _$$RoundLevelImplFromJson(Map<String, dynamic> json) =>
    _$RoundLevelImpl(
      type: $enumDecode(_$RoundTypeEnumMap, json['type'],
          unknownValue: RoundType.unknown),
      qualifiersPerRace: (json['qualifiersPerRace'] as num?)?.toInt() ?? 0,
      spotsPerRace: (json['spotsPerRace'] as num?)?.toInt() ?? 0,
      serverId: (json['serverId'] as num?)?.toInt() ?? 0,
      qualificationMethod:
          json['qualificationMethod'] as String? ?? qualificationNone,
      races: (json['races'] as List<dynamic>?)
              ?.map((e) => ProgrammeRace.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProgrammeRace>[],
    );

Map<String, dynamic> _$$RoundLevelImplToJson(_$RoundLevelImpl instance) =>
    <String, dynamic>{
      'type': _$RoundTypeEnumMap[instance.type]!,
      'qualifiersPerRace': instance.qualifiersPerRace,
      'spotsPerRace': instance.spotsPerRace,
      'serverId': instance.serverId,
      'qualificationMethod': instance.qualificationMethod,
      'races': instance.races,
    };

const _$RoundTypeEnumMap = {
  RoundType.serie: 'serie',
  RoundType.quart: 'quart',
  RoundType.demi: 'demi',
  RoundType.finale: 'finale',
  RoundType.unknown: 'unknown',
};
