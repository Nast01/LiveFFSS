// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatImpl _$$HeatImplFromJson(Map<String, dynamic> json) => _$HeatImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      number: (json['number'] as num?)?.toInt() ?? 0,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      race: json['race'] == null
          ? null
          : Race.fromJson(json['race'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => Result.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Result>[],
    );

Map<String, dynamic> _$$HeatImplToJson(_$HeatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'done': instance.done,
      'number': instance.number,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'race': instance.race,
      'results': instance.results,
    };
