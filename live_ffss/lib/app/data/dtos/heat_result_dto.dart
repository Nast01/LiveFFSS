// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'heat_result_dto.freezed.dart';
part 'heat_result_dto.g.dart';

/// One result of a heat, as `GET competition/resultat?serie=:id` serves it.
///
/// Only what the Séries screen redisplays is carried: rank, complement and the
/// disqualification flag, plus the engagement they belong to. The route also
/// returns times, points and record flags — none of which this app records
/// yet, and modelling them now would be guessing at how they are meant to be
/// written back.
///
/// `Rang` is null for a competitor out of the ranking: a forfeit takes no
/// place, and the athletes behind them number as though they had not started.
/// Verified in production on 2026-09-04.
@freezed
class HeatResultDto with _$HeatResultDto {
  const factory HeatResultDto({
    @JsonKey(name: 'Id') @Default(0) int id,
    @JsonKey(name: 'Rang') int? rank,
    @JsonKey(name: 'isDisqualifie') @Default(false) bool isDisqualified,
    @JsonKey(name: 'complement') String? complement,
    @JsonKey(name: 'Statut') int? status,
    @JsonKey(name: 'engagement') HeatResultEntryDto? entry,
  }) = _HeatResultDto;

  factory HeatResultDto.fromJson(Map<String, dynamic> json) =>
      _$HeatResultDtoFromJson(json);
}

/// The engagement a result belongs to. Capitalised `Id` here — unlike the
/// engagement nested in a place, which uses `id`. Third route, third spelling.
@freezed
class HeatResultEntryDto with _$HeatResultEntryDto {
  const factory HeatResultEntryDto({
    @JsonKey(name: 'Id') @Default(0) int id,
  }) = _HeatResultEntryDto;

  factory HeatResultEntryDto.fromJson(Map<String, dynamic> json) =>
      _$HeatResultEntryDtoFromJson(json);
}
