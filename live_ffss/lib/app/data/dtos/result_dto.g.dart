// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ResultDtoImpl _$$ResultDtoImplFromJson(Map<String, dynamic> json) =>
    _$ResultDtoImpl(
      id: _readId(json, 'Id') as String? ?? '',
      isValid: json['isValid'] as bool? ?? false,
      status: (json['Statut'] as num?)?.toInt() ?? 0,
      statusLabel: json['statutLabel'] as String? ?? '',
      isDisqualified: json['isDisqualifie'] as bool? ?? false,
      rank: (json['Rang'] as num?)?.toInt() ?? 0,
      time: (json['Temps'] as num?)?.toInt() ?? 0,
      timeLabel: json['tempsLabel'] as String? ?? '',
      complement: json['complement'] as String?,
      complementLabel: json['complementLabel'] as String?,
      disqualificationCode: json['CodeDisqualification'] as String? ?? '',
      disqualificationReason:
          _readDisqualificationReason(json, 'disqualificationReason')
                  as String? ??
              '',
      heat: json['serie'] == null
          ? null
          : HeatDto.fromJson(json['serie'] as Map<String, dynamic>),
      entry: json['engagement'] == null
          ? null
          : EntryDto.fromJson(json['engagement'] as Map<String, dynamic>),
      athletes: (json['athletes'] as List<dynamic>?)
              ?.map((e) => AthleteDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AthleteDto>[],
      isRecord: json['isRecord'] as bool? ?? false,
      isBestPerformance: json['isMeilleurPerformance'] as bool? ?? false,
      isFranceRecord: json['isRecordDeFrance'] as bool? ?? false,
      points: (json['points'] as num?)?.toInt() ?? 0,
      liveTime1: (json['TempsLive1'] as num?)?.toInt() ?? 0,
      liveTime2: (json['TempsLive2'] as num?)?.toInt() ?? 0,
      liveTime3: (json['TempsLive3'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ResultDtoImplToJson(_$ResultDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'isValid': instance.isValid,
      'Statut': instance.status,
      'statutLabel': instance.statusLabel,
      'isDisqualifie': instance.isDisqualified,
      'Rang': instance.rank,
      'Temps': instance.time,
      'tempsLabel': instance.timeLabel,
      'complement': instance.complement,
      'complementLabel': instance.complementLabel,
      'CodeDisqualification': instance.disqualificationCode,
      'disqualificationReason': instance.disqualificationReason,
      'serie': instance.heat,
      'engagement': instance.entry,
      'athletes': instance.athletes,
      'isRecord': instance.isRecord,
      'isMeilleurPerformance': instance.isBestPerformance,
      'isRecordDeFrance': instance.isFranceRecord,
      'points': instance.points,
      'TempsLive1': instance.liveTime1,
      'TempsLive2': instance.liveTime2,
      'TempsLive3': instance.liveTime3,
    };
