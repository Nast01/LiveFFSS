// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'programme_race.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgrammeRace _$ProgrammeRaceFromJson(Map<String, dynamic> json) {
  return _ProgrammeRace.fromJson(json);
}

/// @nodoc
mixin _$ProgrammeRace {
  int get id => throw _privateConstructorUsedError;
  int get number =>
      throw _privateConstructorUsedError; // opt1/opt2 wiring: ids of the feeding races at the previous level.
// Empty at the séries level and for opt2-with-no-selection.
  List<int> get sourceRaceIds =>
      throw _privateConstructorUsedError; // null until the race is scheduled (Plan B fills this).
  RacePlacement? get placement => throw _privateConstructorUsedError;

  /// Serializes this ProgrammeRace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgrammeRaceCopyWith<ProgrammeRace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgrammeRaceCopyWith<$Res> {
  factory $ProgrammeRaceCopyWith(
          ProgrammeRace value, $Res Function(ProgrammeRace) then) =
      _$ProgrammeRaceCopyWithImpl<$Res, ProgrammeRace>;
  @useResult
  $Res call(
      {int id, int number, List<int> sourceRaceIds, RacePlacement? placement});

  $RacePlacementCopyWith<$Res>? get placement;
}

/// @nodoc
class _$ProgrammeRaceCopyWithImpl<$Res, $Val extends ProgrammeRace>
    implements $ProgrammeRaceCopyWith<$Res> {
  _$ProgrammeRaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? sourceRaceIds = null,
    Object? placement = freezed,
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
      sourceRaceIds: null == sourceRaceIds
          ? _value.sourceRaceIds
          : sourceRaceIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      placement: freezed == placement
          ? _value.placement
          : placement // ignore: cast_nullable_to_non_nullable
              as RacePlacement?,
    ) as $Val);
  }

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RacePlacementCopyWith<$Res>? get placement {
    if (_value.placement == null) {
      return null;
    }

    return $RacePlacementCopyWith<$Res>(_value.placement!, (value) {
      return _then(_value.copyWith(placement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgrammeRaceImplCopyWith<$Res>
    implements $ProgrammeRaceCopyWith<$Res> {
  factory _$$ProgrammeRaceImplCopyWith(
          _$ProgrammeRaceImpl value, $Res Function(_$ProgrammeRaceImpl) then) =
      __$$ProgrammeRaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id, int number, List<int> sourceRaceIds, RacePlacement? placement});

  @override
  $RacePlacementCopyWith<$Res>? get placement;
}

/// @nodoc
class __$$ProgrammeRaceImplCopyWithImpl<$Res>
    extends _$ProgrammeRaceCopyWithImpl<$Res, _$ProgrammeRaceImpl>
    implements _$$ProgrammeRaceImplCopyWith<$Res> {
  __$$ProgrammeRaceImplCopyWithImpl(
      _$ProgrammeRaceImpl _value, $Res Function(_$ProgrammeRaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? sourceRaceIds = null,
    Object? placement = freezed,
  }) {
    return _then(_$ProgrammeRaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      sourceRaceIds: null == sourceRaceIds
          ? _value._sourceRaceIds
          : sourceRaceIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      placement: freezed == placement
          ? _value.placement
          : placement // ignore: cast_nullable_to_non_nullable
              as RacePlacement?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgrammeRaceImpl implements _ProgrammeRace {
  const _$ProgrammeRaceImpl(
      {required this.id,
      required this.number,
      final List<int> sourceRaceIds = const <int>[],
      this.placement})
      : _sourceRaceIds = sourceRaceIds;

  factory _$ProgrammeRaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgrammeRaceImplFromJson(json);

  @override
  final int id;
  @override
  final int number;
// opt1/opt2 wiring: ids of the feeding races at the previous level.
// Empty at the séries level and for opt2-with-no-selection.
  final List<int> _sourceRaceIds;
// opt1/opt2 wiring: ids of the feeding races at the previous level.
// Empty at the séries level and for opt2-with-no-selection.
  @override
  @JsonKey()
  List<int> get sourceRaceIds {
    if (_sourceRaceIds is EqualUnmodifiableListView) return _sourceRaceIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sourceRaceIds);
  }

// null until the race is scheduled (Plan B fills this).
  @override
  final RacePlacement? placement;

  @override
  String toString() {
    return 'ProgrammeRace(id: $id, number: $number, sourceRaceIds: $sourceRaceIds, placement: $placement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgrammeRaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            const DeepCollectionEquality()
                .equals(other._sourceRaceIds, _sourceRaceIds) &&
            (identical(other.placement, placement) ||
                other.placement == placement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, number,
      const DeepCollectionEquality().hash(_sourceRaceIds), placement);

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgrammeRaceImplCopyWith<_$ProgrammeRaceImpl> get copyWith =>
      __$$ProgrammeRaceImplCopyWithImpl<_$ProgrammeRaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgrammeRaceImplToJson(
      this,
    );
  }
}

abstract class _ProgrammeRace implements ProgrammeRace {
  const factory _ProgrammeRace(
      {required final int id,
      required final int number,
      final List<int> sourceRaceIds,
      final RacePlacement? placement}) = _$ProgrammeRaceImpl;

  factory _ProgrammeRace.fromJson(Map<String, dynamic> json) =
      _$ProgrammeRaceImpl.fromJson;

  @override
  int get id;
  @override
  int get number; // opt1/opt2 wiring: ids of the feeding races at the previous level.
// Empty at the séries level and for opt2-with-no-selection.
  @override
  List<int>
      get sourceRaceIds; // null until the race is scheduled (Plan B fills this).
  @override
  RacePlacement? get placement;

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgrammeRaceImplCopyWith<_$ProgrammeRaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
