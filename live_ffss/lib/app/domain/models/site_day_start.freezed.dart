// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'site_day_start.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SiteDayStart _$SiteDayStartFromJson(Map<String, dynamic> json) {
  return _SiteDayStart.fromJson(json);
}

/// @nodoc
mixin _$SiteDayStart {
  int get siteId => throw _privateConstructorUsedError;
  DateTime get day => throw _privateConstructorUsedError;
  int get startMinutes => throw _privateConstructorUsedError;

  /// Serializes this SiteDayStart to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SiteDayStart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SiteDayStartCopyWith<SiteDayStart> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SiteDayStartCopyWith<$Res> {
  factory $SiteDayStartCopyWith(
          SiteDayStart value, $Res Function(SiteDayStart) then) =
      _$SiteDayStartCopyWithImpl<$Res, SiteDayStart>;
  @useResult
  $Res call({int siteId, DateTime day, int startMinutes});
}

/// @nodoc
class _$SiteDayStartCopyWithImpl<$Res, $Val extends SiteDayStart>
    implements $SiteDayStartCopyWith<$Res> {
  _$SiteDayStartCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SiteDayStart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? day = null,
    Object? startMinutes = null,
  }) {
    return _then(_value.copyWith(
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startMinutes: null == startMinutes
          ? _value.startMinutes
          : startMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SiteDayStartImplCopyWith<$Res>
    implements $SiteDayStartCopyWith<$Res> {
  factory _$$SiteDayStartImplCopyWith(
          _$SiteDayStartImpl value, $Res Function(_$SiteDayStartImpl) then) =
      __$$SiteDayStartImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int siteId, DateTime day, int startMinutes});
}

/// @nodoc
class __$$SiteDayStartImplCopyWithImpl<$Res>
    extends _$SiteDayStartCopyWithImpl<$Res, _$SiteDayStartImpl>
    implements _$$SiteDayStartImplCopyWith<$Res> {
  __$$SiteDayStartImplCopyWithImpl(
      _$SiteDayStartImpl _value, $Res Function(_$SiteDayStartImpl) _then)
      : super(_value, _then);

  /// Create a copy of SiteDayStart
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? siteId = null,
    Object? day = null,
    Object? startMinutes = null,
  }) {
    return _then(_$SiteDayStartImpl(
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      startMinutes: null == startMinutes
          ? _value.startMinutes
          : startMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SiteDayStartImpl implements _SiteDayStart {
  const _$SiteDayStartImpl(
      {required this.siteId, required this.day, required this.startMinutes});

  factory _$SiteDayStartImpl.fromJson(Map<String, dynamic> json) =>
      _$$SiteDayStartImplFromJson(json);

  @override
  final int siteId;
  @override
  final DateTime day;
  @override
  final int startMinutes;

  @override
  String toString() {
    return 'SiteDayStart(siteId: $siteId, day: $day, startMinutes: $startMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SiteDayStartImpl &&
            (identical(other.siteId, siteId) || other.siteId == siteId) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.startMinutes, startMinutes) ||
                other.startMinutes == startMinutes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, siteId, day, startMinutes);

  /// Create a copy of SiteDayStart
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SiteDayStartImplCopyWith<_$SiteDayStartImpl> get copyWith =>
      __$$SiteDayStartImplCopyWithImpl<_$SiteDayStartImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SiteDayStartImplToJson(
      this,
    );
  }
}

abstract class _SiteDayStart implements SiteDayStart {
  const factory _SiteDayStart(
      {required final int siteId,
      required final DateTime day,
      required final int startMinutes}) = _$SiteDayStartImpl;

  factory _SiteDayStart.fromJson(Map<String, dynamic> json) =
      _$SiteDayStartImpl.fromJson;

  @override
  int get siteId;
  @override
  DateTime get day;
  @override
  int get startMinutes;

  /// Create a copy of SiteDayStart
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SiteDayStartImplCopyWith<_$SiteDayStartImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
