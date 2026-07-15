// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResultImpl _$$ResultImplFromJson(Map<String, dynamic> json) => _$ResultImpl(
      id: json['id'] as String,
      isValid: json['isValid'] as bool,
      status: (json['status'] as num).toInt(),
      statusLabel: json['statusLabel'] as String,
      isDisqualified: json['isDisqualified'] as bool? ?? false,
      rank: (json['rank'] as num).toInt(),
      time: (json['time'] as num).toInt(),
      timeLabel: json['timeLabel'] as String,
      complement: json['complement'] as String?,
      complementLabel: json['complementLabel'] as String?,
      disqualificationCode: json['disqualificationCode'] as String? ?? '',
      disqualificationReason: json['disqualificationReason'] as String? ?? '',
      heat: json['heat'] == null
          ? null
          : Heat.fromJson(json['heat'] as Map<String, dynamic>),
      entry: json['entry'] == null
          ? null
          : Entry.fromJson(json['entry'] as Map<String, dynamic>),
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => Athlete.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Athlete>[],
      isRecord: json['isRecord'] as bool? ?? false,
      isBestPerformance: json['isBestPerformance'] as bool? ?? false,
      isFranceRecord: json['isFranceRecord'] as bool? ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      liveTime1: (json['liveTime1'] as num?)?.toInt() ?? 0,
      liveTime2: (json['liveTime2'] as num?)?.toInt() ?? 0,
      liveTime3: (json['liveTime3'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ResultImplToJson(_$ResultImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isValid': instance.isValid,
      'status': instance.status,
      'statusLabel': instance.statusLabel,
      'isDisqualified': instance.isDisqualified,
      'rank': instance.rank,
      'time': instance.time,
      'timeLabel': instance.timeLabel,
      'complement': instance.complement,
      'complementLabel': instance.complementLabel,
      'disqualificationCode': instance.disqualificationCode,
      'disqualificationReason': instance.disqualificationReason,
      'heat': instance.heat,
      'entry': instance.entry,
      'athletes': instance.athletes,
      'isRecord': instance.isRecord,
      'isBestPerformance': instance.isBestPerformance,
      'isFranceRecord': instance.isFranceRecord,
      'points': instance.points,
      'liveTime1': instance.liveTime1,
      'liveTime2': instance.liveTime2,
      'liveTime3': instance.liveTime3,
    };
