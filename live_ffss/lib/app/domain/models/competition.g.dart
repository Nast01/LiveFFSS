// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompetitionImpl _$$CompetitionImplFromJson(Map<String, dynamic> json) =>
    _$CompetitionImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      beginDate: json['beginDate'] == null
          ? null
          : DateTime.parse(json['beginDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      beginEntryLimitDate: json['beginEntryLimitDate'] == null
          ? null
          : DateTime.parse(json['beginEntryLimitDate'] as String),
      endEntryLimitDate: json['endEntryLimitDate'] == null
          ? null
          : DateTime.parse(json['endEntryLimitDate'] as String),
      location: json['location'] as String?,
      statusCode: (json['statusCode'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      description: json['description'] as String?,
      speciality: (json['speciality'] as num).toInt(),
      specialityLabel: json['specialityLabel'] as String,
      typeWater: json['typeWater'] as String,
      typePool: json['typePool'] as String,
      typeChrono: json['typeChrono'] as String,
      isEligibleToNationalRecord: json['isEligibleToNationalRecord'] as bool,
      numberOfLanes: (json['numberOfLanes'] as num).toInt(),
      organizer: json['organizer'] as String,
      hasBegun: json['hasBegun'] as bool,
      hasResult: json['hasResult'] as bool,
      hasPassed: json['hasPassed'] as bool,
      level: (json['level'] as num).toInt(),
      levelLabel: json['levelLabel'] as String,
      organizerClub:
          Club.fromJson(json['organizerClub'] as Map<String, dynamic>),
      refereePrincipal: json['refereePrincipal'] as String?,
    );

Map<String, dynamic> _$$CompetitionImplToJson(_$CompetitionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'beginDate': instance.beginDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'beginEntryLimitDate': instance.beginEntryLimitDate?.toIso8601String(),
      'endEntryLimitDate': instance.endEntryLimitDate?.toIso8601String(),
      'location': instance.location,
      'statusCode': instance.statusCode,
      'statusLabel': instance.statusLabel,
      'description': instance.description,
      'speciality': instance.speciality,
      'specialityLabel': instance.specialityLabel,
      'typeWater': instance.typeWater,
      'typePool': instance.typePool,
      'typeChrono': instance.typeChrono,
      'isEligibleToNationalRecord': instance.isEligibleToNationalRecord,
      'numberOfLanes': instance.numberOfLanes,
      'organizer': instance.organizer,
      'hasBegun': instance.hasBegun,
      'hasResult': instance.hasResult,
      'hasPassed': instance.hasPassed,
      'level': instance.level,
      'levelLabel': instance.levelLabel,
      'organizerClub': instance.organizerClub,
      'refereePrincipal': instance.refereePrincipal,
    };
