// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discipline_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DisciplineDtoImpl _$$DisciplineDtoImplFromJson(Map<String, dynamic> json) =>
    _$DisciplineDtoImpl(
      id: json['Id'] as String,
      name: json['Nom'] as String,
      speciality: (json['specialite'] as num).toInt(),
      specialityLabel: json['specialiteLabel'] as String? ?? '',
      distance: (json['distance'] as num?)?.toInt() ?? 0,
      numberOfAthletes: (json['nbAthleteParEquipe'] as num?)?.toInt() ?? 0,
      isRelay: json['isRelais'] as bool? ?? false,
      hasTime: json['hasTemps'] as bool? ?? false,
    );

Map<String, dynamic> _$$DisciplineDtoImplToJson(_$DisciplineDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'specialite': instance.speciality,
      'specialiteLabel': instance.specialityLabel,
      'distance': instance.distance,
      'nbAthleteParEquipe': instance.numberOfAthletes,
      'isRelais': instance.isRelay,
      'hasTemps': instance.hasTime,
    };
