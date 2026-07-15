// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Heat _$HeatFromJson(Map<String, dynamic> json) {
  return _Heat.fromJson(json);
}

/// @nodoc
mixin _$Heat {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  Race? get race => throw _privateConstructorUsedError;
  List<Result> get results => throw _privateConstructorUsedError;

  /// Serializes this Heat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatCopyWith<Heat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatCopyWith<$Res> {
  factory $HeatCopyWith(Heat value, $Res Function(Heat) then) =
      _$HeatCopyWithImpl<$Res, Heat>;
  @useResult
  $Res call(
      {int id,
      String name,
      bool done,
      int number,
      DateTime? updatedAt,
      DateTime? startDate,
      DateTime? endDate,
      Race? race,
      List<Result> results});

  $RaceCopyWith<$Res>? get race;
}

/// @nodoc
class _$HeatCopyWithImpl<$Res, $Val extends Heat>
    implements $HeatCopyWith<$Res> {
  _$HeatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
    Object? updatedAt = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? race = freezed,
    Object? results = null,
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
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      race: freezed == race
          ? _value.race
          : race // ignore: cast_nullable_to_non_nullable
              as Race?,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Result>,
    ) as $Val);
  }

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RaceCopyWith<$Res>? get race {
    if (_value.race == null) {
      return null;
    }

    return $RaceCopyWith<$Res>(_value.race!, (value) {
      return _then(_value.copyWith(race: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HeatImplCopyWith<$Res> implements $HeatCopyWith<$Res> {
  factory _$$HeatImplCopyWith(
          _$HeatImpl value, $Res Function(_$HeatImpl) then) =
      __$$HeatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      bool done,
      int number,
      DateTime? updatedAt,
      DateTime? startDate,
      DateTime? endDate,
      Race? race,
      List<Result> results});

  @override
  $RaceCopyWith<$Res>? get race;
}

/// @nodoc
class __$$HeatImplCopyWithImpl<$Res>
    extends _$HeatCopyWithImpl<$Res, _$HeatImpl>
    implements _$$HeatImplCopyWith<$Res> {
  __$$HeatImplCopyWithImpl(_$HeatImpl _value, $Res Function(_$HeatImpl) _then)
      : super(_value, _then);

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
    Object? updatedAt = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? race = freezed,
    Object? results = null,
  }) {
    return _then(_$HeatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      race: freezed == race
          ? _value.race
          : race // ignore: cast_nullable_to_non_nullable
              as Race?,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<Result>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatImpl implements _Heat {
  const _$HeatImpl(
      {this.id = 0,
      this.name = '',
      this.done = false,
      this.number = 0,
      this.updatedAt,
      this.startDate,
      this.endDate,
      this.race,
      final List<Result> results = const <Result>[]})
      : _results = results;

  factory _$HeatImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final bool done;
  @override
  @JsonKey()
  final int number;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final Race? race;
  final List<Result> _results;
  @override
  @JsonKey()
  List<Result> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'Heat(id: $id, name: $name, done: $done, number: $number, updatedAt: $updatedAt, startDate: $startDate, endDate: $endDate, race: $race, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.race, race) || other.race == race) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      done,
      number,
      updatedAt,
      startDate,
      endDate,
      race,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatImplCopyWith<_$HeatImpl> get copyWith =>
      __$$HeatImplCopyWithImpl<_$HeatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatImplToJson(
      this,
    );
  }
}

abstract class _Heat implements Heat {
  const factory _Heat(
      {final int id,
      final String name,
      final bool done,
      final int number,
      final DateTime? updatedAt,
      final DateTime? startDate,
      final DateTime? endDate,
      final Race? race,
      final List<Result> results}) = _$HeatImpl;

  factory _Heat.fromJson(Map<String, dynamic> json) = _$HeatImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  bool get done;
  @override
  int get number;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  Race? get race;
  @override
  List<Result> get results;

  /// Create a copy of Heat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatImplCopyWith<_$HeatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
