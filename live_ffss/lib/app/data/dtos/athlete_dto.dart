// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_entry_dto.dart';

part 'athlete_dto.freezed.dart';
part 'athlete_dto.g.dart';

@freezed
class AthleteDto with _$AthleteDto {
  const factory AthleteDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'NumeroLicence') @Default('') String licenseeNumber,
    @JsonKey(name: 'Prenom') @Default('') String firstName,
    @JsonKey(name: 'Nom') @Default('') String lastName,
    @JsonKey(name: 'Sexe') @Default('') String gender,
    @JsonKey(name: 'Annee', readValue: _readYear) @Default(0) int year,
    @JsonKey(name: 'nationaliteCode') @Default('') String nationalityCode,
    @JsonKey(name: 'nationaliteLabel') @Default('') String nationality,
    @JsonKey(name: 'isValid') @Default(false) bool isValid,
    @JsonKey(name: 'isLicencie') @Default(false) bool isLicensee,
    @JsonKey(name: 'isInvite') @Default(false) bool isGuest,
    // A guest has no FFSS licence: this stands in for `NumeroLicence`.
    // Observed as both an int and a String, hence the coercion.
    @JsonKey(name: 'idInvite', readValue: _readGuestId)
    @Default('')
    String guestId,
    // Engagement-scoped fields (present only on the engagement endpoint).
    @JsonKey(name: 'Performance') @Default(0) int performanceTime,
    @JsonKey(name: 'performanceLabel') @Default('') String performanceLabel,
    @JsonKey(name: 'idClub') @Default(0) int clubId,
    @JsonKey(name: 'clubLabel') @Default('') String clubLabel,
    @JsonKey(name: 'isRemplacant') @Default(false) bool isSubstitute,
    // Present only on `evenement/:id/organismes`, which nests each athlete's
    // entries. Carried for the categories they hold — an athlete's own
    // `categories` map lists what they are *eligible* for, up to eleven
    // brackets for a master, which names nothing they actually race.
    @JsonKey(name: 'engagements')
    @Default(<AthleteEntryDto>[])
    List<AthleteEntryDto> entries,
  }) = _AthleteDto;

  factory AthleteDto.fromJson(Map<String, dynamic> json) =>
      _$AthleteDtoFromJson(json);
}

Object? _readYear(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw is String) return int.tryParse(raw) ?? 0;
  return raw;
}

Object? _readGuestId(Map<dynamic, dynamic> map, String key) {
  final raw = map[key];
  if (raw == null) return '';
  return raw is String ? raw : raw.toString();
}
