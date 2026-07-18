// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_placement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RacePlacement _$RacePlacementFromJson(Map<String, dynamic> json) {
  return _RacePlacement.fromJson(json);
}

/// @nodoc
mixin _$RacePlacement {
  int get siteId => throw _privateConstructorUsedError;
  DateTime get beginHour => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Serializes this RacePlacement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RacePlacement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RacePlacementCopyWith<RacePlacement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RacePlacementCopyWith<$Res> {
  factory $RacePlacementCopyWith(
          RacePlacement value, $Res Function(RacePlacement) then) =
      _$RacePlacementCopyWithImpl<$Res, RacePlacement>;
  @useResult
  $Res call({int siteId, DateTime beginHour, int durationMinutes});
}

/// @nodoc
class _$RacePlacementCopyWithImpl<$Res, $Val extends RacePlacement>
    implements $RacePlacementCopyWith<$Res> {
  _$RacePlacementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RacePlacement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? beginHour = null,
    Object? durationMinutes = null,
  }) {
    return _then(_value.copyWith(
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RacePlacementImplCopyWith<$Res>
    implements $RacePlacementCopyWith<$Res> {
  factory _$$RacePlacementImplCopyWith(
          _$RacePlacementImpl value, $Res Function(_$RacePlacementImpl) then) =
      __$$RacePlacementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int siteId, DateTime beginHour, int durationMinutes});
}

/// @nodoc
class __$$RacePlacementImplCopyWithImpl<$Res>
    extends _$RacePlacementCopyWithImpl<$Res, _$RacePlacementImpl>
    implements _$$RacePlacementImplCopyWith<$Res> {
  __$$RacePlacementImplCopyWithImpl(
      _$RacePlacementImpl _value, $Res Function(_$RacePlacementImpl) _then)
      : super(_value, _then);

  /// Create a copy of RacePlacement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? beginHour = null,
    Object? durationMinutes = null,
  }) {
    return _then(_$RacePlacementImpl(
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RacePlacementImpl implements _RacePlacement {
  const _$RacePlacementImpl(
      {required this.siteId,
      required this.beginHour,
      this.durationMinutes = 10});

  factory _$RacePlacementImpl.fromJson(Map<String, dynamic> json) =>
      _$$RacePlacementImplFromJson(json);

  @override
  final int siteId;
  @override
  final DateTime beginHour;
  @override
  @JsonKey()
  final int durationMinutes;

  @override
  String toString() {
    return 'RacePlacement(siteId: $siteId, beginHour: $beginHour, durationMinutes: $durationMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RacePlacementImpl &&
            (identical(other.siteId, siteId) || other.siteId == siteId) &&
            (identical(other.beginHour, beginHour) ||
                other.beginHour == beginHour) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, siteId, beginHour, durationMinutes);

  /// Create a copy of RacePlacement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RacePlacementImplCopyWith<_$RacePlacementImpl> get copyWith =>
      __$$RacePlacementImplCopyWithImpl<_$RacePlacementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RacePlacementImplToJson(
      this,
    );
  }
}

abstract class _RacePlacement implements RacePlacement {
  const factory _RacePlacement(
      {required final int siteId,
      required final DateTime beginHour,
      final int durationMinutes}) = _$RacePlacementImpl;

  factory _RacePlacement.fromJson(Map<String, dynamic> json) =
      _$RacePlacementImpl.fromJson;

  @override
  int get siteId;
  @override
  DateTime get beginHour;
  @override
  int get durationMinutes;

  /// Create a copy of RacePlacement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RacePlacementImplCopyWith<_$RacePlacementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
