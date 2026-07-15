// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_format_detail_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RaceFormatDetailDto _$RaceFormatDetailDtoFromJson(Map<String, dynamic> json) {
  return _RaceFormatDetailDto.fromJson(json);
}

/// @nodoc
mixin _$RaceFormatDetailDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'ordre')
  int get order => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'fullLabel')
  String get fullLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'niveauLabel')
  String get levelLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'niveau')
  String get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'nbCourses')
  int get numberOfRun => throw _privateConstructorUsedError;
  @JsonKey(name: 'logiqueQualification')
  String get qualificationMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'logiqueQualificationLabel')
  String get qualificationMethodLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'nbPlaceParCourse')
  int get spotsPerRace => throw _privateConstructorUsedError;
  @JsonKey(name: 'nbPlaceQualificative')
  int get qualifyingSpots => throw _privateConstructorUsedError;

  /// Serializes this RaceFormatDetailDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaceFormatDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceFormatDetailDtoCopyWith<RaceFormatDetailDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceFormatDetailDtoCopyWith<$Res> {
  factory $RaceFormatDetailDtoCopyWith(
          RaceFormatDetailDto value, $Res Function(RaceFormatDetailDto) then) =
      _$RaceFormatDetailDtoCopyWithImpl<$Res, RaceFormatDetailDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'ordre') int order,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'niveauLabel') String levelLabel,
      @JsonKey(name: 'niveau') String level,
      @JsonKey(name: 'nbCourses') int numberOfRun,
      @JsonKey(name: 'logiqueQualification') String qualificationMethod,
      @JsonKey(name: 'logiqueQualificationLabel')
      String qualificationMethodLabel,
      @JsonKey(name: 'nbPlaceParCourse') int spotsPerRace,
      @JsonKey(name: 'nbPlaceQualificative') int qualifyingSpots});
}

/// @nodoc
class _$RaceFormatDetailDtoCopyWithImpl<$Res, $Val extends RaceFormatDetailDto>
    implements $RaceFormatDetailDtoCopyWith<$Res> {
  _$RaceFormatDetailDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaceFormatDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? levelLabel = null,
    Object? level = null,
    Object? numberOfRun = null,
    Object? qualificationMethod = null,
    Object? qualificationMethodLabel = null,
    Object? spotsPerRace = null,
    Object? qualifyingSpots = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      levelLabel: null == levelLabel
          ? _value.levelLabel
          : levelLabel // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfRun: null == numberOfRun
          ? _value.numberOfRun
          : numberOfRun // ignore: cast_nullable_to_non_nullable
              as int,
      qualificationMethod: null == qualificationMethod
          ? _value.qualificationMethod
          : qualificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      qualificationMethodLabel: null == qualificationMethodLabel
          ? _value.qualificationMethodLabel
          : qualificationMethodLabel // ignore: cast_nullable_to_non_nullable
              as String,
      spotsPerRace: null == spotsPerRace
          ? _value.spotsPerRace
          : spotsPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      qualifyingSpots: null == qualifyingSpots
          ? _value.qualifyingSpots
          : qualifyingSpots // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceFormatDetailDtoImplCopyWith<$Res>
    implements $RaceFormatDetailDtoCopyWith<$Res> {
  factory _$$RaceFormatDetailDtoImplCopyWith(_$RaceFormatDetailDtoImpl value,
          $Res Function(_$RaceFormatDetailDtoImpl) then) =
      __$$RaceFormatDetailDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'ordre') int order,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'niveauLabel') String levelLabel,
      @JsonKey(name: 'niveau') String level,
      @JsonKey(name: 'nbCourses') int numberOfRun,
      @JsonKey(name: 'logiqueQualification') String qualificationMethod,
      @JsonKey(name: 'logiqueQualificationLabel')
      String qualificationMethodLabel,
      @JsonKey(name: 'nbPlaceParCourse') int spotsPerRace,
      @JsonKey(name: 'nbPlaceQualificative') int qualifyingSpots});
}

/// @nodoc
class __$$RaceFormatDetailDtoImplCopyWithImpl<$Res>
    extends _$RaceFormatDetailDtoCopyWithImpl<$Res, _$RaceFormatDetailDtoImpl>
    implements _$$RaceFormatDetailDtoImplCopyWith<$Res> {
  __$$RaceFormatDetailDtoImplCopyWithImpl(_$RaceFormatDetailDtoImpl _value,
      $Res Function(_$RaceFormatDetailDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RaceFormatDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? order = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? levelLabel = null,
    Object? level = null,
    Object? numberOfRun = null,
    Object? qualificationMethod = null,
    Object? qualificationMethodLabel = null,
    Object? spotsPerRace = null,
    Object? qualifyingSpots = null,
  }) {
    return _then(_$RaceFormatDetailDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      order: null == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      levelLabel: null == levelLabel
          ? _value.levelLabel
          : levelLabel // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      numberOfRun: null == numberOfRun
          ? _value.numberOfRun
          : numberOfRun // ignore: cast_nullable_to_non_nullable
              as int,
      qualificationMethod: null == qualificationMethod
          ? _value.qualificationMethod
          : qualificationMethod // ignore: cast_nullable_to_non_nullable
              as String,
      qualificationMethodLabel: null == qualificationMethodLabel
          ? _value.qualificationMethodLabel
          : qualificationMethodLabel // ignore: cast_nullable_to_non_nullable
              as String,
      spotsPerRace: null == spotsPerRace
          ? _value.spotsPerRace
          : spotsPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      qualifyingSpots: null == qualifyingSpots
          ? _value.qualifyingSpots
          : qualifyingSpots // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceFormatDetailDtoImpl implements _RaceFormatDetailDto {
  const _$RaceFormatDetailDtoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'ordre') required this.order,
      @JsonKey(name: 'label') required this.label,
      @JsonKey(name: 'fullLabel') required this.fullLabel,
      @JsonKey(name: 'niveauLabel') required this.levelLabel,
      @JsonKey(name: 'niveau') required this.level,
      @JsonKey(name: 'nbCourses') required this.numberOfRun,
      @JsonKey(name: 'logiqueQualification') required this.qualificationMethod,
      @JsonKey(name: 'logiqueQualificationLabel')
      required this.qualificationMethodLabel,
      @JsonKey(name: 'nbPlaceParCourse') required this.spotsPerRace,
      @JsonKey(name: 'nbPlaceQualificative') required this.qualifyingSpots});

  factory _$RaceFormatDetailDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceFormatDetailDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'ordre')
  final int order;
  @override
  @JsonKey(name: 'label')
  final String label;
  @override
  @JsonKey(name: 'fullLabel')
  final String fullLabel;
  @override
  @JsonKey(name: 'niveauLabel')
  final String levelLabel;
  @override
  @JsonKey(name: 'niveau')
  final String level;
  @override
  @JsonKey(name: 'nbCourses')
  final int numberOfRun;
  @override
  @JsonKey(name: 'logiqueQualification')
  final String qualificationMethod;
  @override
  @JsonKey(name: 'logiqueQualificationLabel')
  final String qualificationMethodLabel;
  @override
  @JsonKey(name: 'nbPlaceParCourse')
  final int spotsPerRace;
  @override
  @JsonKey(name: 'nbPlaceQualificative')
  final int qualifyingSpots;

  @override
  String toString() {
    return 'RaceFormatDetailDto(id: $id, order: $order, label: $label, fullLabel: $fullLabel, levelLabel: $levelLabel, level: $level, numberOfRun: $numberOfRun, qualificationMethod: $qualificationMethod, qualificationMethodLabel: $qualificationMethodLabel, spotsPerRace: $spotsPerRace, qualifyingSpots: $qualifyingSpots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceFormatDetailDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullLabel, fullLabel) ||
                other.fullLabel == fullLabel) &&
            (identical(other.levelLabel, levelLabel) ||
                other.levelLabel == levelLabel) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.numberOfRun, numberOfRun) ||
                other.numberOfRun == numberOfRun) &&
            (identical(other.qualificationMethod, qualificationMethod) ||
                other.qualificationMethod == qualificationMethod) &&
            (identical(
                    other.qualificationMethodLabel, qualificationMethodLabel) ||
                other.qualificationMethodLabel == qualificationMethodLabel) &&
            (identical(other.spotsPerRace, spotsPerRace) ||
                other.spotsPerRace == spotsPerRace) &&
            (identical(other.qualifyingSpots, qualifyingSpots) ||
                other.qualifyingSpots == qualifyingSpots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      order,
      label,
      fullLabel,
      levelLabel,
      level,
      numberOfRun,
      qualificationMethod,
      qualificationMethodLabel,
      spotsPerRace,
      qualifyingSpots);

  /// Create a copy of RaceFormatDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceFormatDetailDtoImplCopyWith<_$RaceFormatDetailDtoImpl> get copyWith =>
      __$$RaceFormatDetailDtoImplCopyWithImpl<_$RaceFormatDetailDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceFormatDetailDtoImplToJson(
      this,
    );
  }
}

abstract class _RaceFormatDetailDto implements RaceFormatDetailDto {
  const factory _RaceFormatDetailDto(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'ordre') required final int order,
      @JsonKey(name: 'label') required final String label,
      @JsonKey(name: 'fullLabel') required final String fullLabel,
      @JsonKey(name: 'niveauLabel') required final String levelLabel,
      @JsonKey(name: 'niveau') required final String level,
      @JsonKey(name: 'nbCourses') required final int numberOfRun,
      @JsonKey(name: 'logiqueQualification')
      required final String qualificationMethod,
      @JsonKey(name: 'logiqueQualificationLabel')
      required final String qualificationMethodLabel,
      @JsonKey(name: 'nbPlaceParCourse') required final int spotsPerRace,
      @JsonKey(name: 'nbPlaceQualificative')
      required final int qualifyingSpots}) = _$RaceFormatDetailDtoImpl;

  factory _RaceFormatDetailDto.fromJson(Map<String, dynamic> json) =
      _$RaceFormatDetailDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'ordre')
  int get order;
  @override
  @JsonKey(name: 'label')
  String get label;
  @override
  @JsonKey(name: 'fullLabel')
  String get fullLabel;
  @override
  @JsonKey(name: 'niveauLabel')
  String get levelLabel;
  @override
  @JsonKey(name: 'niveau')
  String get level;
  @override
  @JsonKey(name: 'nbCourses')
  int get numberOfRun;
  @override
  @JsonKey(name: 'logiqueQualification')
  String get qualificationMethod;
  @override
  @JsonKey(name: 'logiqueQualificationLabel')
  String get qualificationMethodLabel;
  @override
  @JsonKey(name: 'nbPlaceParCourse')
  int get spotsPerRace;
  @override
  @JsonKey(name: 'nbPlaceQualificative')
  int get qualifyingSpots;

  /// Create a copy of RaceFormatDetailDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceFormatDetailDtoImplCopyWith<_$RaceFormatDetailDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
