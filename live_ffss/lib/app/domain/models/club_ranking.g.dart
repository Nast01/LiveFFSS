// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClubRankingImpl _$$ClubRankingImplFromJson(Map<String, dynamic> json) =>
    _$ClubRankingImpl(
      position: (json['position'] as num?)?.toInt() ?? 0,
      clubName: json['clubName'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ClubRankingImplToJson(_$ClubRankingImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'clubName': instance.clubName,
      'points': instance.points,
    };
