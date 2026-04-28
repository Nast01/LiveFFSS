// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClubImpl _$$ClubImplFromJson(Map<String, dynamic> json) => _$ClubImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      shortName: json['shortName'] as String?,
      logoUrl: json['logoUrl'] as String?,
      capUrl: json['capUrl'] as String?,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => Athlete.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Athlete>[],
      referees: (json['referees'] as List<dynamic>?)
              ?.map((e) => Referee.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Referee>[],
    );

Map<String, dynamic> _$$ClubImplToJson(_$ClubImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'shortName': instance.shortName,
      'logoUrl': instance.logoUrl,
      'capUrl': instance.capUrl,
      'athletes': instance.athletes,
      'referees': instance.referees,
    };
