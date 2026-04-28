// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClubDtoImpl _$$ClubDtoImplFromJson(Map<String, dynamic> json) =>
    _$ClubDtoImpl(
      id: (json['Id'] as num).toInt(),
      name: json['NomCompletOrga'] as String,
      shortName: json['NomCourt'] as String?,
      logoUrl: json['logo'] as String?,
      capUrl: json['bonnet'] as String?,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => AthleteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AthleteDto>[],
      referees: (json['officiels'] as List<dynamic>?)
              ?.map((e) => RefereeDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <RefereeDto>[],
    );

Map<String, dynamic> _$$ClubDtoImplToJson(_$ClubDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'NomCompletOrga': instance.name,
      'NomCourt': instance.shortName,
      'logo': instance.logoUrl,
      'bonnet': instance.capUrl,
      'athletes': instance.athletes,
      'officiels': instance.referees,
    };
