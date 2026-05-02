// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IndividualRankingImpl _$$IndividualRankingImplFromJson(
        Map<String, dynamic> json) =>
    _$IndividualRankingImpl(
      position: (json['position'] as num?)?.toInt() ?? 0,
      athleteFirstName: json['athleteFirstName'] as String? ?? '',
      athleteLastName: json['athleteLastName'] as String? ?? '',
      clubName: json['clubName'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$IndividualRankingImplToJson(
        _$IndividualRankingImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'athleteFirstName': instance.athleteFirstName,
      'athleteLastName': instance.athleteLastName,
      'clubName': instance.clubName,
      'points': instance.points,
    };
