// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'round_level.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoundLevel _$RoundLevelFromJson(Map<String, dynamic> json) {
  return _RoundLevel.fromJson(json);
}

/// @nodoc
mixin _$RoundLevel {
  @JsonKey(unknownEnumValue: RoundType.unknown)
  RoundType get type =>
      throw _privateConstructorUsedError; // Operator metadata; drives no computation in v1 (no seeding).
  int get qualifiersPerRace => throw _privateConstructorUsedError;
  List<ProgrammeRace> get races => throw _privateConstructorUsedError;

  /// Serializes this RoundLevel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoundLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoundLevelCopyWith<RoundLevel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoundLevelCopyWith<$Res> {
  factory $RoundLevelCopyWith(
          RoundLevel value, $Res Function(RoundLevel) then) =
      _$RoundLevelCopyWithImpl<$Res, RoundLevel>;
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: RoundType.unknown) RoundType type,
      int qualifiersPerRace,
      List<ProgrammeRace> races});
}

/// @nodoc
class _$RoundLevelCopyWithImpl<$Res, $Val extends RoundLevel>
    implements $RoundLevelCopyWith<$Res> {
  _$RoundLevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoundLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? qualifiersPerRace = null,
    Object? races = null,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoundType,
      qualifiersPerRace: null == qualifiersPerRace
          ? _value.qualifiersPerRace
          : qualifiersPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      races: null == races
          ? _value.races
          : races // ignore: cast_nullable_to_non_nullable
              as List<ProgrammeRace>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoundLevelImplCopyWith<$Res>
    implements $RoundLevelCopyWith<$Res> {
  factory _$$RoundLevelImplCopyWith(
          _$RoundLevelImpl value, $Res Function(_$RoundLevelImpl) then) =
      __$$RoundLevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(unknownEnumValue: RoundType.unknown) RoundType type,
      int qualifiersPerRace,
      List<ProgrammeRace> races});
}

/// @nodoc
class __$$RoundLevelImplCopyWithImpl<$Res>
    extends _$RoundLevelCopyWithImpl<$Res, _$RoundLevelImpl>
    implements _$$RoundLevelImplCopyWith<$Res> {
  __$$RoundLevelImplCopyWithImpl(
      _$RoundLevelImpl _value, $Res Function(_$RoundLevelImpl) _then)
      : super(_value, _then);

  /// Create a copy of RoundLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? qualifiersPerRace = null,
    Object? races = null,
  }) {
    return _then(_$RoundLevelImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as RoundType,
      qualifiersPerRace: null == qualifiersPerRace
          ? _value.qualifiersPerRace
          : qualifiersPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      races: null == races
          ? _value._races
          : races // ignore: cast_nullable_to_non_nullable
              as List<ProgrammeRace>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoundLevelImpl implements _RoundLevel {
  const _$RoundLevelImpl(
      {@JsonKey(unknownEnumValue: RoundType.unknown) required this.type,
      this.qualifiersPerRace = 0,
      final List<ProgrammeRace> races = const <ProgrammeRace>[]})
      : _races = races;

  factory _$RoundLevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoundLevelImplFromJson(json);

  @override
  @JsonKey(unknownEnumValue: RoundType.unknown)
  final RoundType type;
// Operator metadata; drives no computation in v1 (no seeding).
  @override
  @JsonKey()
  final int qualifiersPerRace;
  final List<ProgrammeRace> _races;
  @override
  @JsonKey()
  List<ProgrammeRace> get races {
    if (_races is EqualUnmodifiableListView) return _races;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_races);
  }

  @override
  String toString() {
    return 'RoundLevel(type: $type, qualifiersPerRace: $qualifiersPerRace, races: $races)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoundLevelImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.qualifiersPerRace, qualifiersPerRace) ||
                other.qualifiersPerRace == qualifiersPerRace) &&
            const DeepCollectionEquality().equals(other._races, _races));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, qualifiersPerRace,
      const DeepCollectionEquality().hash(_races));

  /// Create a copy of RoundLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoundLevelImplCopyWith<_$RoundLevelImpl> get copyWith =>
      __$$RoundLevelImplCopyWithImpl<_$RoundLevelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoundLevelImplToJson(
      this,
    );
  }
}

abstract class _RoundLevel implements RoundLevel {
  const factory _RoundLevel(
      {@JsonKey(unknownEnumValue: RoundType.unknown)
      required final RoundType type,
      final int qualifiersPerRace,
      final List<ProgrammeRace> races}) = _$RoundLevelImpl;

  factory _RoundLevel.fromJson(Map<String, dynamic> json) =
      _$RoundLevelImpl.fromJson;

  @override
  @JsonKey(unknownEnumValue: RoundType.unknown)
  RoundType
      get type; // Operator metadata; drives no computation in v1 (no seeding).
  @override
  int get qualifiersPerRace;
  @override
  List<ProgrammeRace> get races;

  /// Create a copy of RoundLevel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoundLevelImplCopyWith<_$RoundLevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
