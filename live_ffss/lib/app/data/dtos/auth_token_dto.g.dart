// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthTokenDtoImpl _$$AuthTokenDtoImplFromJson(Map<String, dynamic> json) =>
    _$AuthTokenDtoImpl(
      token: json['token'] as String,
      expiration: json['expiration'] as String,
    );

Map<String, dynamic> _$$AuthTokenDtoImplToJson(_$AuthTokenDtoImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'expiration': instance.expiration,
    };
