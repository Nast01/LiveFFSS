// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AthleteImpl _$$AthleteImplFromJson(Map<String, dynamic> json) =>
    _$AthleteImpl(
      id: (json['id'] as num).toInt(),
      licenseeNumber: json['licenseeNumber'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      year: (json['year'] as num).toInt(),
      nationalityCode: json['nationalityCode'] as String,
      nationality: json['nationality'] as String,
      isValid: json['isValid'] as bool,
      isLicensee: json['isLicensee'] as bool? ?? false,
      isGuest: json['isGuest'] as bool? ?? false,
    );

Map<String, dynamic> _$$AthleteImplToJson(_$AthleteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'licenseeNumber': instance.licenseeNumber,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'year': instance.year,
      'nationalityCode': instance.nationalityCode,
      'nationality': instance.nationality,
      'isValid': instance.isValid,
      'isLicensee': instance.isLicensee,
      'isGuest': instance.isGuest,
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.mixed: 'mixed',
  Gender.unknown: 'unknown',
};
