// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lane_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LaneDtoImpl _$$LaneDtoImplFromJson(Map<String, dynamic> json) =>
    _$LaneDtoImpl(
      id: (json['id'] as num).toInt(),
      number: (json['Numero'] as num?)?.toInt() ?? 0,
      label: json['label'] as String? ?? '',
      entry: json['engagement'] == null
          ? null
          : EntryDto.fromJson(json['engagement'] as Map<String, dynamic>),
      result: json['resultat'] == null
          ? null
          : ResultDto.fromJson(json['resultat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LaneDtoImplToJson(_$LaneDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Numero': instance.number,
      'label': instance.label,
      'engagement': instance.entry,
      'resultat': instance.result,
    };
