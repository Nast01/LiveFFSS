// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParticipantDto _$ParticipantDtoFromJson(Map<String, dynamic> json) =>
    _ParticipantDto(
      id: (readInt(json, 'Id') as num?)?.toInt(),
      firstName: json['Prenom'] as String?,
      lastName: json['Nom'] as String?,
      gender: json['Sexe'] as String?,
      club: json['clubLabel'] as String?,
      isGuest: json['isInvite'] as bool?,
      entries:
          (json['engagements'] as List<dynamic>?)
              ?.map(
                (e) => ParticipantEngagementDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const <ParticipantEngagementDto>[],
    );

Map<String, dynamic> _$ParticipantDtoToJson(_ParticipantDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Prenom': instance.firstName,
      'Nom': instance.lastName,
      'Sexe': instance.gender,
      'clubLabel': instance.club,
      'isInvite': instance.isGuest,
      'engagements': instance.entries,
    };

_ParticipantEngagementDto _$ParticipantEngagementDtoFromJson(
  Map<String, dynamic> json,
) => _ParticipantEngagementDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  category: readMap(json, 'categorie') == null
      ? null
      : ParticipantCategorieDto.fromJson(
          readMap(json, 'categorie') as Map<String, dynamic>,
        ),
  event: readMap(json, 'epreuve') == null
      ? null
      : EpreuveDto.fromJson(readMap(json, 'epreuve') as Map<String, dynamic>),
);

Map<String, dynamic> _$ParticipantEngagementDtoToJson(
  _ParticipantEngagementDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'categorie': instance.category,
  'epreuve': instance.event,
};

_ParticipantCategorieDto _$ParticipantCategorieDtoFromJson(
  Map<String, dynamic> json,
) => _ParticipantCategorieDto(label: json['label'] as String?);

Map<String, dynamic> _$ParticipantCategorieDtoToJson(
  _ParticipantCategorieDto instance,
) => <String, dynamic>{'label': instance.label};
