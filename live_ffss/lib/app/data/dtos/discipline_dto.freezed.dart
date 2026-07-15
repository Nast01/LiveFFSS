// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discipline_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DisciplineDto _$DisciplineDtoFromJson(Map<String, dynamic> json) {
  return _DisciplineDto.fromJson(json);
}

/// @nodoc
mixin _$DisciplineDto {
  @JsonKey(name: 'Id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'specialite')
  int get speciality => throw _privateConstructorUsedError;
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'distance')
  int get distance => throw _privateConstructorUsedError;
  @JsonKey(name: 'nbAthleteParEquipe')
  int get numberOfAthletes => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRelais')
  bool get isRelay => throw _privateConstructorUsedError;
  @JsonKey(name: 'hasTemps')
  bool get hasTime => throw _privateConstructorUsedError;

  /// Serializes this DisciplineDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DisciplineDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DisciplineDtoCopyWith<DisciplineDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DisciplineDtoCopyWith<$Res> {
  factory $DisciplineDtoCopyWith(
          DisciplineDto value, $Res Function(DisciplineDto) then) =
      _$DisciplineDtoCopyWithImpl<$Res, DisciplineDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'specialite') int speciality,
      @JsonKey(name: 'specialiteLabel') String specialityLabel,
      @JsonKey(name: 'distance') int distance,
      @JsonKey(name: 'nbAthleteParEquipe') int numberOfAthletes,
      @JsonKey(name: 'isRelais') bool isRelay,
      @JsonKey(name: 'hasTemps') bool hasTime});
}

/// @nodoc
class _$DisciplineDtoCopyWithImpl<$Res, $Val extends DisciplineDto>
    implements $DisciplineDtoCopyWith<$Res> {
  _$DisciplineDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DisciplineDto
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
abstract class _$$DisciplineDtoImplCopyWith<$Res>
    implements $DisciplineDtoCopyWith<$Res> {
  factory _$$DisciplineDtoImplCopyWith(
          _$DisciplineDtoImpl value, $Res Function(_$DisciplineDtoImpl) then) =
      __$$DisciplineDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') String id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'specialite') int speciality,
      @JsonKey(name: 'specialiteLabel') String specialityLabel,
      @JsonKey(name: 'distance') int distance,
      @JsonKey(name: 'nbAthleteParEquipe') int numberOfAthletes,
      @JsonKey(name: 'isRelais') bool isRelay,
      @JsonKey(name: 'hasTemps') bool hasTime});
}

/// @nodoc
class __$$DisciplineDtoImplCopyWithImpl<$Res>
    extends _$DisciplineDtoCopyWithImpl<$Res, _$DisciplineDtoImpl>
    implements _$$DisciplineDtoImplCopyWith<$Res> {
  __$$DisciplineDtoImplCopyWithImpl(
      _$DisciplineDtoImpl _value, $Res Function(_$DisciplineDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of DisciplineDto
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
    return _then(_$DisciplineDtoImpl(
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
class _$DisciplineDtoImpl implements _DisciplineDto {
  const _$DisciplineDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'specialite') required this.speciality,
      @JsonKey(name: 'specialiteLabel') this.specialityLabel = '',
      @JsonKey(name: 'distance') this.distance = 0,
      @JsonKey(name: 'nbAthleteParEquipe') this.numberOfAthletes = 0,
      @JsonKey(name: 'isRelais') this.isRelay = false,
      @JsonKey(name: 'hasTemps') this.hasTime = false});

  factory _$DisciplineDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DisciplineDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final String id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'specialite')
  final int speciality;
  @override
  @JsonKey(name: 'specialiteLabel')
  final String specialityLabel;
  @override
  @JsonKey(name: 'distance')
  final int distance;
  @override
  @JsonKey(name: 'nbAthleteParEquipe')
  final int numberOfAthletes;
  @override
  @JsonKey(name: 'isRelais')
  final bool isRelay;
  @override
  @JsonKey(name: 'hasTemps')
  final bool hasTime;

  @override
  String toString() {
    return 'DisciplineDto(id: $id, name: $name, speciality: $speciality, specialityLabel: $specialityLabel, distance: $distance, numberOfAthletes: $numberOfAthletes, isRelay: $isRelay, hasTime: $hasTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DisciplineDtoImpl &&
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

  /// Create a copy of DisciplineDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DisciplineDtoImplCopyWith<_$DisciplineDtoImpl> get copyWith =>
      __$$DisciplineDtoImplCopyWithImpl<_$DisciplineDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DisciplineDtoImplToJson(
      this,
    );
  }
}

abstract class _DisciplineDto implements DisciplineDto {
  const factory _DisciplineDto(
      {@JsonKey(name: 'Id') required final String id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'specialite') required final int speciality,
      @JsonKey(name: 'specialiteLabel') final String specialityLabel,
      @JsonKey(name: 'distance') final int distance,
      @JsonKey(name: 'nbAthleteParEquipe') final int numberOfAthletes,
      @JsonKey(name: 'isRelais') final bool isRelay,
      @JsonKey(name: 'hasTemps') final bool hasTime}) = _$DisciplineDtoImpl;

  factory _DisciplineDto.fromJson(Map<String, dynamic> json) =
      _$DisciplineDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  String get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'specialite')
  int get speciality;
  @override
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel;
  @override
  @JsonKey(name: 'distance')
  int get distance;
  @override
  @JsonKey(name: 'nbAthleteParEquipe')
  int get numberOfAthletes;
  @override
  @JsonKey(name: 'isRelais')
  bool get isRelay;
  @override
  @JsonKey(name: 'hasTemps')
  bool get hasTime;

  /// Create a copy of DisciplineDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DisciplineDtoImplCopyWith<_$DisciplineDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
