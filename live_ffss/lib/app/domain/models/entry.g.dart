// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntryImpl _$$EntryImplFromJson(Map<String, dynamic> json) => _$EntryImpl(
      id: (json['id'] as num).toInt(),
      raceId: (json['raceId'] as num?)?.toInt() ?? 0,
      category: Category.fromJson(json['category'] as Map<String, dynamic>),
      organisme: json['organisme'] == null
          ? null
          : Club.fromJson(json['organisme'] as Map<String, dynamic>),
      status: (json['status'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      entryTime: (json['entryTime'] as num?)?.toInt() ?? 0,
      entryTimeLabel: json['entryTimeLabel'] as String? ?? '',
      isForfeit: json['isForfeit'] as bool? ?? false,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => Athlete.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Athlete>[],
    );

Map<String, dynamic> _$$EntryImplToJson(_$EntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'raceId': instance.raceId,
      'category': instance.category,
      'organisme': instance.organisme,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'entryTime': instance.entryTime,
      'entryTimeLabel': instance.entryTimeLabel,
      'isForfeit': instance.isForfeit,
      'athletes': instance.athletes,
    };
