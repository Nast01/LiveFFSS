// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_day_start.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SiteDayStartImpl _$$SiteDayStartImplFromJson(Map<String, dynamic> json) =>
    _$SiteDayStartImpl(
      siteId: (json['siteId'] as num).toInt(),
      day: DateTime.parse(json['day'] as String),
      startMinutes: (json['startMinutes'] as num).toInt(),
    );

Map<String, dynamic> _$$SiteDayStartImplToJson(_$SiteDayStartImpl instance) =>
    <String, dynamic>{
      'siteId': instance.siteId,
      'day': instance.day.toIso8601String(),
      'startMinutes': instance.startMinutes,
    };
