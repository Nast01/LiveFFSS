// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serie_results_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SerieResultsDto _$SerieResultsDtoFromJson(Map<String, dynamic> json) =>
    _SerieResultsDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      number: (readInt(json, 'Numero') as num?)?.toInt(),
      name: json['Nom'] as String?,
      start: json['Debut'] as String?,
      event: readMap(json, 'epreuve') == null
          ? null
          : EpreuveDto.fromJson(
              readMap(json, 'epreuve') as Map<String, dynamic>,
            ),
      results:
          (json['resultats'] as List<dynamic>?)
              ?.map((e) => ResultatSerieDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ResultatSerieDto>[],
    );

Map<String, dynamic> _$SerieResultsDtoToJson(_SerieResultsDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Numero': instance.number,
      'Nom': instance.name,
      'Debut': instance.start,
      'epreuve': instance.event,
      'resultats': instance.results,
    };

_ResultatSerieDto _$ResultatSerieDtoFromJson(Map<String, dynamic> json) =>
    _ResultatSerieDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      status: (readInt(json, 'Statut') as num?)?.toInt(),
      time: (readInt(json, 'Temps') as num?)?.toInt(),
      complement: json['complement'] as String?,
      athletes:
          (json['Athletes'] as List<dynamic>?)
              ?.map((e) => AthleteResultDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AthleteResultDto>[],
      entry: readMap(json, 'engagement') == null
          ? null
          : EngagementResultDto.fromJson(
              readMap(json, 'engagement') as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ResultatSerieDtoToJson(_ResultatSerieDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Statut': instance.status,
      'Temps': instance.time,
      'complement': instance.complement,
      'Athletes': instance.athletes,
      'engagement': instance.entry,
    };

_AthleteResultDto _$AthleteResultDtoFromJson(Map<String, dynamic> json) =>
    _AthleteResultDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      label: json['label'] as String?,
      gender: json['sexe'] as String?,
      club: json['clubLabel'] as String?,
      nationality: json['nationaliteCode'] as String?,
      isGuest: json['isInvite'] as bool?,
    );

Map<String, dynamic> _$AthleteResultDtoToJson(_AthleteResultDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'label': instance.label,
      'sexe': instance.gender,
      'clubLabel': instance.club,
      'nationaliteCode': instance.nationality,
      'isInvite': instance.isGuest,
    };

_EngagementResultDto _$EngagementResultDtoFromJson(Map<String, dynamic> json) =>
    _EngagementResultDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      eventId: (readInt(json, 'IdEpreuve') as num?)?.toInt(),
      category: readMap(json, 'categorie') == null
          ? null
          : EngagementCategorieDto.fromJson(
              readMap(json, 'categorie') as Map<String, dynamic>,
            ),
      club: json['clubLabel'] as String?,
    );

Map<String, dynamic> _$EngagementResultDtoToJson(
  _EngagementResultDto instance,
) => <String, dynamic>{
  'Id': instance.id,
  'IdEpreuve': instance.eventId,
  'categorie': instance.category,
  'clubLabel': instance.club,
};

_EngagementCategorieDto _$EngagementCategorieDtoFromJson(
  Map<String, dynamic> json,
) => _EngagementCategorieDto(name: json['Nom'] as String?);

Map<String, dynamic> _$EngagementCategorieDtoToJson(
  _EngagementCategorieDto instance,
) => <String, dynamic>{'Nom': instance.name};
