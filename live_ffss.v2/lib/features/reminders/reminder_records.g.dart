// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_records.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_KnownHeatDto _$KnownHeatDtoFromJson(Map<String, dynamic> json) =>
    _KnownHeatDto(
      entryId: (json['entryId'] as num?)?.toInt(),
      eventId: (json['eventId'] as num?)?.toInt(),
      heatId: (json['heatId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$KnownHeatDtoToJson(_KnownHeatDto instance) =>
    <String, dynamic>{
      'entryId': instance.entryId,
      'eventId': instance.eventId,
      'heatId': instance.heatId,
    };

_SelfAthleteDto _$SelfAthleteDtoFromJson(Map<String, dynamic> json) =>
    _SelfAthleteDto(
      account: json['account'] as String?,
      athlete: json['athlete'] == null
          ? null
          : FollowedAthleteDto.fromJson(
              json['athlete'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SelfAthleteDtoToJson(_SelfAthleteDto instance) =>
    <String, dynamic>{'account': instance.account, 'athlete': instance.athlete};
