// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompetitionDtoImpl _$$CompetitionDtoImplFromJson(Map<String, dynamic> json) =>
    _$CompetitionDtoImpl(
      id: (json['Id'] as num).toInt(),
      name: json['Nom'] as String,
      beginDate: json['Debut'] as String?,
      endDate: json['Fin'] as String?,
      beginEntryLimitDate: json['DebutEngagement'] as String?,
      endEntryLimitDate: json['FinEngagement'] as String?,
      location: json['Lieu'] as String?,
      statusCode: (json['Statut'] as num).toInt(),
      statusLabel: json['statutLabel'] as String,
      description: json['Description'] as String?,
      speciality: (json['Specialite'] as num).toInt(),
      specialityLabel: json['specialiteLabel'] as String,
      typeWater: json['water'] as String,
      typePool: json['bassin'] as String,
      typeChrono: json['chronoLabel'] as String,
      isEligibleToNationalRecord: json['isEligibleToNationalRecord'] as bool,
      numberOfLanes: (json['numberOfLanes'] as num?)?.toInt(),
      organisme: CompetitionOrganismeDto.fromJson(
          json['Organisme'] as Map<String, dynamic>),
      hasBegun: json['hasBegun'] as bool,
      hasResult: json['hasResultat'] as bool,
      hasPassed: json['hasPassed'] as bool,
      level: (json['Niveau'] as num).toInt(),
      levelLabel: json['niveauLabel'] as String,
      refereePrincipal: json['JugePrincipal'] as String?,
    );

Map<String, dynamic> _$$CompetitionDtoImplToJson(
        _$CompetitionDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Debut': instance.beginDate,
      'Fin': instance.endDate,
      'DebutEngagement': instance.beginEntryLimitDate,
      'FinEngagement': instance.endEntryLimitDate,
      'Lieu': instance.location,
      'Statut': instance.statusCode,
      'statutLabel': instance.statusLabel,
      'Description': instance.description,
      'Specialite': instance.speciality,
      'specialiteLabel': instance.specialityLabel,
      'water': instance.typeWater,
      'bassin': instance.typePool,
      'chronoLabel': instance.typeChrono,
      'isEligibleToNationalRecord': instance.isEligibleToNationalRecord,
      'numberOfLanes': instance.numberOfLanes,
      'Organisme': instance.organisme,
      'hasBegun': instance.hasBegun,
      'hasResultat': instance.hasResult,
      'hasPassed': instance.hasPassed,
      'Niveau': instance.level,
      'niveauLabel': instance.levelLabel,
      'JugePrincipal': instance.refereePrincipal,
    };

_$CompetitionOrganismeDtoImpl _$$CompetitionOrganismeDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CompetitionOrganismeDtoImpl(
      id: (json['Id'] as num).toInt(),
      organizerName: json['NomOrga'] as String,
      clubFullName: json['NomCompletOrga'] as String?,
      shortName: json['NomCourt'] as String?,
      logoUrl: json['logo'] as String?,
      capUrl: json['bonnet'] as String?,
    );

Map<String, dynamic> _$$CompetitionOrganismeDtoImplToJson(
        _$CompetitionOrganismeDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'NomOrga': instance.organizerName,
      'NomCompletOrga': instance.clubFullName,
      'NomCourt': instance.shortName,
      'logo': instance.logoUrl,
      'bonnet': instance.capUrl,
    };
