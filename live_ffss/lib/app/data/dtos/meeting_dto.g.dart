// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingDtoImpl _$$MeetingDtoImplFromJson(Map<String, dynamic> json) =>
    _$MeetingDtoImpl(
      id: (json['Id'] as num).toInt(),
      name: json['Nom'] as String,
      description: json['Description'] as String,
      date: json['Jour'] as String,
      beginHour: json['Debut'] as String,
      endHour: json['Fin'] as String,
      slots: (json['creneaus'] as List<dynamic>?)
              ?.map((e) => SlotDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <SlotDto>[],
    );

Map<String, dynamic> _$$MeetingDtoImplToJson(_$MeetingDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Description': instance.description,
      'Jour': instance.date,
      'Debut': instance.beginHour,
      'Fin': instance.endHour,
      'creneaus': instance.slots,
    };
