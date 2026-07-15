// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Race _$RaceFromJson(Map<String, dynamic> json) {
  return _Race.fromJson(json);
}

/// @nodoc
mixin _$Race {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get nameEnglish => throw _privateConstructorUsedError;
  int get distance => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  int get athletesPerTeam => throw _privateConstructorUsedError;
  int get specialityId => throw _privateConstructorUsedError;
  String get specialityLabel => throw _privateConstructorUsedError;
  int get disciplineId => throw _privateConstructorUsedError;
  bool get isEligibleToNationalRecord => throw _privateConstructorUsedError;
  List<Category> get categories => throw _privateConstructorUsedError;

  /// Serializes this Race to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Race
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceCopyWith<Race> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceCopyWith<$Res> {
  factory $RaceCopyWith(Race value, $Res Function(Race) then) =
      _$RaceCopyWithImpl<$Res, Race>;
  @useResult
  $Res call(
      {int id,
      String name,
      String nameEnglish,
      int distance,
      Gender gender,
      int athletesPerTeam,
      int specialityId,
      String specialityLabel,
      int disciplineId,
      bool isEligibleToNationalRecord,
      List<Category> categories});
}

/// @nodoc
class _$RaceCopyWithImpl<$Res, $Val extends Race>
    implements $RaceCopyWith<$Res> {
  _$RaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Race
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameEnglish = null,
    Object? distance = null,
    Object? gender = null,
    Object? athletesPerTeam = null,
    Object? specialityId = null,
    Object? specialityLabel = null,
    Object? disciplineId = null,
    Object? isEligibleToNationalRecord = null,
    Object? categories = null,
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
      nameEnglish: null == nameEnglish
          ? _value.nameEnglish
          : nameEnglish // ignore: cast_nullable_to_non_nullable
              as String,
      distance: null == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as int,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
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
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RaceImplCopyWith<$Res> implements $RaceCopyWith<$Res> {
  factory _$$RaceImplCopyWith(
          _$RaceImpl value, $Res Function(_$RaceImpl) then) =
      __$$RaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String nameEnglish,
      int distance,
      Gender gender,
      int athletesPerTeam,
      int specialityId,
      String specialityLabel,
      int disciplineId,
      bool isEligibleToNationalRecord,
      List<Category> categories});
}

/// @nodoc
class __$$RaceImplCopyWithImpl<$Res>
    extends _$RaceCopyWithImpl<$Res, _$RaceImpl>
    implements _$$RaceImplCopyWith<$Res> {
  __$$RaceImplCopyWithImpl(_$RaceImpl _value, $Res Function(_$RaceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Race
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? nameEnglish = null,
    Object? distance = null,
    Object? gender = null,
    Object? athletesPerTeam = null,
    Object? specialityId = null,
    Object? specialityLabel = null,
    Object? disciplineId = null,
    Object? isEligibleToNationalRecord = null,
    Object? categories = null,
  }) {
    return _then(_$RaceImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
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
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
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
      disciplineId: null == disciplineId
          ? _value.disciplineId
          : disciplineId // ignore: cast_nullable_to_non_nullable
              as int,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceImpl implements _Race {
  const _$RaceImpl(
      {required this.id,
      required this.name,
      required this.nameEnglish,
      required this.distance,
      required this.gender,
      required this.athletesPerTeam,
      required this.specialityId,
      required this.specialityLabel,
      required this.disciplineId,
      required this.isEligibleToNationalRecord,
      required final List<Category> categories})
      : _categories = categories;

  factory _$RaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String nameEnglish;
  @override
  final int distance;
  @override
  final Gender gender;
  @override
  final int athletesPerTeam;
  @override
  final int specialityId;
  @override
  final String specialityLabel;
  @override
  final int disciplineId;
  @override
  final bool isEligibleToNationalRecord;
  final List<Category> _categories;
  @override
  List<Category> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'Race(id: $id, name: $name, nameEnglish: $nameEnglish, distance: $distance, gender: $gender, athletesPerTeam: $athletesPerTeam, specialityId: $specialityId, specialityLabel: $specialityLabel, disciplineId: $disciplineId, isEligibleToNationalRecord: $isEligibleToNationalRecord, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameEnglish, nameEnglish) ||
                other.nameEnglish == nameEnglish) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.athletesPerTeam, athletesPerTeam) ||
                other.athletesPerTeam == athletesPerTeam) &&
            (identical(other.specialityId, specialityId) ||
                other.specialityId == specialityId) &&
            (identical(other.specialityLabel, specialityLabel) ||
                other.specialityLabel == specialityLabel) &&
            (identical(other.disciplineId, disciplineId) ||
                other.disciplineId == disciplineId) &&
            (identical(other.isEligibleToNationalRecord,
                    isEligibleToNationalRecord) ||
                other.isEligibleToNationalRecord ==
                    isEligibleToNationalRecord) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      nameEnglish,
      distance,
      gender,
      athletesPerTeam,
      specialityId,
      specialityLabel,
      disciplineId,
      isEligibleToNationalRecord,
      const DeepCollectionEquality().hash(_categories));

  /// Create a copy of Race
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceImplCopyWith<_$RaceImpl> get copyWith =>
      __$$RaceImplCopyWithImpl<_$RaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceImplToJson(
      this,
    );
  }
}

abstract class _Race implements Race {
  const factory _Race(
      {required final int id,
      required final String name,
      required final String nameEnglish,
      required final int distance,
      required final Gender gender,
      required final int athletesPerTeam,
      required final int specialityId,
      required final String specialityLabel,
      required final int disciplineId,
      required final bool isEligibleToNationalRecord,
      required final List<Category> categories}) = _$RaceImpl;

  factory _Race.fromJson(Map<String, dynamic> json) = _$RaceImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get nameEnglish;
  @override
  int get distance;
  @override
  Gender get gender;
  @override
  int get athletesPerTeam;
  @override
  int get specialityId;
  @override
  String get specialityLabel;
  @override
  int get disciplineId;
  @override
  bool get isEligibleToNationalRecord;
  @override
  List<Category> get categories;

  /// Create a copy of Race
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceImplCopyWith<_$RaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
