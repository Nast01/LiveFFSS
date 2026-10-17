// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlaceDto _$PlaceDtoFromJson(Map<String, dynamic> json) => _PlaceDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  lane: (readInt(json, 'Numero') as num?)?.toInt(),
  engagement: readMap(json, 'engagement') == null
      ? null
      : PlaceEngagementDto.fromJson(
          readMap(json, 'engagement') as Map<String, dynamic>,
        ),
  result: readMap(json, 'resultat') == null
      ? null
      : PlaceResultDto.fromJson(
          readMap(json, 'resultat') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PlaceDtoToJson(_PlaceDto instance) => <String, dynamic>{
  'id': instance.id,
  'Numero': instance.lane,
  'engagement': instance.engagement,
  'resultat': instance.result,
};

_PlaceEngagementDto _$PlaceEngagementDtoFromJson(Map<String, dynamic> json) =>
    _PlaceEngagementDto(
      clubLabel: json['clubLabel'] as String?,
      isForfeit: json['isForfait'] as bool?,
      athletes:
          (json['athletes'] as List<dynamic>?)
              ?.map((e) => PlaceAthleteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <PlaceAthleteDto>[],
      epreuveCategorie: readMap(json, 'EpreuveCategorie') == null
          ? null
          : PlaceEpreuveCategorieDto.fromJson(
              readMap(json, 'EpreuveCategorie') as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PlaceEngagementDtoToJson(_PlaceEngagementDto instance) =>
    <String, dynamic>{
      'clubLabel': instance.clubLabel,
      'isForfait': instance.isForfeit,
      'athletes': instance.athletes,
      'EpreuveCategorie': instance.epreuveCategorie,
    };

_PlaceAthleteDto _$PlaceAthleteDtoFromJson(Map<String, dynamic> json) =>
    _PlaceAthleteDto(publicLabel: json['publicLabel'] as String?);

Map<String, dynamic> _$PlaceAthleteDtoToJson(_PlaceAthleteDto instance) =>
    <String, dynamic>{'publicLabel': instance.publicLabel};

_PlaceEpreuveCategorieDto _$PlaceEpreuveCategorieDtoFromJson(
  Map<String, dynamic> json,
) => _PlaceEpreuveCategorieDto(
  categorie: readMap(json, 'Categorie') == null
      ? null
      : PlaceCategorieDto.fromJson(
          readMap(json, 'Categorie') as Map<String, dynamic>,
        ),
  epreuve: readMap(json, 'Epreuve') == null
      ? null
      : PlaceEpreuveDto.fromJson(
          readMap(json, 'Epreuve') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$PlaceEpreuveCategorieDtoToJson(
  _PlaceEpreuveCategorieDto instance,
) => <String, dynamic>{
  'Categorie': instance.categorie,
  'Epreuve': instance.epreuve,
};

_PlaceCategorieDto _$PlaceCategorieDtoFromJson(Map<String, dynamic> json) =>
    _PlaceCategorieDto(name: json['Nom'] as String?);

Map<String, dynamic> _$PlaceCategorieDtoToJson(_PlaceCategorieDto instance) =>
    <String, dynamic>{'Nom': instance.name};

_PlaceEpreuveDto _$PlaceEpreuveDtoFromJson(Map<String, dynamic> json) =>
    _PlaceEpreuveDto(
      discipline: readMap(json, 'Discipline') == null
          ? null
          : PlaceDisciplineDto.fromJson(
              readMap(json, 'Discipline') as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PlaceEpreuveDtoToJson(_PlaceEpreuveDto instance) =>
    <String, dynamic>{'Discipline': instance.discipline};

_PlaceDisciplineDto _$PlaceDisciplineDtoFromJson(Map<String, dynamic> json) =>
    _PlaceDisciplineDto(isRelay: json['isRelais'] as bool?);

Map<String, dynamic> _$PlaceDisciplineDtoToJson(_PlaceDisciplineDto instance) =>
    <String, dynamic>{'isRelais': instance.isRelay};

_PlaceResultDto _$PlaceResultDtoFromJson(Map<String, dynamic> json) =>
    _PlaceResultDto(
      time: json['tempsLabel'] as String?,
      statusLabel: json['statutLabel'] as String?,
      rankLabel: json['rangLabel'] as String?,
      disqualificationCode: json['disqualificationCode'] as String?,
      isDisqualified: json['isDisqualifie'] as bool?,
      isRecord: json['isRecord'] as bool?,
      isNationalRecord: json['isRecordDeFrance'] as bool?,
    );

Map<String, dynamic> _$PlaceResultDtoToJson(_PlaceResultDto instance) =>
    <String, dynamic>{
      'tempsLabel': instance.time,
      'statutLabel': instance.statusLabel,
      'rangLabel': instance.rankLabel,
      'disqualificationCode': instance.disqualificationCode,
      'isDisqualifie': instance.isDisqualified,
      'isRecord': instance.isRecord,
      'isRecordDeFrance': instance.isNationalRecord,
    };
