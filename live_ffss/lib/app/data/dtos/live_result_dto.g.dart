// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LiveResultDtoImpl _$$LiveResultDtoImplFromJson(Map<String, dynamic> json) =>
    _$LiveResultDtoImpl(
      id: (json['Id'] as num).toInt(),
      number: json['Numero'] as String? ?? '',
      entry: json['Engagement'] == null
          ? null
          : EntryDto.fromJson(json['Engagement'] as Map<String, dynamic>),
      result: json['Resultat'] == null
          ? null
          : ResultDto.fromJson(json['Resultat'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LiveResultDtoImplToJson(_$LiveResultDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Numero': instance.number,
      'Engagement': instance.entry,
      'Resultat': instance.result,
    };
