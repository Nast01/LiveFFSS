// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme_race.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgrammeRaceImpl _$$ProgrammeRaceImplFromJson(Map<String, dynamic> json) =>
    _$ProgrammeRaceImpl(
      id: (json['id'] as num).toInt(),
      number: (json['number'] as num).toInt(),
      sourceRaceIds: (json['sourceRaceIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      placement: json['placement'] == null
          ? null
          : RacePlacement.fromJson(json['placement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProgrammeRaceImplToJson(_$ProgrammeRaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'sourceRaceIds': instance.sourceRaceIds,
      'placement': instance.placement?.toJson(),
    };
