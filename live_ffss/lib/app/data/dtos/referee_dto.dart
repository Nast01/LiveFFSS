// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'referee_dto.freezed.dart';
part 'referee_dto.g.dart';

@freezed
class RefereeDto with _$RefereeDto {
  const factory RefereeDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'NumeroLicence') @Default('') String licenseeNumber,
    @JsonKey(name: 'Prenom') @Default('') String firstName,
    @JsonKey(name: 'Nom') @Default('') String lastName,
    @JsonKey(name: 'Sexe') @Default('') String gender,
    @JsonKey(name: 'Annee', readValue: _readYear) @Default(0) int year,
    @JsonKey(name: 'Niveau') @Default('') String level,
    @JsonKey(name: 'NiveauMax') @Default('') String levelMax,
    @JsonKey(name: 'nationaliteCode') @Default('') String nationalityCode,
    @JsonKey(name: 'nationaliteLabel') @Default('') String nationality,
    @JsonKey(name: 'isValid') @Default(false) bool isValid,
    @JsonKey(name: 'isLicencie') @Default(false) bool isLicensee,
    @JsonKey(name: 'isInvite') @Default(false) bool isGuest,
    @JsonKey(name: 'Principal') @Default(false) bool isPrincipal,
    @JsonKey(name: 'Jours', readValue: _readAvailabilities)
    @Default(<int>[]) List<int> availabilities,
  }) = _RefereeDto;

  factory RefereeDto.fromJson(Map<String, dynamic> json) =>
      _$RefereeDtoFromJson(json);
}

Object? _readYear(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}

Object? _readAvailabilities(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is! List) return const <int>[];
  return raw
      .map((v) => v is int ? v : int.tryParse(v.toString()) ?? 0)
      .toList();
}
