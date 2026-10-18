// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OutboxOperationDto _$OutboxOperationDtoFromJson(Map<String, dynamic> json) =>
    _OutboxOperationDto(
      id: json['id'] as String,
      account: json['account'] as String,
      competitionId: (json['competitionId'] as num).toInt(),
      placeId: (json['placeId'] as num).toInt(),
      resultId: (json['resultId'] as num?)?.toInt(),
      seriesId: (json['seriesId'] as num).toInt(),
      entryId: (json['entryId'] as num).toInt(),
      chronos: (json['chronos'] as List<dynamic>?)
          ?.map((e) => (e as num?)?.toInt())
          .toList(),
      mark: json['mark'] as String?,
      code: json['code'] as String?,
      state: json['state'] as String,
      rejection: json['rejection'] as String?,
      reason: json['reason'] as String?,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      faults: (json['faults'] as num?)?.toInt() ?? 0,
      sentAt: json['sentAt'] as String?,
    );

Map<String, dynamic> _$OutboxOperationDtoToJson(_OutboxOperationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'account': instance.account,
      'competitionId': instance.competitionId,
      'placeId': instance.placeId,
      'resultId': instance.resultId,
      'seriesId': instance.seriesId,
      'entryId': instance.entryId,
      'chronos': instance.chronos,
      'mark': instance.mark,
      'code': instance.code,
      'state': instance.state,
      'rejection': instance.rejection,
      'reason': instance.reason,
      'attempts': instance.attempts,
      'faults': instance.faults,
      'sentAt': instance.sentAt,
    };
