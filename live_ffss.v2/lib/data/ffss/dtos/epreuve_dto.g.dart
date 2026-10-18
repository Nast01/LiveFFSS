// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'epreuve_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EpreuveDto _$EpreuveDtoFromJson(Map<String, dynamic> json) => _EpreuveDto(
  id: (readInt(json, 'Id') as num?)?.toInt(),
  disciplineId: (readInt(json, 'IdDiscipline') as num?)?.toInt(),
  gender: json['Genre'] as String?,
  discipline: readMap(json, 'discipline') == null
      ? null
      : EpreuveDisciplineDto.fromJson(
          readMap(json, 'discipline') as Map<String, dynamic>,
        ),
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => EpreuveCategorieDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <EpreuveCategorieDto>[],
);

Map<String, dynamic> _$EpreuveDtoToJson(_EpreuveDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'IdDiscipline': instance.disciplineId,
      'Genre': instance.gender,
      'discipline': instance.discipline,
      'categories': instance.categories,
    };

_EpreuveDisciplineDto _$EpreuveDisciplineDtoFromJson(
  Map<String, dynamic> json,
) => _EpreuveDisciplineDto(
  label: json['label'] as String?,
  name: json['Nom'] as String?,
  teamSize: (readInt(json, 'NbAthleteParEquipe') as num?)?.toInt(),
);

Map<String, dynamic> _$EpreuveDisciplineDtoToJson(
  _EpreuveDisciplineDto instance,
) => <String, dynamic>{
  'label': instance.label,
  'Nom': instance.name,
  'NbAthleteParEquipe': instance.teamSize,
};

_EpreuveCategorieDto _$EpreuveCategorieDtoFromJson(Map<String, dynamic> json) =>
    _EpreuveCategorieDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      name: json['Nom'] as String?,
    );

Map<String, dynamic> _$EpreuveCategorieDtoToJson(
  _EpreuveCategorieDto instance,
) => <String, dynamic>{'Id': instance.id, 'Nom': instance.name};
