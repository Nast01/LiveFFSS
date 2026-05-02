// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referee_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RefereeDtoImpl _$$RefereeDtoImplFromJson(Map<String, dynamic> json) =>
    _$RefereeDtoImpl(
      id: (json['Id'] as num?)?.toInt() ?? 0,
      licenseeNumber: json['NumeroLicence'] as String? ?? '',
      firstName: json['Prenom'] as String? ?? '',
      lastName: json['Nom'] as String? ?? '',
      gender: json['Sexe'] as String? ?? '',
      year: (_readYear(json, 'Annee') as num?)?.toInt() ?? 0,
      level: json['Niveau'] as String? ?? '',
      levelMax: json['NiveauMax'] as String? ?? '',
      nationalityCode: json['nationaliteCode'] as String? ?? '',
      nationality: json['nationaliteLabel'] as String? ?? '',
      isValid: json['isValid'] as bool? ?? false,
      isLicensee: json['isLicencie'] as bool? ?? false,
      isGuest: json['isInvite'] as bool? ?? false,
      isPrincipal: json['Principal'] as bool? ?? false,
      availabilities: (_readAvailabilities(json, 'Jours') as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
    );

Map<String, dynamic> _$$RefereeDtoImplToJson(_$RefereeDtoImpl instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'NumeroLicence': instance.licenseeNumber,
      'Prenom': instance.firstName,
      'Nom': instance.lastName,
      'Sexe': instance.gender,
      'Annee': instance.year,
      'Niveau': instance.level,
      'NiveauMax': instance.levelMax,
      'nationaliteCode': instance.nationalityCode,
      'nationaliteLabel': instance.nationality,
      'isValid': instance.isValid,
      'isLicencie': instance.isLicensee,
      'isInvite': instance.isGuest,
      'Principal': instance.isPrincipal,
      'Jours': instance.availabilities,
    };
