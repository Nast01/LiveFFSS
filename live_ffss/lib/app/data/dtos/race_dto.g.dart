// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceDtoImpl _$$RaceDtoImplFromJson(Map<String, dynamic> json) =>
    _$RaceDtoImpl(
      id: (json['Id'] as num).toInt(),
      disciplineId: (json['IdDiscipline'] as num).toInt(),
      gender: json['Genre'] as String,
      isEligibleToNationalRecord:
          json['isEligibleToNationalRecord'] as bool? ?? false,
      discipline: RaceDisciplineDto.fromJson(
          json['discipline'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CategoryDto>[],
    );

Map<String, dynamic> _$$RaceDtoImplToJson(_$RaceDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'IdDiscipline': instance.disciplineId,
      'Genre': instance.gender,
      'isEligibleToNationalRecord': instance.isEligibleToNationalRecord,
      'discipline': instance.discipline,
      'categories': instance.categories,
    };

_$RaceDisciplineDtoImpl _$$RaceDisciplineDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$RaceDisciplineDtoImpl(
      name: json['Nom'] as String,
      nameEnglish: json['NomEn'] as String,
      distance: (json['Distance'] as num?)?.toInt() ?? 0,
      athletesPerTeam: (json['NbAthleteParEquipe'] as num?)?.toInt() ?? 1,
      specialityId: (json['Specialite'] as num).toInt(),
      specialityLabel: json['specialiteLabel'] as String,
    );

Map<String, dynamic> _$$RaceDisciplineDtoImplToJson(
        _$RaceDisciplineDtoImpl instance) =>
    <String, dynamic>{
      'Nom': instance.name,
      'NomEn': instance.nameEnglish,
      'Distance': instance.distance,
      'NbAthleteParEquipe': instance.athletesPerTeam,
      'Specialite': instance.specialityId,
      'specialiteLabel': instance.specialityLabel,
    };
