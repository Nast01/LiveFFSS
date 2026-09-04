// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lane_detail_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LaneDetailDtoImpl _$$LaneDetailDtoImplFromJson(Map<String, dynamic> json) =>
    _$LaneDetailDtoImpl(
      id: (json['id'] as num).toInt(),
      number: (json['Numero'] as num?)?.toInt() ?? 0,
      seat: json['engagement'] == null
          ? null
          : LaneSeatDto.fromJson(json['engagement'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LaneDetailDtoImplToJson(_$LaneDetailDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'Numero': instance.number,
      'engagement': instance.seat,
    };

_$LaneSeatDtoImpl _$$LaneSeatDtoImplFromJson(Map<String, dynamic> json) =>
    _$LaneSeatDtoImpl(
      entryId: (json['id'] as num?)?.toInt() ?? 0,
      athletes: (json['athletes'] as List<dynamic>?)
          ?.map((e) => LaneSeatAthleteDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$LaneSeatDtoImplToJson(_$LaneSeatDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.entryId,
      'athletes': instance.athletes,
    };

_$LaneSeatAthleteDtoImpl _$$LaneSeatAthleteDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$LaneSeatAthleteDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$LaneSeatAthleteDtoImplToJson(
        _$LaneSeatAthleteDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
    };
