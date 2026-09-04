// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heat_result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatResultDtoImpl _$$HeatResultDtoImplFromJson(Map<String, dynamic> json) =>
    _$HeatResultDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
      rank: (json['Rang'] as num?)?.toInt(),
      isDisqualified: json['isDisqualifie'] as bool? ?? false,
      complement: json['complement'] as String?,
      status: (json['Statut'] as num?)?.toInt(),
      entry: json['engagement'] == null
          ? null
          : HeatResultEntryDto.fromJson(
              json['engagement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HeatResultDtoImplToJson(_$HeatResultDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Rang': instance.rank,
      'isDisqualifie': instance.isDisqualified,
      'complement': instance.complement,
      'Statut': instance.status,
      'engagement': instance.entry,
    };

_$HeatResultEntryDtoImpl _$$HeatResultEntryDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$HeatResultEntryDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HeatResultEntryDtoImplToJson(
        _$HeatResultEntryDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
    };
