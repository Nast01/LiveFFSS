// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_programme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompetitionProgrammeImpl _$$CompetitionProgrammeImplFromJson(
        Map<String, dynamic> json) =>
    _$CompetitionProgrammeImpl(
      competitionId: (json['competitionId'] as num).toInt(),
      nextLocalId: (json['nextLocalId'] as num?)?.toInt() ?? 1,
      sites: (json['sites'] as List<dynamic>?)
              ?.map((e) => ProgrammeSite.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ProgrammeSite>[],
      structures: (json['structures'] as List<dynamic>?)
              ?.map((e) => EventStructure.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <EventStructure>[],
    );

Map<String, dynamic> _$$CompetitionProgrammeImplToJson(
        _$CompetitionProgrammeImpl instance) =>
    <String, dynamic>{
      'competitionId': instance.competitionId,
      'nextLocalId': instance.nextLocalId,
      'sites': instance.sites,
      'structures': instance.structures,
    };
