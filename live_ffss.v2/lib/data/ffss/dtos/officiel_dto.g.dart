// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'officiel_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OfficielDto _$OfficielDtoFromJson(Map<String, dynamic> json) => _OfficielDto(
  id: (readInt(json, 'Id') as num?)?.toInt(),
  firstName: json['Prenom'] as String?,
  lastName: json['Nom'] as String?,
  level: json['Niveau'] as String?,
  principal: json['Principal'] as bool?,
  days: readList(json, 'Jours') as List<dynamic>?,
  daysLabel: json['joursLabel'] as String?,
  club: json['officielClubLabel'] as String?,
);

Map<String, dynamic> _$OfficielDtoToJson(_OfficielDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Prenom': instance.firstName,
      'Nom': instance.lastName,
      'Niveau': instance.level,
      'Principal': instance.principal,
      'Jours': instance.days,
      'joursLabel': instance.daysLabel,
      'officielClubLabel': instance.club,
    };
