// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EntryDtoImpl _$$EntryDtoImplFromJson(Map<String, dynamic> json) =>
    _$EntryDtoImpl(
      id: (json['Id'] as num).toInt(),
      raceId: (json['IdEpreuve'] as num?)?.toInt() ?? 0,
      category: CategoryDto.fromJson(json['categorie'] as Map<String, dynamic>),
      organismeId: (json['IdOrganisme'] as num?)?.toInt() ?? 0,
      organisme: json['Organisme'] == null
          ? null
          : ClubDto.fromJson(json['Organisme'] as Map<String, dynamic>),
      status: (json['Statut'] as num).toInt(),
      statusLabel: json['statutLabel'] as String,
      entryTime: (json['performance'] as num?)?.toInt() ?? 0,
      entryTimeLabel: json['performanceLabel'] as String? ?? '',
      isForfeit: json['forfait'] as bool? ?? false,
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => AthleteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AthleteDto>[],
    );

Map<String, dynamic> _$$EntryDtoImplToJson(_$EntryDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'IdEpreuve': instance.raceId,
      'categorie': instance.category,
      'IdOrganisme': instance.organismeId,
      'Organisme': instance.organisme,
      'Statut': instance.status,
      'statutLabel': instance.statusLabel,
      'performance': instance.entryTime,
      'performanceLabel': instance.entryTimeLabel,
      'forfait': instance.isForfeit,
      'athletes': instance.athletes,
    };
