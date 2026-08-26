// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_penalty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CoursePenalty _$CoursePenaltyFromJson(Map<String, dynamic> json) {
  return _CoursePenalty.fromJson(json);
}

/// @nodoc
mixin _$CoursePenalty {
  int get athleteId => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
  CoursePenaltyKind get kind => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  /// Serializes this CoursePenalty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CoursePenalty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CoursePenaltyCopyWith<CoursePenalty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoursePenaltyCopyWith<$Res> {
  factory $CoursePenaltyCopyWith(
          CoursePenalty value, $Res Function(CoursePenalty) then) =
      _$CoursePenaltyCopyWithImpl<$Res, CoursePenalty>;
  @useResult
  $Res call(
      {int athleteId,
      @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
      CoursePenaltyKind kind,
      String code});
}

/// @nodoc
class _$CoursePenaltyCopyWithImpl<$Res, $Val extends CoursePenalty>
    implements $CoursePenaltyCopyWith<$Res> {
  _$CoursePenaltyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CoursePenalty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? athleteId = null,
    Object? kind = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      athleteId: null == athleteId
          ? _value.athleteId
          : athleteId // ignore: cast_nullable_to_non_nullable
              as int,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as CoursePenaltyKind,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoursePenaltyImplCopyWith<$Res>
    implements $CoursePenaltyCopyWith<$Res> {
  factory _$$CoursePenaltyImplCopyWith(
          _$CoursePenaltyImpl value, $Res Function(_$CoursePenaltyImpl) then) =
      __$$CoursePenaltyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int athleteId,
      @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
      CoursePenaltyKind kind,
      String code});
}

/// @nodoc
class __$$CoursePenaltyImplCopyWithImpl<$Res>
    extends _$CoursePenaltyCopyWithImpl<$Res, _$CoursePenaltyImpl>
    implements _$$CoursePenaltyImplCopyWith<$Res> {
  __$$CoursePenaltyImplCopyWithImpl(
      _$CoursePenaltyImpl _value, $Res Function(_$CoursePenaltyImpl) _then)
      : super(_value, _then);

  /// Create a copy of CoursePenalty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? athleteId = null,
    Object? kind = null,
    Object? code = null,
  }) {
    return _then(_$CoursePenaltyImpl(
      athleteId: null == athleteId
          ? _value.athleteId
          : athleteId // ignore: cast_nullable_to_non_nullable
              as int,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as CoursePenaltyKind,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoursePenaltyImpl implements _CoursePenalty {
  const _$CoursePenaltyImpl(
      {required this.athleteId,
      @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown) required this.kind,
      this.code = ''});

  factory _$CoursePenaltyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoursePenaltyImplFromJson(json);

  @override
  final int athleteId;
  @override
  @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
  final CoursePenaltyKind kind;
  @override
  @JsonKey()
  final String code;

  @override
  String toString() {
    return 'CoursePenalty(athleteId: $athleteId, kind: $kind, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoursePenaltyImpl &&
            (identical(other.athleteId, athleteId) ||
                other.athleteId == athleteId) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, athleteId, kind, code);

  /// Create a copy of CoursePenalty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CoursePenaltyImplCopyWith<_$CoursePenaltyImpl> get copyWith =>
      __$$CoursePenaltyImplCopyWithImpl<_$CoursePenaltyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoursePenaltyImplToJson(
      this,
    );
  }
}

abstract class _CoursePenalty implements CoursePenalty {
  const factory _CoursePenalty(
      {required final int athleteId,
      @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
      required final CoursePenaltyKind kind,
      final String code}) = _$CoursePenaltyImpl;

  factory _CoursePenalty.fromJson(Map<String, dynamic> json) =
      _$CoursePenaltyImpl.fromJson;

  @override
  int get athleteId;
  @override
  @JsonKey(unknownEnumValue: CoursePenaltyKind.unknown)
  CoursePenaltyKind get kind;
  @override
  String get code;

  /// Create a copy of CoursePenalty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CoursePenaltyImplCopyWith<_$CoursePenaltyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
