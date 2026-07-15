// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discipline.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Discipline _$DisciplineFromJson(Map<String, dynamic> json) {
  return _Discipline.fromJson(json);
}

/// @nodoc
mixin _$Discipline {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get speciality => throw _privateConstructorUsedError;
  String get specialityLabel => throw _privateConstructorUsedError;
  int get distance => throw _privateConstructorUsedError;
  int get numberOfAthletes => throw _privateConstructorUsedError;
  bool get isRelay => throw _privateConstructorUsedError;
  bool get hasTime => throw _privateConstructorUsedError;

  /// Serializes this Discipline to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Discipline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisciplineCopyWith<Discipline> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisciplineCopyWith<$Res> {
  factory $DisciplineCopyWith(
          Discipline value, $Res Function(Discipline) then) =
      _$DisciplineCopyWithImpl<$Res, Discipline>;
  @useResult
  $Res call(
      {String id,
      String name,
      int speciality,
      String specialityLabel,
      int distance,
      int numberOfAthletes,
      bool isRelay,
      bool hasTime});
}

/// @nodoc
class _$DisciplineCopyWithImpl<$Res, $Val extends Discipline>
    implements $DisciplineCopyWith<$Res> {
  _$DisciplineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Discipline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? speciality = null,
    Object? specialityLabel = null,
    Object? distance = null,
    Object? numberOfAthletes = null,
    Object? isRelay = null,
    Object? hasTime = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      speciality: null == speciality
          ? _value.speciality
          : speciality // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfAthletes: null == numberOfAthletes
          ? _value.numberOfAthletes
          : numberOfAthletes // ignore: cast_nullable_to_non_nullable
              as int,
      isRelay: null == isRelay
          ? _value.isRelay
          : isRelay // ignore: cast_nullable_to_non_nullable
              as bool,
      hasTime: null == hasTime
          ? _value.hasTime
          : hasTime // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DisciplineImplCopyWith<$Res>
    implements $DisciplineCopyWith<$Res> {
  factory _$$DisciplineImplCopyWith(
          _$DisciplineImpl value, $Res Function(_$DisciplineImpl) then) =
      __$$DisciplineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int speciality,
      String specialityLabel,
      int distance,
      int numberOfAthletes,
      bool isRelay,
      bool hasTime});
}

/// @nodoc
class __$$DisciplineImplCopyWithImpl<$Res>
    extends _$DisciplineCopyWithImpl<$Res, _$DisciplineImpl>
    implements _$$DisciplineImplCopyWith<$Res> {
  __$$DisciplineImplCopyWithImpl(
      _$DisciplineImpl _value, $Res Function(_$DisciplineImpl) _then)
      : super(_value, _then);

  /// Create a copy of Discipline
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? speciality = null,
    Object? specialityLabel = null,
    Object? distance = null,
    Object? numberOfAthletes = null,
    Object? isRelay = null,
    Object? hasTime = null,
  }) {
    return _then(_$DisciplineImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      speciality: null == speciality
          ? _value.speciality
          : speciality // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int,
      numberOfAthletes: null == numberOfAthletes
          ? _value.numberOfAthletes
          : numberOfAthletes // ignore: cast_nullable_to_non_nullable
              as int,
      isRelay: null == isRelay
          ? _value.isRelay
          : isRelay // ignore: cast_nullable_to_non_nullable
              as bool,
      hasTime: null == hasTime
          ? _value.hasTime
          : hasTime // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DisciplineImpl implements _Discipline {
  const _$DisciplineImpl(
      {required this.id,
      required this.name,
      required this.speciality,
      required this.specialityLabel,
      this.distance = 0,
      this.numberOfAthletes = 0,
      this.isRelay = false,
      this.hasTime = false});

  factory _$DisciplineImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisciplineImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int speciality;
  @override
  final String specialityLabel;
  @override
  @JsonKey()
  final int distance;
  @override
  @JsonKey()
  final int numberOfAthletes;
  @override
  @JsonKey()
  final bool isRelay;
  @override
  @JsonKey()
  final bool hasTime;

  @override
  String toString() {
    return 'Discipline(id: $id, name: $name, speciality: $speciality, specialityLabel: $specialityLabel, distance: $distance, numberOfAthletes: $numberOfAthletes, isRelay: $isRelay, hasTime: $hasTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisciplineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.speciality, speciality) ||
                other.speciality == speciality) &&
            (identical(other.specialityLabel, specialityLabel) ||
                other.specialityLabel == specialityLabel) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.numberOfAthletes, numberOfAthletes) ||
                other.numberOfAthletes == numberOfAthletes) &&
            (identical(other.isRelay, isRelay) || other.isRelay == isRelay) &&
            (identical(other.hasTime, hasTime) || other.hasTime == hasTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, speciality,
      specialityLabel, distance, numberOfAthletes, isRelay, hasTime);

  /// Create a copy of Discipline
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisciplineImplCopyWith<_$DisciplineImpl> get copyWith =>
      __$$DisciplineImplCopyWithImpl<_$DisciplineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisciplineImplToJson(
      this,
    );
  }
}

abstract class _Discipline implements Discipline {
  const factory _Discipline(
      {required final String id,
      required final String name,
      required final int speciality,
      required final String specialityLabel,
      final int distance,
      final int numberOfAthletes,
      final bool isRelay,
      final bool hasTime}) = _$DisciplineImpl;

  factory _Discipline.fromJson(Map<String, dynamic> json) =
      _$DisciplineImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get speciality;
  @override
  String get specialityLabel;
  @override
  int get distance;
  @override
  int get numberOfAthletes;
  @override
  bool get isRelay;
  @override
  bool get hasTime;

  /// Create a copy of Discipline
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisciplineImplCopyWith<_$DisciplineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
