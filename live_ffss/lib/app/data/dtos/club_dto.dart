// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'club_dto.freezed.dart';
part 'club_dto.g.dart';

@freezed
class ClubDto with _$ClubDto {
  const factory ClubDto({
    @JsonKey(name: 'Id') required int id,
    @JsonKey(name: 'NomCompletOrga') required String name,
    @JsonKey(name: 'NomCourt') String? shortName,
    @JsonKey(name: 'logo') String? logoUrl,
    @JsonKey(name: 'bonnet') String? capUrl,
  }) = _ClubDto;

  factory ClubDto.fromJson(Map<String, dynamic> json) =>
      _$ClubDtoFromJson(json);
}
