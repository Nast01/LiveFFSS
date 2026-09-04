// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lane_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LaneDetailDto _$LaneDetailDtoFromJson(Map<String, dynamic> json) {
  return _LaneDetailDto.fromJson(json);
}

/// @nodoc
mixin _$LaneDetailDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Numero')
  int get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'engagement')
  LaneSeatDto? get seat => throw _privateConstructorUsedError;

  /// Serializes this LaneDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaneDetailDtoCopyWith<LaneDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaneDetailDtoCopyWith<$Res> {
  factory $LaneDetailDtoCopyWith(
          LaneDetailDto value, $Res Function(LaneDetailDto) then) =
      _$LaneDetailDtoCopyWithImpl<$Res, LaneDetailDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Numero') int number,
      @JsonKey(name: 'engagement') LaneSeatDto? seat});

  $LaneSeatDtoCopyWith<$Res>? get seat;
}

/// @nodoc
class _$LaneDetailDtoCopyWithImpl<$Res, $Val extends LaneDetailDto>
    implements $LaneDetailDtoCopyWith<$Res> {
  _$LaneDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? seat = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      seat: freezed == seat
          ? _value.seat
          : seat // ignore: cast_nullable_to_non_nullable
              as LaneSeatDto?,
    ) as $Val);
  }

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LaneSeatDtoCopyWith<$Res>? get seat {
    if (_value.seat == null) {
      return null;
    }

    return $LaneSeatDtoCopyWith<$Res>(_value.seat!, (value) {
      return _then(_value.copyWith(seat: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LaneDetailDtoImplCopyWith<$Res>
    implements $LaneDetailDtoCopyWith<$Res> {
  factory _$$LaneDetailDtoImplCopyWith(
          _$LaneDetailDtoImpl value, $Res Function(_$LaneDetailDtoImpl) then) =
      __$$LaneDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Numero') int number,
      @JsonKey(name: 'engagement') LaneSeatDto? seat});

  @override
  $LaneSeatDtoCopyWith<$Res>? get seat;
}

/// @nodoc
class __$$LaneDetailDtoImplCopyWithImpl<$Res>
    extends _$LaneDetailDtoCopyWithImpl<$Res, _$LaneDetailDtoImpl>
    implements _$$LaneDetailDtoImplCopyWith<$Res> {
  __$$LaneDetailDtoImplCopyWithImpl(
      _$LaneDetailDtoImpl _value, $Res Function(_$LaneDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? seat = freezed,
  }) {
    return _then(_$LaneDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      seat: freezed == seat
          ? _value.seat
          : seat // ignore: cast_nullable_to_non_nullable
              as LaneSeatDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaneDetailDtoImpl implements _LaneDetailDto {
  const _$LaneDetailDtoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'Numero') this.number = 0,
      @JsonKey(name: 'engagement') this.seat});

  factory _$LaneDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaneDetailDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'Numero')
  final int number;
  @override
  @JsonKey(name: 'engagement')
  final LaneSeatDto? seat;

  @override
  String toString() {
    return 'LaneDetailDto(id: $id, number: $number, seat: $seat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaneDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.seat, seat) || other.seat == seat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, seat);

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaneDetailDtoImplCopyWith<_$LaneDetailDtoImpl> get copyWith =>
      __$$LaneDetailDtoImplCopyWithImpl<_$LaneDetailDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaneDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _LaneDetailDto implements LaneDetailDto {
  const factory _LaneDetailDto(
          {@JsonKey(name: 'id') required final int id,
          @JsonKey(name: 'Numero') final int number,
          @JsonKey(name: 'engagement') final LaneSeatDto? seat}) =
      _$LaneDetailDtoImpl;

  factory _LaneDetailDto.fromJson(Map<String, dynamic> json) =
      _$LaneDetailDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'Numero')
  int get number;
  @override
  @JsonKey(name: 'engagement')
  LaneSeatDto? get seat;

  /// Create a copy of LaneDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaneDetailDtoImplCopyWith<_$LaneDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LaneSeatDto _$LaneSeatDtoFromJson(Map<String, dynamic> json) {
  return _LaneSeatDto.fromJson(json);
}

/// @nodoc
mixin _$LaneSeatDto {
  @JsonKey(name: 'id')
  int get entryId =>
      throw _privateConstructorUsedError; // Nullable rather than defaulted: FFSS serves both `[]` and an explicit
// null for this key depending on the route, and `@Default` only covers
// the absent case.
  @JsonKey(name: 'athletes')
  List<LaneSeatAthleteDto>? get athletes => throw _privateConstructorUsedError;

  /// Serializes this LaneSeatDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaneSeatDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaneSeatDtoCopyWith<LaneSeatDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaneSeatDtoCopyWith<$Res> {
  factory $LaneSeatDtoCopyWith(
          LaneSeatDto value, $Res Function(LaneSeatDto) then) =
      _$LaneSeatDtoCopyWithImpl<$Res, LaneSeatDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int entryId,
      @JsonKey(name: 'athletes') List<LaneSeatAthleteDto>? athletes});
}

/// @nodoc
class _$LaneSeatDtoCopyWithImpl<$Res, $Val extends LaneSeatDto>
    implements $LaneSeatDtoCopyWith<$Res> {
  _$LaneSeatDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaneSeatDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? athletes = freezed,
  }) {
    return _then(_value.copyWith(
      entryId: null == entryId
          ? _value.entryId
          : entryId // ignore: cast_nullable_to_non_nullable
              as int,
      athletes: freezed == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<LaneSeatAthleteDto>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LaneSeatDtoImplCopyWith<$Res>
    implements $LaneSeatDtoCopyWith<$Res> {
  factory _$$LaneSeatDtoImplCopyWith(
          _$LaneSeatDtoImpl value, $Res Function(_$LaneSeatDtoImpl) then) =
      __$$LaneSeatDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int entryId,
      @JsonKey(name: 'athletes') List<LaneSeatAthleteDto>? athletes});
}

/// @nodoc
class __$$LaneSeatDtoImplCopyWithImpl<$Res>
    extends _$LaneSeatDtoCopyWithImpl<$Res, _$LaneSeatDtoImpl>
    implements _$$LaneSeatDtoImplCopyWith<$Res> {
  __$$LaneSeatDtoImplCopyWithImpl(
      _$LaneSeatDtoImpl _value, $Res Function(_$LaneSeatDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaneSeatDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? athletes = freezed,
  }) {
    return _then(_$LaneSeatDtoImpl(
      entryId: null == entryId
          ? _value.entryId
          : entryId // ignore: cast_nullable_to_non_nullable
              as int,
      athletes: freezed == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<LaneSeatAthleteDto>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaneSeatDtoImpl implements _LaneSeatDto {
  const _$LaneSeatDtoImpl(
      {@JsonKey(name: 'id') this.entryId = 0,
      @JsonKey(name: 'athletes') final List<LaneSeatAthleteDto>? athletes})
      : _athletes = athletes;

  factory _$LaneSeatDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaneSeatDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int entryId;
// Nullable rather than defaulted: FFSS serves both `[]` and an explicit
// null for this key depending on the route, and `@Default` only covers
// the absent case.
  final List<LaneSeatAthleteDto>? _athletes;
// Nullable rather than defaulted: FFSS serves both `[]` and an explicit
// null for this key depending on the route, and `@Default` only covers
// the absent case.
  @override
  @JsonKey(name: 'athletes')
  List<LaneSeatAthleteDto>? get athletes {
    final value = _athletes;
    if (value == null) return null;
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'LaneSeatDto(entryId: $entryId, athletes: $athletes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaneSeatDtoImpl &&
            (identical(other.entryId, entryId) || other.entryId == entryId) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, entryId, const DeepCollectionEquality().hash(_athletes));

  /// Create a copy of LaneSeatDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaneSeatDtoImplCopyWith<_$LaneSeatDtoImpl> get copyWith =>
      __$$LaneSeatDtoImplCopyWithImpl<_$LaneSeatDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaneSeatDtoImplToJson(
      this,
    );
  }
}

abstract class _LaneSeatDto implements LaneSeatDto {
  const factory _LaneSeatDto(
      {@JsonKey(name: 'id') final int entryId,
      @JsonKey(name: 'athletes')
      final List<LaneSeatAthleteDto>? athletes}) = _$LaneSeatDtoImpl;

  factory _LaneSeatDto.fromJson(Map<String, dynamic> json) =
      _$LaneSeatDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get entryId; // Nullable rather than defaulted: FFSS serves both `[]` and an explicit
// null for this key depending on the route, and `@Default` only covers
// the absent case.
  @override
  @JsonKey(name: 'athletes')
  List<LaneSeatAthleteDto>? get athletes;

  /// Create a copy of LaneSeatDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaneSeatDtoImplCopyWith<_$LaneSeatDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LaneSeatAthleteDto _$LaneSeatAthleteDtoFromJson(Map<String, dynamic> json) {
  return _LaneSeatAthleteDto.fromJson(json);
}

/// @nodoc
mixin _$LaneSeatAthleteDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;

  /// Serializes this LaneSeatAthleteDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaneSeatAthleteDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaneSeatAthleteDtoCopyWith<LaneSeatAthleteDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaneSeatAthleteDtoCopyWith<$Res> {
  factory $LaneSeatAthleteDtoCopyWith(
          LaneSeatAthleteDto value, $Res Function(LaneSeatAthleteDto) then) =
      _$LaneSeatAthleteDtoCopyWithImpl<$Res, LaneSeatAthleteDto>;
  @useResult
  $Res call({@JsonKey(name: 'Id') int id});
}

/// @nodoc
class _$LaneSeatAthleteDtoCopyWithImpl<$Res, $Val extends LaneSeatAthleteDto>
    implements $LaneSeatAthleteDtoCopyWith<$Res> {
  _$LaneSeatAthleteDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaneSeatAthleteDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LaneSeatAthleteDtoImplCopyWith<$Res>
    implements $LaneSeatAthleteDtoCopyWith<$Res> {
  factory _$$LaneSeatAthleteDtoImplCopyWith(_$LaneSeatAthleteDtoImpl value,
          $Res Function(_$LaneSeatAthleteDtoImpl) then) =
      __$$LaneSeatAthleteDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'Id') int id});
}

/// @nodoc
class __$$LaneSeatAthleteDtoImplCopyWithImpl<$Res>
    extends _$LaneSeatAthleteDtoCopyWithImpl<$Res, _$LaneSeatAthleteDtoImpl>
    implements _$$LaneSeatAthleteDtoImplCopyWith<$Res> {
  __$$LaneSeatAthleteDtoImplCopyWithImpl(_$LaneSeatAthleteDtoImpl _value,
      $Res Function(_$LaneSeatAthleteDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaneSeatAthleteDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$LaneSeatAthleteDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaneSeatAthleteDtoImpl implements _LaneSeatAthleteDto {
  const _$LaneSeatAthleteDtoImpl({@JsonKey(name: 'Id') this.id = 0});

  factory _$LaneSeatAthleteDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaneSeatAthleteDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;

  @override
  String toString() {
    return 'LaneSeatAthleteDto(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaneSeatAthleteDtoImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of LaneSeatAthleteDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaneSeatAthleteDtoImplCopyWith<_$LaneSeatAthleteDtoImpl> get copyWith =>
      __$$LaneSeatAthleteDtoImplCopyWithImpl<_$LaneSeatAthleteDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaneSeatAthleteDtoImplToJson(
      this,
    );
  }
}

abstract class _LaneSeatAthleteDto implements LaneSeatAthleteDto {
  const factory _LaneSeatAthleteDto({@JsonKey(name: 'Id') final int id}) =
      _$LaneSeatAthleteDtoImpl;

  factory _LaneSeatAthleteDto.fromJson(Map<String, dynamic> json) =
      _$LaneSeatAthleteDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;

  /// Create a copy of LaneSeatAthleteDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaneSeatAthleteDtoImplCopyWith<_$LaneSeatAthleteDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
