// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_format_configuration_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RaceFormatConfigurationDto _$RaceFormatConfigurationDtoFromJson(
    Map<String, dynamic> json) {
  return _RaceFormatConfigurationDto.fromJson(json);
}

/// @nodoc
mixin _$RaceFormatConfigurationDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'IdEvenement')
  int get competitionId =>
      throw _privateConstructorUsedError; // A déroulement is identified by (discipline, gender); its categories then
// fan it out. That triple is what joins it back to a Race, whose own id
// lives in a different namespace.
  @JsonKey(name: 'IdDiscipline')
  int get disciplineId => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'fullLabel')
  String get fullLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'Genre')
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'genreLabel')
  String get genderLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'Discipline')
  DisciplineDto get discipline => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories', readValue: _readCategories)
  List<CategoryDto> get categories =>
      throw _privateConstructorUsedError; // The rounds FFSS already holds for this déroulement: a semi at 18 places
// feeding a final at 16. Same shape as the local RoundLevel tree.
  @JsonKey(name: 'parties')
  List<RaceFormatDetailDto> get details => throw _privateConstructorUsedError;

  /// Serializes this RaceFormatConfigurationDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceFormatConfigurationDtoCopyWith<RaceFormatConfigurationDto>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceFormatConfigurationDtoCopyWith<$Res> {
  factory $RaceFormatConfigurationDtoCopyWith(RaceFormatConfigurationDto value,
          $Res Function(RaceFormatConfigurationDto) then) =
      _$RaceFormatConfigurationDtoCopyWithImpl<$Res,
          RaceFormatConfigurationDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdEvenement') int competitionId,
      @JsonKey(name: 'IdDiscipline') int disciplineId,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'Genre') String gender,
      @JsonKey(name: 'genreLabel') String genderLabel,
      @JsonKey(name: 'Discipline') DisciplineDto discipline,
      @JsonKey(name: 'categories', readValue: _readCategories)
      List<CategoryDto> categories,
      @JsonKey(name: 'parties') List<RaceFormatDetailDto> details});

  $DisciplineDtoCopyWith<$Res> get discipline;
}

/// @nodoc
class _$RaceFormatConfigurationDtoCopyWithImpl<$Res,
        $Val extends RaceFormatConfigurationDto>
    implements $RaceFormatConfigurationDtoCopyWith<$Res> {
  _$RaceFormatConfigurationDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? competitionId = null,
    Object? disciplineId = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? gender = null,
    Object? genderLabel = null,
    Object? discipline = null,
    Object? categories = null,
    Object? details = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      competitionId: null == competitionId
          ? _value.competitionId
          : competitionId // ignore: cast_nullable_to_non_nullable
              as int,
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      genderLabel: null == genderLabel
          ? _value.genderLabel
          : genderLabel // ignore: cast_nullable_to_non_nullable
              as String,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as DisciplineDto,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryDto>,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as List<RaceFormatDetailDto>,
    ) as $Val);
  }

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisciplineDtoCopyWith<$Res> get discipline {
    return $DisciplineDtoCopyWith<$Res>(_value.discipline, (value) {
      return _then(_value.copyWith(discipline: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RaceFormatConfigurationDtoImplCopyWith<$Res>
    implements $RaceFormatConfigurationDtoCopyWith<$Res> {
  factory _$$RaceFormatConfigurationDtoImplCopyWith(
          _$RaceFormatConfigurationDtoImpl value,
          $Res Function(_$RaceFormatConfigurationDtoImpl) then) =
      __$$RaceFormatConfigurationDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdEvenement') int competitionId,
      @JsonKey(name: 'IdDiscipline') int disciplineId,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'Genre') String gender,
      @JsonKey(name: 'genreLabel') String genderLabel,
      @JsonKey(name: 'Discipline') DisciplineDto discipline,
      @JsonKey(name: 'categories', readValue: _readCategories)
      List<CategoryDto> categories,
      @JsonKey(name: 'parties') List<RaceFormatDetailDto> details});

  @override
  $DisciplineDtoCopyWith<$Res> get discipline;
}

/// @nodoc
class __$$RaceFormatConfigurationDtoImplCopyWithImpl<$Res>
    extends _$RaceFormatConfigurationDtoCopyWithImpl<$Res,
        _$RaceFormatConfigurationDtoImpl>
    implements _$$RaceFormatConfigurationDtoImplCopyWith<$Res> {
  __$$RaceFormatConfigurationDtoImplCopyWithImpl(
      _$RaceFormatConfigurationDtoImpl _value,
      $Res Function(_$RaceFormatConfigurationDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? competitionId = null,
    Object? disciplineId = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? gender = null,
    Object? genderLabel = null,
    Object? discipline = null,
    Object? categories = null,
    Object? details = null,
  }) {
    return _then(_$RaceFormatConfigurationDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      competitionId: null == competitionId
          ? _value.competitionId
          : competitionId // ignore: cast_nullable_to_non_nullable
              as int,
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      genderLabel: null == genderLabel
          ? _value.genderLabel
          : genderLabel // ignore: cast_nullable_to_non_nullable
              as String,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as DisciplineDto,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryDto>,
      details: null == details
          ? _value._details
          : details // ignore: cast_nullable_to_non_nullable
              as List<RaceFormatDetailDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceFormatConfigurationDtoImpl implements _RaceFormatConfigurationDto {
  const _$RaceFormatConfigurationDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'IdEvenement') this.competitionId = 0,
      @JsonKey(name: 'IdDiscipline') this.disciplineId = 0,
      @JsonKey(name: 'label') required this.label,
      @JsonKey(name: 'fullLabel') required this.fullLabel,
      @JsonKey(name: 'Genre') required this.gender,
      @JsonKey(name: 'genreLabel') required this.genderLabel,
      @JsonKey(name: 'Discipline') required this.discipline,
      @JsonKey(name: 'categories', readValue: _readCategories)
      final List<CategoryDto> categories = const <CategoryDto>[],
      @JsonKey(name: 'parties')
      final List<RaceFormatDetailDto> details = const <RaceFormatDetailDto>[]})
      : _categories = categories,
        _details = details;

  factory _$RaceFormatConfigurationDtoImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$RaceFormatConfigurationDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'IdEvenement')
  final int competitionId;
// A déroulement is identified by (discipline, gender); its categories then
// fan it out. That triple is what joins it back to a Race, whose own id
// lives in a different namespace.
  @override
  @JsonKey(name: 'IdDiscipline')
  final int disciplineId;
  @override
  @JsonKey(name: 'label')
  final String label;
  @override
  @JsonKey(name: 'fullLabel')
  final String fullLabel;
  @override
  @JsonKey(name: 'Genre')
  final String gender;
  @override
  @JsonKey(name: 'genreLabel')
  final String genderLabel;
  @override
  @JsonKey(name: 'Discipline')
  final DisciplineDto discipline;
  final List<CategoryDto> _categories;
  @override
  @JsonKey(name: 'categories', readValue: _readCategories)
  List<CategoryDto> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

// The rounds FFSS already holds for this déroulement: a semi at 18 places
// feeding a final at 16. Same shape as the local RoundLevel tree.
  final List<RaceFormatDetailDto> _details;
// The rounds FFSS already holds for this déroulement: a semi at 18 places
// feeding a final at 16. Same shape as the local RoundLevel tree.
  @override
  @JsonKey(name: 'parties')
  List<RaceFormatDetailDto> get details {
    if (_details is EqualUnmodifiableListView) return _details;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_details);
  }

  @override
  String toString() {
    return 'RaceFormatConfigurationDto(id: $id, competitionId: $competitionId, disciplineId: $disciplineId, label: $label, fullLabel: $fullLabel, gender: $gender, genderLabel: $genderLabel, discipline: $discipline, categories: $categories, details: $details)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceFormatConfigurationDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.competitionId, competitionId) ||
                other.competitionId == competitionId) &&
            (identical(other.disciplineId, disciplineId) ||
                other.disciplineId == disciplineId) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullLabel, fullLabel) ||
                other.fullLabel == fullLabel) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.genderLabel, genderLabel) ||
                other.genderLabel == genderLabel) &&
            (identical(other.discipline, discipline) ||
                other.discipline == discipline) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._details, _details));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      competitionId,
      disciplineId,
      label,
      fullLabel,
      gender,
      genderLabel,
      discipline,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_details));

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceFormatConfigurationDtoImplCopyWith<_$RaceFormatConfigurationDtoImpl>
      get copyWith => __$$RaceFormatConfigurationDtoImplCopyWithImpl<
          _$RaceFormatConfigurationDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceFormatConfigurationDtoImplToJson(
      this,
    );
  }
}

abstract class _RaceFormatConfigurationDto
    implements RaceFormatConfigurationDto {
  const factory _RaceFormatConfigurationDto(
          {@JsonKey(name: 'Id') required final int id,
          @JsonKey(name: 'IdEvenement') final int competitionId,
          @JsonKey(name: 'IdDiscipline') final int disciplineId,
          @JsonKey(name: 'label') required final String label,
          @JsonKey(name: 'fullLabel') required final String fullLabel,
          @JsonKey(name: 'Genre') required final String gender,
          @JsonKey(name: 'genreLabel') required final String genderLabel,
          @JsonKey(name: 'Discipline') required final DisciplineDto discipline,
          @JsonKey(name: 'categories', readValue: _readCategories)
          final List<CategoryDto> categories,
          @JsonKey(name: 'parties') final List<RaceFormatDetailDto> details}) =
      _$RaceFormatConfigurationDtoImpl;

  factory _RaceFormatConfigurationDto.fromJson(Map<String, dynamic> json) =
      _$RaceFormatConfigurationDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'IdEvenement')
  int get competitionId; // A déroulement is identified by (discipline, gender); its categories then
// fan it out. That triple is what joins it back to a Race, whose own id
// lives in a different namespace.
  @override
  @JsonKey(name: 'IdDiscipline')
  int get disciplineId;
  @override
  @JsonKey(name: 'label')
  String get label;
  @override
  @JsonKey(name: 'fullLabel')
  String get fullLabel;
  @override
  @JsonKey(name: 'Genre')
  String get gender;
  @override
  @JsonKey(name: 'genreLabel')
  String get genderLabel;
  @override
  @JsonKey(name: 'Discipline')
  DisciplineDto get discipline;
  @override
  @JsonKey(name: 'categories', readValue: _readCategories)
  List<CategoryDto>
      get categories; // The rounds FFSS already holds for this déroulement: a semi at 18 places
// feeding a final at 16. Same shape as the local RoundLevel tree.
  @override
  @JsonKey(name: 'parties')
  List<RaceFormatDetailDto> get details;

  /// Create a copy of RaceFormatConfigurationDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceFormatConfigurationDtoImplCopyWith<_$RaceFormatConfigurationDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
