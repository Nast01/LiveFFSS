// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programme_site.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgrammeSiteImpl _$$ProgrammeSiteImplFromJson(Map<String, dynamic> json) =>
    _$ProgrammeSiteImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: $enumDecode(_$SiteTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$ProgrammeSiteImplToJson(_$ProgrammeSiteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$SiteTypeEnumMap[instance.type]!,
    };

const _$SiteTypeEnumMap = {
  SiteType.cotier: 'cotier',
  SiteType.sable: 'sable',
  SiteType.unknown: 'unknown',
};
