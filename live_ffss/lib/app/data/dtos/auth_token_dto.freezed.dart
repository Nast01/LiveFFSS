// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_token_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthTokenDto _$AuthTokenDtoFromJson(Map<String, dynamic> json) {
  return _AuthTokenDto.fromJson(json);
}

/// @nodoc
mixin _$AuthTokenDto {
  String get token => throw _privateConstructorUsedError;
  String get expiration => throw _privateConstructorUsedError;

  /// Serializes this AuthTokenDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthTokenDtoCopyWith<AuthTokenDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthTokenDtoCopyWith<$Res> {
  factory $AuthTokenDtoCopyWith(
          AuthTokenDto value, $Res Function(AuthTokenDto) then) =
      _$AuthTokenDtoCopyWithImpl<$Res, AuthTokenDto>;
  @useResult
  $Res call({String token, String expiration});
}

/// @nodoc
class _$AuthTokenDtoCopyWithImpl<$Res, $Val extends AuthTokenDto>
    implements $AuthTokenDtoCopyWith<$Res> {
  _$AuthTokenDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? expiration = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      expiration: null == expiration
          ? _value.expiration
          : expiration // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthTokenDtoImplCopyWith<$Res>
    implements $AuthTokenDtoCopyWith<$Res> {
  factory _$$AuthTokenDtoImplCopyWith(
          _$AuthTokenDtoImpl value, $Res Function(_$AuthTokenDtoImpl) then) =
      __$$AuthTokenDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String expiration});
}

/// @nodoc
class __$$AuthTokenDtoImplCopyWithImpl<$Res>
    extends _$AuthTokenDtoCopyWithImpl<$Res, _$AuthTokenDtoImpl>
    implements _$$AuthTokenDtoImplCopyWith<$Res> {
  __$$AuthTokenDtoImplCopyWithImpl(
      _$AuthTokenDtoImpl _value, $Res Function(_$AuthTokenDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? expiration = null,
  }) {
    return _then(_$AuthTokenDtoImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      expiration: null == expiration
          ? _value.expiration
          : expiration // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthTokenDtoImpl implements _AuthTokenDto {
  const _$AuthTokenDtoImpl({required this.token, required this.expiration});

  factory _$AuthTokenDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthTokenDtoImplFromJson(json);

  @override
  final String token;
  @override
  final String expiration;

  @override
  String toString() {
    return 'AuthTokenDto(token: $token, expiration: $expiration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthTokenDtoImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.expiration, expiration) ||
                other.expiration == expiration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, expiration);

  /// Create a copy of AuthTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthTokenDtoImplCopyWith<_$AuthTokenDtoImpl> get copyWith =>
      __$$AuthTokenDtoImplCopyWithImpl<_$AuthTokenDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthTokenDtoImplToJson(
      this,
    );
  }
}

abstract class _AuthTokenDto implements AuthTokenDto {
  const factory _AuthTokenDto(
      {required final String token,
      required final String expiration}) = _$AuthTokenDtoImpl;

  factory _AuthTokenDto.fromJson(Map<String, dynamic> json) =
      _$AuthTokenDtoImpl.fromJson;

  @override
  String get token;
  @override
  String get expiration;

  /// Create a copy of AuthTokenDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthTokenDtoImplCopyWith<_$AuthTokenDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
