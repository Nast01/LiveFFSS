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
      athletes: json['athletes'] as List<dynamic>? ?? const <dynamic>[],
      referees: json['referees'] as List<dynamic>? ?? const <dynamic>[],
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
