// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evenement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EvenementDto _$EvenementDtoFromJson(Map<String, dynamic> json) =>
    _EvenementDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      name: json['Nom'] as String?,
      startDate: json['Debut'] as String?,
      endDate: json['Fin'] as String?,
      speciality: (readInt(json, 'Specialite') as num?)?.toInt(),
      specialityLabel: json['specialiteLabel'] as String?,
      location: json['Lieu'] as String?,
      organisme: readMap(json, 'Organisme') == null
          ? null
          : OrganismeRefDto.fromJson(
              readMap(json, 'Organisme') as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EvenementDtoToJson(_EvenementDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Debut': instance.startDate,
      'Fin': instance.endDate,
      'Specialite': instance.speciality,
      'specialiteLabel': instance.specialityLabel,
      'Lieu': instance.location,
      'Organisme': instance.organisme,
    };

_OrganismeRefDto _$OrganismeRefDtoFromJson(Map<String, dynamic> json) =>
    _OrganismeRefDto(
      name: json['NomOrga'] as String?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$OrganismeRefDtoToJson(_OrganismeRefDto instance) =>
    <String, dynamic>{'NomOrga': instance.name, 'label': instance.label};
