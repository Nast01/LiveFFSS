// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RefereeImpl _$$RefereeImplFromJson(Map<String, dynamic> json) =>
    _$RefereeImpl(
      id: (json['id'] as num).toInt(),
      licenseeNumber: json['licenseeNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      year: (json['year'] as num).toInt(),
      level: json['level'] as String,
      levelMax: json['levelMax'] as String,
      nationalityCode: json['nationalityCode'] as String,
      nationality: json['nationality'] as String,
      isValid: json['isValid'] as bool,
      isLicensee: json['isLicensee'] as bool? ?? false,
      isGuest: json['isGuest'] as bool? ?? false,
      isPrincipal: json['isPrincipal'] as bool? ?? false,
      availabilities: (json['availabilities'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$$RefereeImplToJson(_$RefereeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'licenseeNumber': instance.licenseeNumber,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'year': instance.year,
      'level': instance.level,
      'levelMax': instance.levelMax,
      'nationalityCode': instance.nationalityCode,
      'nationality': instance.nationality,
      'isValid': instance.isValid,
      'isLicensee': instance.isLicensee,
      'isGuest': instance.isGuest,
      'isPrincipal': instance.isPrincipal,
      'availabilities': instance.availabilities,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.mixed: 'mixed',
  Gender.unknown: 'unknown',
};
