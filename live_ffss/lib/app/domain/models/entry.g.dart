// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntryImpl _$$EntryImplFromJson(Map<String, dynamic> json) => _$EntryImpl(
      id: (json['id'] as num).toInt(),
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      status: (json['status'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      entryTime: (json['entryTime'] as num).toInt(),
      entryTimeLabel: json['entryTimeLabel'] as String,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => Athlete.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Athlete>[],
    );

Map<String, dynamic> _$$EntryImplToJson(_$EntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'entryTime': instance.entryTime,
      'entryTimeLabel': instance.entryTimeLabel,
      'athletes': instance.athletes,
    };
