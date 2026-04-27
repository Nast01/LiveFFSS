// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDtoImpl _$$UserDtoImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoImpl(
      label: json['label'] as String,
      type: json['type'] as String,
      data: UserDtoData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserDtoImplToJson(_$UserDtoImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'type': instance.type,
      'data': instance.data,
    };

_$UserDtoDataImpl _$$UserDtoDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoDataImpl(
      role: json['role'] as String,
      lastName: json['nom'] as String?,
      firstName: json['prenom'] as String?,
      licenseeNumber: json['numero'] as String?,
      club: json['club'] == null
          ? null
          : UserDtoClub.fromJson(json['club'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserDtoDataImplToJson(_$UserDtoDataImpl instance) =>
    <String, dynamic>{
      'role': instance.role,
      'nom': instance.lastName,
      'prenom': instance.firstName,
      'numero': instance.licenseeNumber,
      'club': instance.club,
    };

_$UserDtoClubImpl _$$UserDtoClubImplFromJson(Map<String, dynamic> json) =>
    _$UserDtoClubImpl(
      label: json['label'] as String,
    );

Map<String, dynamic> _$$UserDtoClubImplToJson(_$UserDtoClubImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
    };
