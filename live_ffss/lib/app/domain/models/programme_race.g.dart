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
      athleteIds: (json['athleteIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      finishOrder: (json['finishOrder'] as List<dynamic>?)
              ?.map((e) =>
                  (e as List<dynamic>).map((e) => (e as num).toInt()).toList())
              .toList() ??
          const <List<int>>[],
      penalties: (json['penalties'] as List<dynamic>?)
              ?.map((e) => CoursePenalty.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CoursePenalty>[],
      runId: (json['runId'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ProgrammeRaceImplToJson(_$ProgrammeRaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'sourceRaceIds': instance.sourceRaceIds,
      'athleteIds': instance.athleteIds,
      'finishOrder': instance.finishOrder,
      'penalties': instance.penalties.map((e) => e.toJson()).toList(),
      'runId': instance.runId,
    };
