// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntryDtoImpl _$$EntryDtoImplFromJson(Map<String, dynamic> json) =>
    _$EntryDtoImpl(
      id: (json['Id'] as num).toInt(),
      category: CategoryDto.fromJson(json['categorie'] as Map<String, dynamic>),
      status: (json['Statut'] as num).toInt(),
      statusLabel: json['statutLabel'] as String,
      entryTime: (json['performance'] as num).toInt(),
      entryTimeLabel: json['performanceLabel'] as String,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => AthleteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AthleteDto>[],
    );

Map<String, dynamic> _$$EntryDtoImplToJson(_$EntryDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'categorie': instance.category,
      'Statut': instance.status,
      'statutLabel': instance.statusLabel,
      'performance': instance.entryTime,
      'performanceLabel': instance.entryTimeLabel,
      'athletes': instance.athletes,
    };
