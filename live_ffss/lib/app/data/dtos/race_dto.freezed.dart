// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RaceDto _$RaceDtoFromJson(Map<String, dynamic> json) {
  return _RaceDto.fromJson(json);
}

/// @nodoc
mixin _$RaceDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'IdDiscipline')
  int get disciplineId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Genre')
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'isEligibleToNationalRecord')
  bool get isEligibleToNationalRecord => throw _privateConstructorUsedError;
  @JsonKey(name: 'discipline')
  RaceDisciplineDto get discipline => throw _privateConstructorUsedError;
  @JsonKey(name: 'categories')
  List<CategoryDto> get categories => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RaceDtoCopyWith<RaceDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceDtoCopyWith<$Res> {
  factory $RaceDtoCopyWith(RaceDto value, $Res Function(RaceDto) then) =
      _$RaceDtoCopyWithImpl<$Res, RaceDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdDiscipline') int disciplineId,
      @JsonKey(name: 'Genre') String gender,
      @JsonKey(name: 'isEligibleToNationalRecord')
      bool isEligibleToNationalRecord,
      @JsonKey(name: 'discipline') RaceDisciplineDto discipline,
      @JsonKey(name: 'categories') List<CategoryDto> categories});

  $RaceDisciplineDtoCopyWith<$Res> get discipline;
}

/// @nodoc
class _$RaceDtoCopyWithImpl<$Res, $Val extends RaceDto>
    implements $RaceDtoCopyWith<$Res> {
  _$RaceDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? disciplineId = null,
    Object? gender = null,
    Object? isEligibleToNationalRecord = null,
    Object? discipline = null,
    Object? categories = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as RaceDisciplineDto,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryDto>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RaceDisciplineDtoCopyWith<$Res> get discipline {
    return $RaceDisciplineDtoCopyWith<$Res>(_value.discipline, (value) {
      return _then(_value.copyWith(discipline: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RaceDtoImplCopyWith<$Res> implements $RaceDtoCopyWith<$Res> {
  factory _$$RaceDtoImplCopyWith(
          _$RaceDtoImpl value, $Res Function(_$RaceDtoImpl) then) =
      __$$RaceDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdDiscipline') int disciplineId,
      @JsonKey(name: 'Genre') String gender,
      @JsonKey(name: 'isEligibleToNationalRecord')
      bool isEligibleToNationalRecord,
      @JsonKey(name: 'discipline') RaceDisciplineDto discipline,
      @JsonKey(name: 'categories') List<CategoryDto> categories});

  @override
  $RaceDisciplineDtoCopyWith<$Res> get discipline;
}

/// @nodoc
class __$$RaceDtoImplCopyWithImpl<$Res>
    extends _$RaceDtoCopyWithImpl<$Res, _$RaceDtoImpl>
    implements _$$RaceDtoImplCopyWith<$Res> {
  __$$RaceDtoImplCopyWithImpl(
      _$RaceDtoImpl _value, $Res Function(_$RaceDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? disciplineId = null,
    Object? gender = null,
    Object? isEligibleToNationalRecord = null,
    Object? discipline = null,
    Object? categories = null,
  }) {
    return _then(_$RaceDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as RaceDisciplineDto,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<CategoryDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceDtoImpl implements _RaceDto {
  const _$RaceDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'IdDiscipline') required this.disciplineId,
      @JsonKey(name: 'Genre') required this.gender,
      @JsonKey(name: 'isEligibleToNationalRecord')
      this.isEligibleToNationalRecord = false,
      @JsonKey(name: 'discipline') required this.discipline,
      @JsonKey(name: 'categories')
      final List<CategoryDto> categories = const <CategoryDto>[]})
      : _categories = categories;

  factory _$RaceDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'IdDiscipline')
  final int disciplineId;
  @override
  @JsonKey(name: 'Genre')
  final String gender;
  @override
  @JsonKey(name: 'isEligibleToNationalRecord')
  final bool isEligibleToNationalRecord;
  @override
  @JsonKey(name: 'discipline')
  final RaceDisciplineDto discipline;
  final List<CategoryDto> _categories;
  @override
  @JsonKey(name: 'categories')
  List<CategoryDto> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'RaceDto(id: $id, disciplineId: $disciplineId, gender: $gender, isEligibleToNationalRecord: $isEligibleToNationalRecord, discipline: $discipline, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.disciplineId, disciplineId) ||
                other.disciplineId == disciplineId) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isEligibleToNationalRecord,
                    isEligibleToNationalRecord) ||
                other.isEligibleToNationalRecord ==
                    isEligibleToNationalRecord) &&
            (identical(other.discipline, discipline) ||
                other.discipline == discipline) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      disciplineId,
      gender,
      isEligibleToNationalRecord,
      discipline,
      const DeepCollectionEquality().hash(_categories));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceDtoImplCopyWith<_$RaceDtoImpl> get copyWith =>
      __$$RaceDtoImplCopyWithImpl<_$RaceDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceDtoImplToJson(
      this,
    );
  }
}

abstract class _RaceDto implements RaceDto {
  const factory _RaceDto(
      {@JsonKey(name: 'Id') required final int id,
      @JsonKey(name: 'IdDiscipline') required final int disciplineId,
      @JsonKey(name: 'Genre') required final String gender,
      @JsonKey(name: 'isEligibleToNationalRecord')
      final bool isEligibleToNationalRecord,
      @JsonKey(name: 'discipline') required final RaceDisciplineDto discipline,
      @JsonKey(name: 'categories')
      final List<CategoryDto> categories}) = _$RaceDtoImpl;

  factory _RaceDto.fromJson(Map<String, dynamic> json) = _$RaceDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'IdDiscipline')
  int get disciplineId;
  @override
  @JsonKey(name: 'Genre')
  String get gender;
  @override
  @JsonKey(name: 'isEligibleToNationalRecord')
  bool get isEligibleToNationalRecord;
  @override
  @JsonKey(name: 'discipline')
  RaceDisciplineDto get discipline;
  @override
  @JsonKey(name: 'categories')
  List<CategoryDto> get categories;
  @override
  @JsonKey(ignore: true)
  _$$RaceDtoImplCopyWith<_$RaceDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RaceDisciplineDto _$RaceDisciplineDtoFromJson(Map<String, dynamic> json) {
  return _RaceDisciplineDto.fromJson(json);
}

/// @nodoc
mixin _$RaceDisciplineDto {
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomEn')
  String get nameEnglish => throw _privateConstructorUsedError;
  @JsonKey(name: 'Distance')
  int get distance => throw _privateConstructorUsedError;
  @JsonKey(name: 'NbAthleteParEquipe')
  int get athletesPerTeam => throw _privateConstructorUsedError;
  @JsonKey(name: 'Specialite')
  int get specialityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RaceDisciplineDtoCopyWith<RaceDisciplineDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceDisciplineDtoCopyWith<$Res> {
  factory $RaceDisciplineDtoCopyWith(
          RaceDisciplineDto value, $Res Function(RaceDisciplineDto) then) =
      _$RaceDisciplineDtoCopyWithImpl<$Res, RaceDisciplineDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'NomEn') String nameEnglish,
      @JsonKey(name: 'Distance') int distance,
      @JsonKey(name: 'NbAthleteParEquipe') int athletesPerTeam,
      @JsonKey(name: 'Specialite') int specialityId,
      @JsonKey(name: 'specialiteLabel') String specialityLabel});
}

/// @nodoc
class _$RaceDisciplineDtoCopyWithImpl<$Res, $Val extends RaceDisciplineDto>
    implements $RaceDisciplineDtoCopyWith<$Res> {
  _$RaceDisciplineDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameEnglish = null,
    Object? distance = null,
    Object? athletesPerTeam = null,
    Object? specialityId = null,
    Object? specialityLabel = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameEnglish: null == nameEnglish
          ? _value.nameEnglish
          : nameEnglish // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int,
      athletesPerTeam: null == athletesPerTeam
          ? _value.athletesPerTeam
          : athletesPerTeam // ignore: cast_nullable_to_non_nullable
              as int,
      specialityId: null == specialityId
          ? _value.specialityId
          : specialityId // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceDisciplineDtoImplCopyWith<$Res>
    implements $RaceDisciplineDtoCopyWith<$Res> {
  factory _$$RaceDisciplineDtoImplCopyWith(_$RaceDisciplineDtoImpl value,
          $Res Function(_$RaceDisciplineDtoImpl) then) =
      __$$RaceDisciplineDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'NomEn') String nameEnglish,
      @JsonKey(name: 'Distance') int distance,
      @JsonKey(name: 'NbAthleteParEquipe') int athletesPerTeam,
      @JsonKey(name: 'Specialite') int specialityId,
      @JsonKey(name: 'specialiteLabel') String specialityLabel});
}

/// @nodoc
class __$$RaceDisciplineDtoImplCopyWithImpl<$Res>
    extends _$RaceDisciplineDtoCopyWithImpl<$Res, _$RaceDisciplineDtoImpl>
    implements _$$RaceDisciplineDtoImplCopyWith<$Res> {
  __$$RaceDisciplineDtoImplCopyWithImpl(_$RaceDisciplineDtoImpl _value,
      $Res Function(_$RaceDisciplineDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? nameEnglish = null,
    Object? distance = null,
    Object? athletesPerTeam = null,
    Object? specialityId = null,
    Object? specialityLabel = null,
  }) {
    return _then(_$RaceDisciplineDtoImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      nameEnglish: null == nameEnglish
          ? _value.nameEnglish
          : nameEnglish // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int,
      athletesPerTeam: null == athletesPerTeam
          ? _value.athletesPerTeam
          : athletesPerTeam // ignore: cast_nullable_to_non_nullable
              as int,
      specialityId: null == specialityId
          ? _value.specialityId
          : specialityId // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceDisciplineDtoImpl implements _RaceDisciplineDto {
  const _$RaceDisciplineDtoImpl(
      {@JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'NomEn') required this.nameEnglish,
      @JsonKey(name: 'Distance') this.distance = 0,
      @JsonKey(name: 'NbAthleteParEquipe') this.athletesPerTeam = 1,
      @JsonKey(name: 'Specialite') required this.specialityId,
      @JsonKey(name: 'specialiteLabel') required this.specialityLabel});

  factory _$RaceDisciplineDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceDisciplineDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'NomEn')
  final String nameEnglish;
  @override
  @JsonKey(name: 'Distance')
  final int distance;
  @override
  @JsonKey(name: 'NbAthleteParEquipe')
  final int athletesPerTeam;
  @override
  @JsonKey(name: 'Specialite')
  final int specialityId;
  @override
  @JsonKey(name: 'specialiteLabel')
  final String specialityLabel;

  @override
  String toString() {
    return 'RaceDisciplineDto(name: $name, nameEnglish: $nameEnglish, distance: $distance, athletesPerTeam: $athletesPerTeam, specialityId: $specialityId, specialityLabel: $specialityLabel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceDisciplineDtoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameEnglish, nameEnglish) ||
                other.nameEnglish == nameEnglish) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.athletesPerTeam, athletesPerTeam) ||
                other.athletesPerTeam == athletesPerTeam) &&
            (identical(other.specialityId, specialityId) ||
                other.specialityId == specialityId) &&
            (identical(other.specialityLabel, specialityLabel) ||
                other.specialityLabel == specialityLabel));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, nameEnglish, distance,
      athletesPerTeam, specialityId, specialityLabel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceDisciplineDtoImplCopyWith<_$RaceDisciplineDtoImpl> get copyWith =>
      __$$RaceDisciplineDtoImplCopyWithImpl<_$RaceDisciplineDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceDisciplineDtoImplToJson(
      this,
    );
  }
}

abstract class _RaceDisciplineDto implements RaceDisciplineDto {
  const factory _RaceDisciplineDto(
      {@JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'NomEn') required final String nameEnglish,
      @JsonKey(name: 'Distance') final int distance,
      @JsonKey(name: 'NbAthleteParEquipe') final int athletesPerTeam,
      @JsonKey(name: 'Specialite') required final int specialityId,
      @JsonKey(name: 'specialiteLabel')
      required final String specialityLabel}) = _$RaceDisciplineDtoImpl;

  factory _RaceDisciplineDto.fromJson(Map<String, dynamic> json) =
      _$RaceDisciplineDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'NomEn')
  String get nameEnglish;
  @override
  @JsonKey(name: 'Distance')
  int get distance;
  @override
  @JsonKey(name: 'NbAthleteParEquipe')
  int get athletesPerTeam;
  @override
  @JsonKey(name: 'Specialite')
  int get specialityId;
  @override
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel;
  @override
  @JsonKey(ignore: true)
  _$$RaceDisciplineDtoImplCopyWith<_$RaceDisciplineDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
