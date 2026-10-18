// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follows_providers.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowsDto _$FollowsDtoFromJson(Map<String, dynamic> json) => _FollowsDto(
  athletes: (json['athletes'] as List<dynamic>?)
      ?.map((e) => FollowedAthleteDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  clubs: (json['clubs'] as List<dynamic>?)
      ?.map((e) => FollowedClubDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FollowsDtoToJson(_FollowsDto instance) =>
    <String, dynamic>{'athletes': instance.athletes, 'clubs': instance.clubs};

_FollowedAthleteDto _$FollowedAthleteDtoFromJson(Map<String, dynamic> json) =>
    _FollowedAthleteDto(
      participantId: (json['participantId'] as num?)?.toInt(),
      name: json['name'] as String?,
      club: json['club'] as String?,
      entryIds: (json['entryIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      eventIds: (json['eventIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$FollowedAthleteDtoToJson(_FollowedAthleteDto instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'name': instance.name,
      'club': instance.club,
      'entryIds': instance.entryIds,
      'eventIds': instance.eventIds,
    };

_FollowedClubDto _$FollowedClubDtoFromJson(Map<String, dynamic> json) =>
    _FollowedClubDto(
      id: (json['id'] as num?)?.toInt(),
      label: json['label'] as String?,
    );

Map<String, dynamic> _$FollowedClubDtoToJson(_FollowedClubDto instance) =>
    <String, dynamic>{'id': instance.id, 'label': instance.label};
