// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_block.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScheduleBlock _$ScheduleBlockFromJson(Map<String, dynamic> json) {
  return _ScheduleBlock.fromJson(json);
}

/// @nodoc
mixin _$ScheduleBlock {
  int get id => throw _privateConstructorUsedError;
  int get siteId => throw _privateConstructorUsedError;
  DateTime get day => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  int? get raceId => throw _privateConstructorUsedError;
  String get manualLabel => throw _privateConstructorUsedError;

  /// Serializes this ScheduleBlock to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScheduleBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScheduleBlockCopyWith<ScheduleBlock> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleBlockCopyWith<$Res> {
  factory $ScheduleBlockCopyWith(
          ScheduleBlock value, $Res Function(ScheduleBlock) then) =
      _$ScheduleBlockCopyWithImpl<$Res, ScheduleBlock>;
  @useResult
  $Res call(
      {int id,
      int siteId,
      DateTime day,
      int order,
      int durationMinutes,
      int? raceId,
      String manualLabel});
}

/// @nodoc
class _$ScheduleBlockCopyWithImpl<$Res, $Val extends ScheduleBlock>
    implements $ScheduleBlockCopyWith<$Res> {
  _$ScheduleBlockCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScheduleBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? siteId = null,
    Object? day = null,
    Object? order = null,
    Object? durationMinutes = null,
    Object? raceId = freezed,
    Object? manualLabel = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: freezed == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int?,
      manualLabel: null == manualLabel
          ? _value.manualLabel
          : manualLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleBlockImplCopyWith<$Res>
    implements $ScheduleBlockCopyWith<$Res> {
  factory _$$ScheduleBlockImplCopyWith(
          _$ScheduleBlockImpl value, $Res Function(_$ScheduleBlockImpl) then) =
      __$$ScheduleBlockImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int siteId,
      DateTime day,
      int order,
      int durationMinutes,
      int? raceId,
      String manualLabel});
}

/// @nodoc
class __$$ScheduleBlockImplCopyWithImpl<$Res>
    extends _$ScheduleBlockCopyWithImpl<$Res, _$ScheduleBlockImpl>
    implements _$$ScheduleBlockImplCopyWith<$Res> {
  __$$ScheduleBlockImplCopyWithImpl(
      _$ScheduleBlockImpl _value, $Res Function(_$ScheduleBlockImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScheduleBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? siteId = null,
    Object? day = null,
    Object? order = null,
    Object? durationMinutes = null,
    Object? raceId = freezed,
    Object? manualLabel = null,
  }) {
    return _then(_$ScheduleBlockImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      siteId: null == siteId
          ? _value.siteId
          : siteId // ignore: cast_nullable_to_non_nullable
              as int,
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as DateTime,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: freezed == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int?,
      manualLabel: null == manualLabel
          ? _value.manualLabel
          : manualLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScheduleBlockImpl implements _ScheduleBlock {
  const _$ScheduleBlockImpl(
      {required this.id,
      required this.siteId,
      required this.day,
      required this.order,
      this.durationMinutes = 10,
      this.raceId,
      this.manualLabel = ''});

  factory _$ScheduleBlockImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScheduleBlockImplFromJson(json);

  @override
  final int id;
  @override
  final int siteId;
  @override
  final DateTime day;
  @override
  final int order;
  @override
  @JsonKey()
  final int durationMinutes;
  @override
  final int? raceId;
  @override
  @JsonKey()
  final String manualLabel;

  @override
  String toString() {
    return 'ScheduleBlock(id: $id, siteId: $siteId, day: $day, order: $order, durationMinutes: $durationMinutes, raceId: $raceId, manualLabel: $manualLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleBlockImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.siteId, siteId) || other.siteId == siteId) &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.raceId, raceId) || other.raceId == raceId) &&
            (identical(other.manualLabel, manualLabel) ||
                other.manualLabel == manualLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, siteId, day, order,
      durationMinutes, raceId, manualLabel);

  /// Create a copy of ScheduleBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleBlockImplCopyWith<_$ScheduleBlockImpl> get copyWith =>
      __$$ScheduleBlockImplCopyWithImpl<_$ScheduleBlockImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScheduleBlockImplToJson(
      this,
    );
  }
}

abstract class _ScheduleBlock implements ScheduleBlock {
  const factory _ScheduleBlock(
      {required final int id,
      required final int siteId,
      required final DateTime day,
      required final int order,
      final int durationMinutes,
      final int? raceId,
      final String manualLabel}) = _$ScheduleBlockImpl;

  factory _ScheduleBlock.fromJson(Map<String, dynamic> json) =
      _$ScheduleBlockImpl.fromJson;

  @override
  int get id;
  @override
  int get siteId;
  @override
  DateTime get day;
  @override
  int get order;
  @override
  int get durationMinutes;
  @override
  int? get raceId;
  @override
  String get manualLabel;

  /// Create a copy of ScheduleBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScheduleBlockImplCopyWith<_$ScheduleBlockImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
