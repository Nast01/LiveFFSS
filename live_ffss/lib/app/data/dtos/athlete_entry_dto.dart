// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'athlete_entry_dto.freezed.dart';
part 'athlete_entry_dto.g.dart';

/// One of an athlete's entries, as `evenement/:id/organismes` nests them under
/// `engagements`. Only the category is carried: that endpoint repeats the whole
/// épreuve inside every entry, and nothing here needs it.
///
/// The entry endpoint (`competition/engagement`) serves athletes with no
/// `engagements` key at all — verified 2026-09-02 — so the field defaults to
/// empty rather than being required.
@freezed
class AthleteEntryDto with _$AthleteEntryDto {
  const factory AthleteEntryDto({
    @JsonKey(name: 'categorie') EntryCategoryDto? category,
  }) = _AthleteEntryDto;

  factory AthleteEntryDto.fromJson(Map<String, dynamic> json) =>
      _$AthleteEntryDtoFromJson(json);
}

/// The category of an entry: `{id, label}`, lower-case — not the `Id`/`Nom` of
/// [CategoryDto], which the standalone category routes use. Same concept, two
/// spellings on the wire.
@freezed
class EntryCategoryDto with _$EntryCategoryDto {
  const factory EntryCategoryDto({
    @JsonKey(name: 'id') @Default(0) int id,
    @JsonKey(name: 'label') @Default('') String name,
  }) = _EntryCategoryDto;

  factory EntryCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$EntryCategoryDtoFromJson(json);
}
