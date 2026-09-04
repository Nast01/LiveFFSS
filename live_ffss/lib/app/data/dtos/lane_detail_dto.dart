// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'lane_detail_dto.freezed.dart';
part 'lane_detail_dto.g.dart';

/// A place as `GET .../place/:id` serves it — the ONLY route that shows who
/// sits in it. The réunion tree lists the same places with `engagement: null`
/// even when they are taken; syncing a draw down to another device has to go
/// through this detail route, one place at a time.
///
/// The nested engagement is NOT an `EntryDto`: lower-case keys (`id`,
/// `statut`, `clubLabel`, `athletes`…) where `EntryDto` requires `Id` and
/// `Statut`. Same notion, third spelling on the wire — hence this dedicated
/// DTO. Every field beyond what a composition needs is deliberately left out.
/// Verified in production on 2026-09-03 (place 287, compétition 1451).
@freezed
class LaneDetailDto with _$LaneDetailDto {
  const factory LaneDetailDto({
    @JsonKey(name: 'id') required int id,
    @JsonKey(name: 'Numero') @Default(0) int number,
    @JsonKey(name: 'engagement') LaneSeatDto? seat,
  }) = _LaneDetailDto;

  factory LaneDetailDto.fromJson(Map<String, dynamic> json) =>
      _$LaneDetailDtoFromJson(json);
}

/// The engagement seated in a place: its id and its athletes — all a draw
/// needs to travel between devices; labels resolve locally from the entries.
@freezed
class LaneSeatDto with _$LaneSeatDto {
  const factory LaneSeatDto({
    @JsonKey(name: 'id') @Default(0) int entryId,
    // Nullable rather than defaulted: FFSS serves both `[]` and an explicit
    // null for this key depending on the route, and `@Default` only covers
    // the absent case.
    @JsonKey(name: 'athletes') List<LaneSeatAthleteDto>? athletes,
  }) = _LaneSeatDto;

  factory LaneSeatDto.fromJson(Map<String, dynamic> json) =>
      _$LaneSeatDtoFromJson(json);
}

@freezed
class LaneSeatAthleteDto with _$LaneSeatAthleteDto {
  const factory LaneSeatAthleteDto({
    @JsonKey(name: 'Id') @Default(0) int id,
  }) = _LaneSeatAthleteDto;

  factory LaneSeatAthleteDto.fromJson(Map<String, dynamic> json) =>
      _$LaneSeatAthleteDtoFromJson(json);
}
