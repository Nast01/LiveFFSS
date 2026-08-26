// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_penalty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoursePenaltyImpl _$$CoursePenaltyImplFromJson(Map<String, dynamic> json) =>
    _$CoursePenaltyImpl(
      athleteId: (json['athleteId'] as num).toInt(),
      kind: $enumDecode(_$CoursePenaltyKindEnumMap, json['kind'],
          unknownValue: CoursePenaltyKind.unknown),
      code: json['code'] as String? ?? '',
    );

Map<String, dynamic> _$$CoursePenaltyImplToJson(_$CoursePenaltyImpl instance) =>
    <String, dynamic>{
      'athleteId': instance.athleteId,
      'kind': _$CoursePenaltyKindEnumMap[instance.kind]!,
      'code': instance.code,
    };

const _$CoursePenaltyKindEnumMap = {
  CoursePenaltyKind.forfeit: 'forfeit',
  CoursePenaltyKind.disqualified: 'disqualified',
  CoursePenaltyKind.unknown: 'unknown',
};
