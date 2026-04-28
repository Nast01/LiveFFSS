// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athlete_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AthleteDto _$AthleteDtoFromJson(Map<String, dynamic> json) {
  return _AthleteDto.fromJson(json);
}

/// @nodoc
mixin _$AthleteDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'NumeroLicence')
  String get licenseeNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'Prenom')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'Sexe')
  String get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'Annee', readValue: _readYear)
  int get year => throw _privateConstructorUsedError;
  @JsonKey(name: 'nationaliteCode')
  String get nationalityCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'nationaliteLabel')
  String get nationality => throw _privateConstructorUsedError;
  @JsonKey(name: 'isValid')
  bool get isValid => throw _privateConstructorUsedError;
  @JsonKey(name: 'isLicencie')
  bool get isLicensee => throw _privateConstructorUsedError;
  @JsonKey(name: 'isInvite')
  bool get isGuest => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AthleteDtoCopyWith<AthleteDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AthleteDtoCopyWith<$Res> {
  factory $AthleteDtoCopyWith(
          AthleteDto value, $Res Function(AthleteDto) then) =
      _$AthleteDtoCopyWithImpl<$Res, AthleteDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NumeroLicence') String licenseeNumber,
      @JsonKey(name: 'Prenom') String firstName,
      @JsonKey(name: 'Nom') String lastName,
      @JsonKey(name: 'Sexe') String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) int year,
      @JsonKey(name: 'nationaliteCode') String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') String nationality,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'isLicencie') bool isLicensee,
      @JsonKey(name: 'isInvite') bool isGuest});
}

/// @nodoc
class _$AthleteDtoCopyWithImpl<$Res, $Val extends AthleteDto>
    implements $AthleteDtoCopyWith<$Res> {
  _$AthleteDtoCopyWithImpl(this._value, this._then);

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
    Object? nationalityCode = null,
    Object? nationality = null,
    Object? isValid = null,
    Object? isLicensee = null,
    Object? isGuest = null,
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
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AthleteDtoImplCopyWith<$Res>
    implements $AthleteDtoCopyWith<$Res> {
  factory _$$AthleteDtoImplCopyWith(
          _$AthleteDtoImpl value, $Res Function(_$AthleteDtoImpl) then) =
      __$$AthleteDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NumeroLicence') String licenseeNumber,
      @JsonKey(name: 'Prenom') String firstName,
      @JsonKey(name: 'Nom') String lastName,
      @JsonKey(name: 'Sexe') String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) int year,
      @JsonKey(name: 'nationaliteCode') String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') String nationality,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'isLicencie') bool isLicensee,
      @JsonKey(name: 'isInvite') bool isGuest});
}

/// @nodoc
class __$$AthleteDtoImplCopyWithImpl<$Res>
    extends _$AthleteDtoCopyWithImpl<$Res, _$AthleteDtoImpl>
    implements _$$AthleteDtoImplCopyWith<$Res> {
  __$$AthleteDtoImplCopyWithImpl(
      _$AthleteDtoImpl _value, $Res Function(_$AthleteDtoImpl) _then)
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
    Object? nationalityCode = null,
    Object? nationality = null,
    Object? isValid = null,
    Object? isLicensee = null,
    Object? isGuest = null,
  }) {
    return _then(_$AthleteDtoImpl(
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
              as String,
      year: null == year
          ? _value.year
          : year // ignore: cast_nullable_to_non_nullable
              as int,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AthleteDtoImpl implements _AthleteDto {
  const _$AthleteDtoImpl(
      {@JsonKey(name: 'Id') this.id = 0,
      @JsonKey(name: 'NumeroLicence') required this.licenseeNumber,
      @JsonKey(name: 'Prenom') required this.firstName,
      @JsonKey(name: 'Nom') required this.lastName,
      @JsonKey(name: 'Sexe') required this.gender,
      @JsonKey(name: 'Annee', readValue: _readYear) required this.year,
      @JsonKey(name: 'nationaliteCode') required this.nationalityCode,
      @JsonKey(name: 'nationaliteLabel') required this.nationality,
      @JsonKey(name: 'isValid') required this.isValid,
      @JsonKey(name: 'isLicencie') this.isLicensee = false,
      @JsonKey(name: 'isInvite') this.isGuest = false});

  factory _$AthleteDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AthleteDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'NumeroLicence')
  final String licenseeNumber;
  @override
  @JsonKey(name: 'Prenom')
  final String firstName;
  @override
  @JsonKey(name: 'Nom')
  final String lastName;
  @override
  @JsonKey(name: 'Sexe')
  final String gender;
  @override
  @JsonKey(name: 'Annee', readValue: _readYear)
  final int year;
  @override
  @JsonKey(name: 'nationaliteCode')
  final String nationalityCode;
  @override
  @JsonKey(name: 'nationaliteLabel')
  final String nationality;
  @override
  @JsonKey(name: 'isValid')
  final bool isValid;
  @override
  @JsonKey(name: 'isLicencie')
  final bool isLicensee;
  @override
  @JsonKey(name: 'isInvite')
  final bool isGuest;

  @override
  String toString() {
    return 'AthleteDto(id: $id, licenseeNumber: $licenseeNumber, firstName: $firstName, lastName: $lastName, gender: $gender, year: $year, nationalityCode: $nationalityCode, nationality: $nationality, isValid: $isValid, isLicensee: $isLicensee, isGuest: $isGuest)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AthleteDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.licenseeNumber, licenseeNumber) ||
                other.licenseeNumber == licenseeNumber) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.nationalityCode, nationalityCode) ||
                other.nationalityCode == nationalityCode) &&
            (identical(other.nationality, nationality) ||
                other.nationality == nationality) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.isLicensee, isLicensee) ||
                other.isLicensee == isLicensee) &&
            (identical(other.isGuest, isGuest) || other.isGuest == isGuest));
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
      nationalityCode,
      nationality,
      isValid,
      isLicensee,
      isGuest);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AthleteDtoImplCopyWith<_$AthleteDtoImpl> get copyWith =>
      __$$AthleteDtoImplCopyWithImpl<_$AthleteDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AthleteDtoImplToJson(
      this,
    );
  }
}

abstract class _AthleteDto implements AthleteDto {
  const factory _AthleteDto(
      {@JsonKey(name: 'Id') final int id,
      @JsonKey(name: 'NumeroLicence') required final String licenseeNumber,
      @JsonKey(name: 'Prenom') required final String firstName,
      @JsonKey(name: 'Nom') required final String lastName,
      @JsonKey(name: 'Sexe') required final String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) required final int year,
      @JsonKey(name: 'nationaliteCode') required final String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') required final String nationality,
      @JsonKey(name: 'isValid') required final bool isValid,
      @JsonKey(name: 'isLicencie') final bool isLicensee,
      @JsonKey(name: 'isInvite') final bool isGuest}) = _$AthleteDtoImpl;

  factory _AthleteDto.fromJson(Map<String, dynamic> json) =
      _$AthleteDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'NumeroLicence')
  String get licenseeNumber;
  @override
  @JsonKey(name: 'Prenom')
  String get firstName;
  @override
  @JsonKey(name: 'Nom')
  String get lastName;
  @override
  @JsonKey(name: 'Sexe')
  String get gender;
  @override
  @JsonKey(name: 'Annee', readValue: _readYear)
  int get year;
  @override
  @JsonKey(name: 'nationaliteCode')
  String get nationalityCode;
  @override
  @JsonKey(name: 'nationaliteLabel')
  String get nationality;
  @override
  @JsonKey(name: 'isValid')
  bool get isValid;
  @override
  @JsonKey(name: 'isLicencie')
  bool get isLicensee;
  @override
  @JsonKey(name: 'isInvite')
  bool get isGuest;
  @override
  @JsonKey(ignore: true)
  _$$AthleteDtoImplCopyWith<_$AthleteDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
