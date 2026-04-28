// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referee.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Referee _$RefereeFromJson(Map<String, dynamic> json) {
  return _Referee.fromJson(json);
}

/// @nodoc
mixin _$Referee {
  int get id => throw _privateConstructorUsedError;
  String get licenseeNumber => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  String get levelMax => throw _privateConstructorUsedError;
  String get nationalityCode => throw _privateConstructorUsedError;
  String get nationality => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  bool get isLicensee => throw _privateConstructorUsedError;
  bool get isGuest => throw _privateConstructorUsedError;
  bool get isPrincipal => throw _privateConstructorUsedError;
  List<int> get availabilities => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RefereeCopyWith<Referee> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefereeCopyWith<$Res> {
  factory $RefereeCopyWith(Referee value, $Res Function(Referee) then) =
      _$RefereeCopyWithImpl<$Res, Referee>;
  @useResult
  $Res call(
      {int id,
      String licenseeNumber,
      String firstName,
      String lastName,
      Gender gender,
      int year,
      String level,
      String levelMax,
      String nationalityCode,
      String nationality,
      bool isValid,
      bool isLicensee,
      bool isGuest,
      bool isPrincipal,
      List<int> availabilities});
}

/// @nodoc
class _$RefereeCopyWithImpl<$Res, $Val extends Referee>
    implements $RefereeCopyWith<$Res> {
  _$RefereeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? licenseeNumber = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = null,
    Object? year = null,
    Object? level = null,
    Object? levelMax = null,
    Object? nationalityCode = null,
    Object? nationality = null,
    Object? isValid = null,
    Object? isLicensee = null,
    Object? isGuest = null,
    Object? isPrincipal = null,
    Object? availabilities = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      licenseeNumber: null == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      levelMax: null == levelMax
          ? _value.levelMax
          : levelMax // ignore: cast_nullable_to_non_nullable
              as String,
      nationalityCode: null == nationalityCode
          ? _value.nationalityCode
          : nationalityCode // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      isLicensee: null == isLicensee
          ? _value.isLicensee
          : isLicensee // ignore: cast_nullable_to_non_nullable
              as bool,
      isGuest: null == isGuest
          ? _value.isGuest
          : isGuest // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrincipal: null == isPrincipal
          ? _value.isPrincipal
          : isPrincipal // ignore: cast_nullable_to_non_nullable
              as bool,
      availabilities: null == availabilities
          ? _value.availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefereeImplCopyWith<$Res> implements $RefereeCopyWith<$Res> {
  factory _$$RefereeImplCopyWith(
          _$RefereeImpl value, $Res Function(_$RefereeImpl) then) =
      __$$RefereeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String licenseeNumber,
      String firstName,
      String lastName,
      Gender gender,
      int year,
      String level,
      String levelMax,
      String nationalityCode,
      String nationality,
      bool isValid,
      bool isLicensee,
      bool isGuest,
      bool isPrincipal,
      List<int> availabilities});
}

/// @nodoc
class __$$RefereeImplCopyWithImpl<$Res>
    extends _$RefereeCopyWithImpl<$Res, _$RefereeImpl>
    implements _$$RefereeImplCopyWith<$Res> {
  __$$RefereeImplCopyWithImpl(
      _$RefereeImpl _value, $Res Function(_$RefereeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? licenseeNumber = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? gender = null,
    Object? year = null,
    Object? level = null,
    Object? levelMax = null,
    Object? nationalityCode = null,
    Object? nationality = null,
    Object? isValid = null,
    Object? isLicensee = null,
    Object? isGuest = null,
    Object? isPrincipal = null,
    Object? availabilities = null,
  }) {
    return _then(_$RefereeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      licenseeNumber: null == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      levelMax: null == levelMax
          ? _value.levelMax
          : levelMax // ignore: cast_nullable_to_non_nullable
              as String,
      nationalityCode: null == nationalityCode
          ? _value.nationalityCode
          : nationalityCode // ignore: cast_nullable_to_non_nullable
              as String,
      nationality: null == nationality
          ? _value.nationality
          : nationality // ignore: cast_nullable_to_non_nullable
              as String,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      isLicensee: null == isLicensee
          ? _value.isLicensee
          : isLicensee // ignore: cast_nullable_to_non_nullable
              as bool,
      isGuest: null == isGuest
          ? _value.isGuest
          : isGuest // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrincipal: null == isPrincipal
          ? _value.isPrincipal
          : isPrincipal // ignore: cast_nullable_to_non_nullable
              as bool,
      availabilities: null == availabilities
          ? _value._availabilities
          : availabilities // ignore: cast_nullable_to_non_nullable
              as List<int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefereeImpl implements _Referee {
  const _$RefereeImpl(
      {required this.id,
      required this.licenseeNumber,
      required this.firstName,
      required this.lastName,
      required this.gender,
      required this.year,
      required this.level,
      required this.levelMax,
      required this.nationalityCode,
      required this.nationality,
      required this.isValid,
      this.isLicensee = false,
      this.isGuest = false,
      this.isPrincipal = false,
      final List<int> availabilities = const <int>[]})
      : _availabilities = availabilities;

  factory _$RefereeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefereeImplFromJson(json);

  @override
  final int id;
  @override
  final String licenseeNumber;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final Gender gender;
  @override
  final int year;
  @override
  final String level;
  @override
  final String levelMax;
  @override
  final String nationalityCode;
  @override
  final String nationality;
  @override
  final bool isValid;
  @override
  @JsonKey()
  final bool isLicensee;
  @override
  @JsonKey()
  final bool isGuest;
  @override
  @JsonKey()
  final bool isPrincipal;
  final List<int> _availabilities;
  @override
  @JsonKey()
  List<int> get availabilities {
    if (_availabilities is EqualUnmodifiableListView) return _availabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availabilities);
  }

  @override
  String toString() {
    return 'Referee(id: $id, licenseeNumber: $licenseeNumber, firstName: $firstName, lastName: $lastName, gender: $gender, year: $year, level: $level, levelMax: $levelMax, nationalityCode: $nationalityCode, nationality: $nationality, isValid: $isValid, isLicensee: $isLicensee, isGuest: $isGuest, isPrincipal: $isPrincipal, availabilities: $availabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefereeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.licenseeNumber, licenseeNumber) ||
                other.licenseeNumber == licenseeNumber) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.levelMax, levelMax) ||
                other.levelMax == levelMax) &&
            (identical(other.nationalityCode, nationalityCode) ||
                other.nationalityCode == nationalityCode) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.isLicensee, isLicensee) ||
                other.isLicensee == isLicensee) &&
            (identical(other.isGuest, isGuest) || other.isGuest == isGuest) &&
            (identical(other.isPrincipal, isPrincipal) ||
                other.isPrincipal == isPrincipal) &&
            const DeepCollectionEquality()
                .equals(other._availabilities, _availabilities));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      licenseeNumber,
      firstName,
      lastName,
      gender,
      year,
      level,
      levelMax,
      nationalityCode,
      nationality,
      isValid,
      isLicensee,
      isGuest,
      isPrincipal,
      const DeepCollectionEquality().hash(_availabilities));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RefereeImplCopyWith<_$RefereeImpl> get copyWith =>
      __$$RefereeImplCopyWithImpl<_$RefereeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefereeImplToJson(
      this,
    );
  }
}

abstract class _Referee implements Referee {
  const factory _Referee(
      {required final int id,
      required final String licenseeNumber,
      required final String firstName,
      required final String lastName,
      required final Gender gender,
      required final int year,
      required final String level,
      required final String levelMax,
      required final String nationalityCode,
      required final String nationality,
      required final bool isValid,
      final bool isLicensee,
      final bool isGuest,
      final bool isPrincipal,
      final List<int> availabilities}) = _$RefereeImpl;

  factory _Referee.fromJson(Map<String, dynamic> json) = _$RefereeImpl.fromJson;

  @override
  int get id;
  @override
  String get licenseeNumber;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  Gender get gender;
  @override
  int get year;
  @override
  String get level;
  @override
  String get levelMax;
  @override
  String get nationalityCode;
  @override
  String get nationality;
  @override
  bool get isValid;
  @override
  bool get isLicensee;
  @override
  bool get isGuest;
  @override
  bool get isPrincipal;
  @override
  List<int> get availabilities;
  @override
  @JsonKey(ignore: true)
  _$$RefereeImplCopyWith<_$RefereeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
