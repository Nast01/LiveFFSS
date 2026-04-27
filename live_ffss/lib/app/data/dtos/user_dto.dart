// ignore_for_file: invalid_annotation_target
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String label,
    required String type,
    required UserDtoData data,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);
}

@freezed
class UserDtoData with _$UserDtoData {
  const factory UserDtoData({
    required String role,
    @JsonKey(name: 'nom') String? lastName,
    @JsonKey(name: 'prenom') String? firstName,
    @JsonKey(name: 'numero') String? licenseeNumber,
    UserDtoClub? club,
  }) = _UserDtoData;

  factory UserDtoData.fromJson(Map<String, dynamic> json) =>
      _$UserDtoDataFromJson(json);
}

@freezed
class UserDtoClub with _$UserDtoClub {
  const factory UserDtoClub({
    required String label,
  }) = _UserDtoClub;

  factory UserDtoClub.fromJson(Map<String, dynamic> json) =>
      _$UserDtoClubFromJson(json);
}
