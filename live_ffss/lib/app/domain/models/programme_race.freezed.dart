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
      throw _privateConstructorUsedError; // Entries drawn into this race, one per lane, in lane order — the FFSS
// « place » model: a lane seats one engagement, a relay team included.
// Empty for a draw made before this field existed; `athleteIds` then
// remains the only record.
  List<int> get entryIds =>
      throw _privateConstructorUsedError; // The drawn athletes, flattened in lane order — a relay team contributes
// all its members here while holding a single slot in `entryIds`. What
// the result and display code reads.
  List<int> get athleteIds =>
      throw _privateConstructorUsedError; // The order this race was crossed in — one entry per finishing group, a
// group of several being a declared tie. Places are computed from this
// and never stored: that is what makes a removal renumber for free.
  List<List<int>> get finishOrder =>
      throw _privateConstructorUsedError; // Athletes out of the ranking. They take no place, so the athletes after
// them number as though they had not started.
  List<CoursePenalty> get penalties =>
      throw _privateConstructorUsedError; // The FFSS course this heat runs as, 0 while it has none. The draw lives
// on the device and the timetable on the server: without this id nothing
// says that heat 2 is the 08:10 start on OCEAN 1.
//
// Recorded rather than matched by position: deleting a course would shift
// every later heat onto a start that is not its own, silently.
  int get runId => throw _privateConstructorUsedError;

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
      {int id,
      int number,
      List<int> sourceRaceIds,
      List<int> entryIds,
      List<int> athleteIds,
      List<List<int>> finishOrder,
      List<CoursePenalty> penalties,
      int runId});
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
    Object? entryIds = null,
    Object? athleteIds = null,
    Object? finishOrder = null,
    Object? penalties = null,
    Object? runId = null,
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
      entryIds: null == entryIds
          ? _value.entryIds
          : entryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      athleteIds: null == athleteIds
          ? _value.athleteIds
          : athleteIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      finishOrder: null == finishOrder
          ? _value.finishOrder
          : finishOrder // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      penalties: null == penalties
          ? _value.penalties
          : penalties // ignore: cast_nullable_to_non_nullable
              as List<CoursePenalty>,
      runId: null == runId
          ? _value.runId
          : runId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
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
      {int id,
      int number,
      List<int> sourceRaceIds,
      List<int> entryIds,
      List<int> athleteIds,
      List<List<int>> finishOrder,
      List<CoursePenalty> penalties,
      int runId});
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
    Object? entryIds = null,
    Object? athleteIds = null,
    Object? finishOrder = null,
    Object? penalties = null,
    Object? runId = null,
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
      entryIds: null == entryIds
          ? _value._entryIds
          : entryIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      athleteIds: null == athleteIds
          ? _value._athleteIds
          : athleteIds // ignore: cast_nullable_to_non_nullable
              as List<int>,
      finishOrder: null == finishOrder
          ? _value._finishOrder
          : finishOrder // ignore: cast_nullable_to_non_nullable
              as List<List<int>>,
      penalties: null == penalties
          ? _value._penalties
          : penalties // ignore: cast_nullable_to_non_nullable
              as List<CoursePenalty>,
      runId: null == runId
          ? _value.runId
          : runId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$ProgrammeRaceImpl implements _ProgrammeRace {
  const _$ProgrammeRaceImpl(
      {required this.id,
      required this.number,
      final List<int> sourceRaceIds = const <int>[],
      final List<int> entryIds = const <int>[],
      final List<int> athleteIds = const <int>[],
      final List<List<int>> finishOrder = const <List<int>>[],
      final List<CoursePenalty> penalties = const <CoursePenalty>[],
      this.runId = 0})
      : _sourceRaceIds = sourceRaceIds,
        _entryIds = entryIds,
        _athleteIds = athleteIds,
        _finishOrder = finishOrder,
        _penalties = penalties;

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

// Entries drawn into this race, one per lane, in lane order — the FFSS
// « place » model: a lane seats one engagement, a relay team included.
// Empty for a draw made before this field existed; `athleteIds` then
// remains the only record.
  final List<int> _entryIds;
// Entries drawn into this race, one per lane, in lane order — the FFSS
// « place » model: a lane seats one engagement, a relay team included.
// Empty for a draw made before this field existed; `athleteIds` then
// remains the only record.
  @override
  @JsonKey()
  List<int> get entryIds {
    if (_entryIds is EqualUnmodifiableListView) return _entryIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entryIds);
  }

// The drawn athletes, flattened in lane order — a relay team contributes
// all its members here while holding a single slot in `entryIds`. What
// the result and display code reads.
  final List<int> _athleteIds;
// The drawn athletes, flattened in lane order — a relay team contributes
// all its members here while holding a single slot in `entryIds`. What
// the result and display code reads.
  @override
  @JsonKey()
  List<int> get athleteIds {
    if (_athleteIds is EqualUnmodifiableListView) return _athleteIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athleteIds);
  }

// The order this race was crossed in — one entry per finishing group, a
// group of several being a declared tie. Places are computed from this
// and never stored: that is what makes a removal renumber for free.
  final List<List<int>> _finishOrder;
// The order this race was crossed in — one entry per finishing group, a
// group of several being a declared tie. Places are computed from this
// and never stored: that is what makes a removal renumber for free.
  @override
  @JsonKey()
  List<List<int>> get finishOrder {
    if (_finishOrder is EqualUnmodifiableListView) return _finishOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_finishOrder);
  }

// Athletes out of the ranking. They take no place, so the athletes after
// them number as though they had not started.
  final List<CoursePenalty> _penalties;
// Athletes out of the ranking. They take no place, so the athletes after
// them number as though they had not started.
  @override
  @JsonKey()
  List<CoursePenalty> get penalties {
    if (_penalties is EqualUnmodifiableListView) return _penalties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_penalties);
  }

// The FFSS course this heat runs as, 0 while it has none. The draw lives
// on the device and the timetable on the server: without this id nothing
// says that heat 2 is the 08:10 start on OCEAN 1.
//
// Recorded rather than matched by position: deleting a course would shift
// every later heat onto a start that is not its own, silently.
  @override
  @JsonKey()
  final int runId;

  @override
  String toString() {
    return 'ProgrammeRace(id: $id, number: $number, sourceRaceIds: $sourceRaceIds, entryIds: $entryIds, athleteIds: $athleteIds, finishOrder: $finishOrder, penalties: $penalties, runId: $runId)';
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
            const DeepCollectionEquality().equals(other._entryIds, _entryIds) &&
            const DeepCollectionEquality()
                .equals(other._athleteIds, _athleteIds) &&
            const DeepCollectionEquality()
                .equals(other._finishOrder, _finishOrder) &&
            const DeepCollectionEquality()
                .equals(other._penalties, _penalties) &&
            (identical(other.runId, runId) || other.runId == runId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      number,
      const DeepCollectionEquality().hash(_sourceRaceIds),
      const DeepCollectionEquality().hash(_entryIds),
      const DeepCollectionEquality().hash(_athleteIds),
      const DeepCollectionEquality().hash(_finishOrder),
      const DeepCollectionEquality().hash(_penalties),
      runId);

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
      final List<int> entryIds,
      final List<int> athleteIds,
      final List<List<int>> finishOrder,
      final List<CoursePenalty> penalties,
      final int runId}) = _$ProgrammeRaceImpl;

  factory _ProgrammeRace.fromJson(Map<String, dynamic> json) =
      _$ProgrammeRaceImpl.fromJson;

  @override
  int get id;
  @override
  int get number; // opt1/opt2 wiring: ids of the feeding races at the previous level.
// Empty at the séries level and for opt2-with-no-selection.
  @override
  List<int>
      get sourceRaceIds; // Entries drawn into this race, one per lane, in lane order — the FFSS
// « place » model: a lane seats one engagement, a relay team included.
// Empty for a draw made before this field existed; `athleteIds` then
// remains the only record.
  @override
  List<int>
      get entryIds; // The drawn athletes, flattened in lane order — a relay team contributes
// all its members here while holding a single slot in `entryIds`. What
// the result and display code reads.
  @override
  List<int>
      get athleteIds; // The order this race was crossed in — one entry per finishing group, a
// group of several being a declared tie. Places are computed from this
// and never stored: that is what makes a removal renumber for free.
  @override
  List<List<int>>
      get finishOrder; // Athletes out of the ranking. They take no place, so the athletes after
// them number as though they had not started.
  @override
  List<CoursePenalty>
      get penalties; // The FFSS course this heat runs as, 0 while it has none. The draw lives
// on the device and the timetable on the server: without this id nothing
// says that heat 2 is the 08:10 start on OCEAN 1.
//
// Recorded rather than matched by position: deleting a course would shift
// every later heat onto a start that is not its own, silently.
  @override
  int get runId;

  /// Create a copy of ProgrammeRace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgrammeRaceImplCopyWith<_$ProgrammeRaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
