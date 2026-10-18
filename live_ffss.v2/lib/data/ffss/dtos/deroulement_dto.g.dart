// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deroulement_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeroulementDto _$DeroulementDtoFromJson(Map<String, dynamic> json) =>
    _DeroulementDto(
      id: (_readId(json, 'Id') as num?)?.toInt(),
      label: json['label'] as String?,
      disciplineId: (readInt(json, 'IdDiscipline') as num?)?.toInt(),
      gender: json['Genre'] as String?,
      genderLabel: json['genreLabel'] as String?,
      discipline: _readDiscipline(json, 'Discipline') == null
          ? null
          : DeroulementDisciplineDto.fromJson(
              _readDiscipline(json, 'Discipline') as Map<String, dynamic>,
            ),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map(
                (e) =>
                    DeroulementCategorieDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const <DeroulementCategorieDto>[],
      parties:
          (json['parties'] as List<dynamic>?)
              ?.map((e) => PartieDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PartieDto>[],
    );

Map<String, dynamic> _$DeroulementDtoToJson(_DeroulementDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'label': instance.label,
      'IdDiscipline': instance.disciplineId,
      'Genre': instance.gender,
      'genreLabel': instance.genderLabel,
      'Discipline': instance.discipline,
      'categories': instance.categories,
      'parties': instance.parties,
    };

_DeroulementDisciplineDto _$DeroulementDisciplineDtoFromJson(
  Map<String, dynamic> json,
) => _DeroulementDisciplineDto(name: json['Nom'] as String?);

Map<String, dynamic> _$DeroulementDisciplineDtoToJson(
  _DeroulementDisciplineDto instance,
) => <String, dynamic>{'Nom': instance.name};

_DeroulementCategorieDto _$DeroulementCategorieDtoFromJson(
  Map<String, dynamic> json,
) => _DeroulementCategorieDto(name: json['Nom'] as String?);

Map<String, dynamic> _$DeroulementCategorieDtoToJson(
  _DeroulementCategorieDto instance,
) => <String, dynamic>{'Nom': instance.name};

_PartieDto _$PartieDtoFromJson(Map<String, dynamic> json) => _PartieDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  order: (readInt(json, 'ordre') as num?)?.toInt(),
  level: json['niveau'] as String?,
  label: json['label'] as String?,
  heatCount: (readInt(json, 'nbCourses') as num?)?.toInt(),
  placesPerHeat: (readInt(json, 'nbPlaceParCourse') as num?)?.toInt(),
  qualifyingPlaces: (readInt(json, 'nbPlaceQualificative') as num?)?.toInt(),
  qualificationLogic: json['logiqueQualification'] as String?,
  deroulement: readMap(json, 'deroulement') == null
      ? null
      : DeroulementDto.fromJson(
          readMap(json, 'deroulement') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PartieDtoToJson(_PartieDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ordre': instance.order,
      'niveau': instance.level,
      'label': instance.label,
      'nbCourses': instance.heatCount,
      'nbPlaceParCourse': instance.placesPerHeat,
      'nbPlaceQualificative': instance.qualifyingPlaces,
      'logiqueQualification': instance.qualificationLogic,
      'deroulement': instance.deroulement,
    };
