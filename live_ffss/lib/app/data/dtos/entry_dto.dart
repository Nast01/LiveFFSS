// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:live_ffss/app/data/dtos/athlete_dto.dart';
import 'package:live_ffss/app/data/dtos/category_dto.dart';
import 'package:live_ffss/app/data/dtos/club_dto.dart';

part 'entry_dto.freezed.dart';
part 'entry_dto.g.dart';

@freezed
class EntryDto with _$EntryDto {
  const factory EntryDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'IdEpreuve') @Default(0) int raceId,
    @JsonKey(name: 'categorie') required CategoryDto category,
    @JsonKey(name: 'IdOrganisme') @Default(0) int organismeId,
    @JsonKey(name: 'Organisme') ClubDto? organisme,
    @JsonKey(name: 'Statut') required int status,
    @JsonKey(name: 'statutLabel') required String statusLabel,
    // Entry-level performance exists on the results endpoint's nested
    // engagement, not on the engagement list (where it's per-athlete).
    @JsonKey(name: 'performance') @Default(0) int entryTime,
    @JsonKey(name: 'performanceLabel') @Default('') String entryTimeLabel,
    @JsonKey(name: 'forfait') @Default(false) bool isForfeit,
    @JsonKey(name: 'athletes') @Default(<AthleteDto>[]) List<AthleteDto> athletes,
  }) = _EntryDto;

  factory EntryDto.fromJson(Map<String, dynamic> json) =>
      _$EntryDtoFromJson(json);
}
