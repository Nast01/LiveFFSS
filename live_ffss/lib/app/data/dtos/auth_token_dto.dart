import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token_dto.freezed.dart';
part 'auth_token_dto.g.dart';

@freezed
class AuthTokenDto with _$AuthTokenDto {
  const factory AuthTokenDto({
    required String token,
    required String expiration,
  }) = _AuthTokenDto;

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenDtoFromJson(json);
}
