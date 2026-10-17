// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reunion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReunionDto _$ReunionDtoFromJson(Map<String, dynamic> json) => _ReunionDto(
  id: (readInt(json, 'Id') as num?)?.toInt(),
  name: json['Nom'] as String?,
  day: json['Jour'] as String?,
  start: json['Debut'] as String?,
  end: json['Fin'] as String?,
  creneaus:
      (json['creneaus'] as List<dynamic>?)
          ?.map((e) => CreneauDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CreneauDto>[],
);

Map<String, dynamic> _$ReunionDtoToJson(_ReunionDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Jour': instance.day,
      'Debut': instance.start,
      'Fin': instance.end,
      'creneaus': instance.creneaus,
    };

_CreneauDto _$CreneauDtoFromJson(Map<String, dynamic> json) => _CreneauDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  name: json['Nom'] as String?,
  start: json['Debut'] as String?,
  end: json['Fin'] as String?,
  partie: readMap(json, 'partie') == null
      ? null
      : PartieDto.fromJson(readMap(json, 'partie') as Map<String, dynamic>),
  courses:
      (json['courses'] as List<dynamic>?)
          ?.map((e) => CourseDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CourseDto>[],
);

Map<String, dynamic> _$CreneauDtoToJson(_CreneauDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Nom': instance.name,
      'Debut': instance.start,
      'Fin': instance.end,
      'partie': instance.partie,
      'courses': instance.courses,
    };

_CourseDto _$CourseDtoFromJson(Map<String, dynamic> json) => _CourseDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  name: json['Nom'] as String?,
  status: (readInt(json, 'statut') as num?)?.toInt(),
  start: json['debut'] as String?,
  end: json['fin'] as String?,
  places:
      (json['places'] as List<dynamic>?)
          ?.map((e) => PlaceRefDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <PlaceRefDto>[],
  serie: readMap(json, 'serie') == null
      ? null
      : SerieDto.fromJson(readMap(json, 'serie') as Map<String, dynamic>),
);

Map<String, dynamic> _$CourseDtoToJson(_CourseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Nom': instance.name,
      'statut': instance.status,
      'debut': instance.start,
      'fin': instance.end,
      'places': instance.places,
      'serie': instance.serie,
    };

_PlaceRefDto _$PlaceRefDtoFromJson(Map<String, dynamic> json) => _PlaceRefDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  number: (readInt(json, 'Numero') as num?)?.toInt(),
);

Map<String, dynamic> _$PlaceRefDtoToJson(_PlaceRefDto instance) =>
    <String, dynamic>{'id': instance.id, 'Numero': instance.number};

_SerieDto _$SerieDtoFromJson(Map<String, dynamic> json) => _SerieDto(
  id: (_readSerieId(json, 'Id') as num?)?.toInt(),
  name: json['Nom'] as String?,
  number: (readInt(json, 'Numero') as num?)?.toInt(),
  epreuve: readMap(json, 'epreuve') == null
      ? null
      : EpreuveRefDto.fromJson(
          readMap(json, 'epreuve') as Map<String, dynamic>,
        ),
  label: json['label'] as String?,
);

Map<String, dynamic> _$SerieDtoToJson(_SerieDto instance) => <String, dynamic>{
  'Id': instance.id,
  'Nom': instance.name,
  'Numero': instance.number,
  'epreuve': instance.epreuve,
  'label': instance.label,
};

_EpreuveRefDto _$EpreuveRefDtoFromJson(Map<String, dynamic> json) =>
    _EpreuveRefDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      gender: json['Genre'] as String?,
      discipline: readMap(json, 'discipline') == null
          ? null
          : DisciplineRefDto.fromJson(
              readMap(json, 'discipline') as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$EpreuveRefDtoToJson(_EpreuveRefDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Genre': instance.gender,
      'discipline': instance.discipline,
    };

_DisciplineRefDto _$DisciplineRefDtoFromJson(Map<String, dynamic> json) =>
    _DisciplineRefDto(name: json['Nom'] as String?);

Map<String, dynamic> _$DisciplineRefDtoToJson(_DisciplineRefDto instance) =>
    <String, dynamic>{'Nom': instance.name};
