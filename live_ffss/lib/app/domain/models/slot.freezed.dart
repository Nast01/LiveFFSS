// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Slot _$SlotFromJson(Map<String, dynamic> json) {
  return _Slot.fromJson(json);
}

/// @nodoc
mixin _$Slot {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime get beginHour => throw _privateConstructorUsedError;
  DateTime get endHour => throw _privateConstructorUsedError;
  RaceFormatDetail? get raceFormatDetail => throw _privateConstructorUsedError;
  List<Run> get runs => throw _privateConstructorUsedError;

  /// Serializes this Slot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotCopyWith<Slot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotCopyWith<$Res> {
  factory $SlotCopyWith(Slot value, $Res Function(Slot) then) =
      _$SlotCopyWithImpl<$Res, Slot>;
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime beginHour,
      DateTime endHour,
      RaceFormatDetail? raceFormatDetail,
      List<Run> runs});

  $RaceFormatDetailCopyWith<$Res>? get raceFormatDetail;
}

/// @nodoc
class _$SlotCopyWithImpl<$Res, $Val extends Slot>
    implements $SlotCopyWith<$Res> {
  _$SlotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? raceFormatDetail = freezed,
    Object? runs = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      raceFormatDetail: freezed == raceFormatDetail
          ? _value.raceFormatDetail
          : raceFormatDetail // ignore: cast_nullable_to_non_nullable
              as RaceFormatDetail?,
      runs: null == runs
          ? _value.runs
          : runs // ignore: cast_nullable_to_non_nullable
              as List<Run>,
    ) as $Val);
  }

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RaceFormatDetailCopyWith<$Res>? get raceFormatDetail {
    if (_value.raceFormatDetail == null) {
      return null;
    }

    return $RaceFormatDetailCopyWith<$Res>(_value.raceFormatDetail!, (value) {
      return _then(_value.copyWith(raceFormatDetail: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SlotImplCopyWith<$Res> implements $SlotCopyWith<$Res> {
  factory _$$SlotImplCopyWith(
          _$SlotImpl value, $Res Function(_$SlotImpl) then) =
      __$$SlotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime beginHour,
      DateTime endHour,
      RaceFormatDetail? raceFormatDetail,
      List<Run> runs});

  @override
  $RaceFormatDetailCopyWith<$Res>? get raceFormatDetail;
}

/// @nodoc
class __$$SlotImplCopyWithImpl<$Res>
    extends _$SlotCopyWithImpl<$Res, _$SlotImpl>
    implements _$$SlotImplCopyWith<$Res> {
  __$$SlotImplCopyWithImpl(_$SlotImpl _value, $Res Function(_$SlotImpl) _then)
      : super(_value, _then);

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? raceFormatDetail = freezed,
    Object? runs = null,
  }) {
    return _then(_$SlotImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as DateTime,
      raceFormatDetail: freezed == raceFormatDetail
          ? _value.raceFormatDetail
          : raceFormatDetail // ignore: cast_nullable_to_non_nullable
              as RaceFormatDetail?,
      runs: null == runs
          ? _value._runs
          : runs // ignore: cast_nullable_to_non_nullable
              as List<Run>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotImpl implements _Slot {
  const _$SlotImpl(
      {required this.id,
      required this.name,
      required this.beginHour,
      required this.endHour,
      this.raceFormatDetail,
      final List<Run> runs = const <Run>[]})
      : _runs = runs;

  factory _$SlotImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final DateTime beginHour;
  @override
  final DateTime endHour;
  @override
  final RaceFormatDetail? raceFormatDetail;
  final List<Run> _runs;
  @override
  @JsonKey()
  List<Run> get runs {
    if (_runs is EqualUnmodifiableListView) return _runs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_runs);
  }

  @override
  String toString() {
    return 'Slot(id: $id, name: $name, beginHour: $beginHour, endHour: $endHour, raceFormatDetail: $raceFormatDetail, runs: $runs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.beginHour, beginHour) ||
                other.beginHour == beginHour) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.raceFormatDetail, raceFormatDetail) ||
                other.raceFormatDetail == raceFormatDetail) &&
            const DeepCollectionEquality().equals(other._runs, _runs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, beginHour, endHour,
      raceFormatDetail, const DeepCollectionEquality().hash(_runs));

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      __$$SlotImplCopyWithImpl<_$SlotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotImplToJson(
      this,
    );
  }
}

abstract class _Slot implements Slot {
  const factory _Slot(
      {required final int id,
      required final String name,
      required final DateTime beginHour,
      required final DateTime endHour,
      final RaceFormatDetail? raceFormatDetail,
      final List<Run> runs}) = _$SlotImpl;

  factory _Slot.fromJson(Map<String, dynamic> json) = _$SlotImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  DateTime get beginHour;
  @override
  DateTime get endHour;
  @override
  RaceFormatDetail? get raceFormatDetail;
  @override
  List<Run> get runs;

  /// Create a copy of Slot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotImplCopyWith<_$SlotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
