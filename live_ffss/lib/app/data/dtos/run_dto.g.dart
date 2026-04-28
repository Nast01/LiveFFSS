// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RunDtoImpl _$$RunDtoImplFromJson(Map<String, dynamic> json) => _$RunDtoImpl(
      id: (json['id'] as num).toInt(),
      name: json['Nom'] as String,
      label: json['label'] as String,
      fullLabel: json['fullLabel'] as String,
      status: (json['statut'] as num).toInt(),
      statusLabel: json['statutLabel'] as String,
      site: json['site'] as String,
      beginTime: json['debut'] as String,
      endTime: json['fin'] as String,
      heat: json['serie'] == null
          ? null
          : HeatDto.fromJson(json['serie'] as Map<String, dynamic>),
      liveResults: (json['liveResults'] as List<dynamic>?)
              ?.map((e) => LiveResultDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <LiveResultDto>[],
    );

Map<String, dynamic> _$$RunDtoImplToJson(_$RunDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Nom': instance.name,
      'label': instance.label,
      'fullLabel': instance.fullLabel,
      'statut': instance.status,
      'statutLabel': instance.statusLabel,
      'site': instance.site,
      'debut': instance.beginTime,
      'fin': instance.endTime,
      'serie': instance.heat,
      'liveResults': instance.liveResults,
    };
