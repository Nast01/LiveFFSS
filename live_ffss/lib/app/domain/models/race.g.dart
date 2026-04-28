// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'race.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RaceImpl _$$RaceImplFromJson(Map<String, dynamic> json) => _$RaceImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameEnglish: json['nameEnglish'] as String,
      distance: (json['distance'] as num).toInt(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      athletesPerTeam: (json['athletesPerTeam'] as num).toInt(),
      specialityId: (json['specialityId'] as num).toInt(),
      specialityLabel: json['specialityLabel'] as String,
      disciplineId: (json['disciplineId'] as num).toInt(),
      isEligibleToNationalRecord: json['isEligibleToNationalRecord'] as bool,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$RaceImplToJson(_$RaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEnglish': instance.nameEnglish,
      'distance': instance.distance,
      'gender': _$GenderEnumMap[instance.gender]!,
      'athletesPerTeam': instance.athletesPerTeam,
      'specialityId': instance.specialityId,
      'specialityLabel': instance.specialityLabel,
      'disciplineId': instance.disciplineId,
      'isEligibleToNationalRecord': instance.isEligibleToNationalRecord,
      'categories': instance.categories,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.mixed: 'mixed',
  Gender.unknown: 'unknown',
};
