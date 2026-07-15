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
      performanceTime: (json['Performance'] as num?)?.toInt() ?? 0,
      performanceLabel: json['performanceLabel'] as String? ?? '',
      clubId: (json['idClub'] as num?)?.toInt() ?? 0,
      clubLabel: json['clubLabel'] as String? ?? '',
      isSubstitute: json['isRemplacant'] as bool? ?? false,
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
      'Performance': instance.performanceTime,
      'performanceLabel': instance.performanceLabel,
      'idClub': instance.clubId,
      'clubLabel': instance.clubLabel,
      'isRemplacant': instance.isSubstitute,
    };
