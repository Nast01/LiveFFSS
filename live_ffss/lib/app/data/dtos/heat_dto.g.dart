// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatDtoImpl _$$HeatDtoImplFromJson(Map<String, dynamic> json) =>
    _$HeatDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
      name: json['Nom'] as String? ?? '',
      done: json['Fini'] as bool? ?? false,
      number: (_readNumber(json, 'Numero') as num?)?.toInt() ?? 0,
      updatedAt: json['UpdatedAt'] as String?,
      startDate: json['Debut'] as String?,
      endDate: json['Fin'] as String?,
      race: json['epreuve'] == null
          ? null
          : RaceDto.fromJson(json['epreuve'] as Map<String, dynamic>),
      results: (json['resultats'] as List<dynamic>?)
              ?.map((e) => ResultDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ResultDto>[],
    );

Map<String, dynamic> _$$HeatDtoImplToJson(_$HeatDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Nom': instance.name,
      'Fini': instance.done,
      'Numero': instance.number,
      'UpdatedAt': instance.updatedAt,
      'Debut': instance.startDate,
      'Fin': instance.endDate,
      'epreuve': instance.race,
      'resultats': instance.results,
    };
