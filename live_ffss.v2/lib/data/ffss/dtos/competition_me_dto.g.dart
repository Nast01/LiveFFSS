// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'competition_me_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompetitionMeDto _$CompetitionMeDtoFromJson(Map<String, dynamic> json) =>
    _CompetitionMeDto(
      roles: readList(json, 'roles') as List<dynamic>? ?? const <Object?>[],
      licensee: readMap(json, 'licencie'),
      official: readMap(json, 'officiel'),
      refereeClubs:
          readList(json, 'referent_sportif') as List<dynamic>? ??
          const <Object?>[],
    );

Map<String, dynamic> _$CompetitionMeDtoToJson(_CompetitionMeDto instance) =>
    <String, dynamic>{
      'roles': instance.roles,
      'licencie': instance.licensee,
      'officiel': instance.official,
      'referent_sportif': instance.refereeClubs,
    };

_LicencieDto _$LicencieDtoFromJson(Map<String, dynamic> json) =>
    _LicencieDto(id: (readInt(json, 'id') as num?)?.toInt());

Map<String, dynamic> _$LicencieDtoToJson(_LicencieDto instance) =>
    <String, dynamic>{'id': instance.id};

_OfficialRoleDto _$OfficialRoleDtoFromJson(Map<String, dynamic> json) =>
    _OfficialRoleDto(
      level: json['niveau'] as String?,
      levelLabel: json['niveauLabel'] as String?,
      principal: json['principal'] as bool?,
    );

Map<String, dynamic> _$OfficialRoleDtoToJson(_OfficialRoleDto instance) =>
    <String, dynamic>{
      'niveau': instance.level,
      'niveauLabel': instance.levelLabel,
      'principal': instance.principal,
    };

_ClubRefDto _$ClubRefDtoFromJson(Map<String, dynamic> json) => _ClubRefDto(
  id: (readInt(json, 'id') as num?)?.toInt(),
  label: json['label'] as String?,
);

Map<String, dynamic> _$ClubRefDtoToJson(_ClubRefDto instance) =>
    <String, dynamic>{'id': instance.id, 'label': instance.label};
