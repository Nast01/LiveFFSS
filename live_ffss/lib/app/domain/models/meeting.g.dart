// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeetingImpl _$$MeetingImplFromJson(Map<String, dynamic> json) =>
    _$MeetingImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      beginHour: DateTime.parse(json['beginHour'] as String),
      endHour: DateTime.parse(json['endHour'] as String),
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => Slot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Slot>[],
    );

Map<String, dynamic> _$$MeetingImplToJson(_$MeetingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'date': instance.date.toIso8601String(),
      'beginHour': instance.beginHour.toIso8601String(),
      'endHour': instance.endHour.toIso8601String(),
      'slots': instance.slots,
    };
