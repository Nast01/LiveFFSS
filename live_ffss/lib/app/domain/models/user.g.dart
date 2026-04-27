// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      token: json['token'] as String,
      tokenExpiration: DateTime.parse(json['tokenExpiration'] as String),
      label: json['label'] as String,
      type: $enumDecode(_$UserTypeEnumMap, json['type']),
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      licenseeNumber: json['licenseeNumber'] as String?,
      clubName: json['clubName'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'tokenExpiration': instance.tokenExpiration.toIso8601String(),
      'label': instance.label,
      'type': _$UserTypeEnumMap[instance.type]!,
      'role': _$UserRoleEnumMap[instance.role]!,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'licenseeNumber': instance.licenseeNumber,
      'clubName': instance.clubName,
    };

const _$UserTypeEnumMap = {
  UserType.licensee: 'licensee',
  UserType.organisme: 'organisme',
  UserType.unknown: 'unknown',
};

const _$UserRoleEnumMap = {
  UserRole.admin: 'admin',
  UserRole.user: 'user',
  UserRole.unknown: 'unknown',
};
