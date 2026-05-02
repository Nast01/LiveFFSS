// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relay_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelayRankingImpl _$$RelayRankingImplFromJson(Map<String, dynamic> json) =>
    _$RelayRankingImpl(
      position: (json['position'] as num?)?.toInt() ?? 0,
      clubName: json['clubName'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RelayRankingImplToJson(_$RelayRankingImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'clubName': instance.clubName,
      'teamName': instance.teamName,
      'points': instance.points,
    };
