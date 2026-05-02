// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'athlete_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AthleteDtoImpl _$$AthleteDtoImplFromJson(Map<String, dynamic> json) =>
    _$AthleteDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
      licenseeNumber: json['NumeroLicence'] as String? ?? '',
      firstName: json['Prenom'] as String? ?? '',
      lastName: json['Nom'] as String? ?? '',
      gender: json['Sexe'] as String? ?? '',
      year: (_readYear(json, 'Annee') as num?)?.toInt() ?? 0,
      nationalityCode: json['nationaliteCode'] as String? ?? '',
      nationality: json['nationaliteLabel'] as String? ?? '',
      isValid: json['isValid'] as bool? ?? false,
      isLicensee: json['isLicencie'] as bool? ?? false,
      isGuest: json['isInvite'] as bool? ?? false,
    );

Map<String, dynamic> _$$AthleteDtoImplToJson(_$AthleteDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'NumeroLicence': instance.licenseeNumber,
      'Prenom': instance.firstName,
      'Nom': instance.lastName,
      'Sexe': instance.gender,
      'Annee': instance.year,
      'nationaliteCode': instance.nationalityCode,
      'nationaliteLabel': instance.nationality,
      'isValid': instance.isValid,
      'isLicencie': instance.isLicensee,
      'isInvite': instance.isGuest,
    };
