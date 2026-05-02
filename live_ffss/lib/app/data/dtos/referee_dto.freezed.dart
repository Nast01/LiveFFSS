// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referee_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RefereeDto _$RefereeDtoFromJson(Map<String, dynamic> json) {
  return _RefereeDto.fromJson(json);
}

/// @nodoc
mixin _$RefereeDto {
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
  @JsonKey(name: 'Niveau')
  String get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'NiveauMax')
  String get levelMax => throw _privateConstructorUsedError;
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
  @JsonKey(name: 'Principal')
  bool get isPrincipal => throw _privateConstructorUsedError;
  @JsonKey(name: 'Jours', readValue: _readAvailabilities)
  List<int> get availabilities => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RefereeDtoCopyWith<RefereeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefereeDtoCopyWith<$Res> {
  factory $RefereeDtoCopyWith(
          RefereeDto value, $Res Function(RefereeDto) then) =
      _$RefereeDtoCopyWithImpl<$Res, RefereeDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NumeroLicence') String licenseeNumber,
      @JsonKey(name: 'Prenom') String firstName,
      @JsonKey(name: 'Nom') String lastName,
      @JsonKey(name: 'Sexe') String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) int year,
      @JsonKey(name: 'Niveau') String level,
      @JsonKey(name: 'NiveauMax') String levelMax,
      @JsonKey(name: 'nationaliteCode') String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') String nationality,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'isLicencie') bool isLicensee,
      @JsonKey(name: 'isInvite') bool isGuest,
      @JsonKey(name: 'Principal') bool isPrincipal,
      @JsonKey(name: 'Jours', readValue: _readAvailabilities)
      List<int> availabilities});
}

/// @nodoc
class _$RefereeDtoCopyWithImpl<$Res, $Val extends RefereeDto>
    implements $RefereeDtoCopyWith<$Res> {
  _$RefereeDtoCopyWithImpl(this._value, this._then);

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
              as String,
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
abstract class _$$RefereeDtoImplCopyWith<$Res>
    implements $RefereeDtoCopyWith<$Res> {
  factory _$$RefereeDtoImplCopyWith(
          _$RefereeDtoImpl value, $Res Function(_$RefereeDtoImpl) then) =
      __$$RefereeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NumeroLicence') String licenseeNumber,
      @JsonKey(name: 'Prenom') String firstName,
      @JsonKey(name: 'Nom') String lastName,
      @JsonKey(name: 'Sexe') String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) int year,
      @JsonKey(name: 'Niveau') String level,
      @JsonKey(name: 'NiveauMax') String levelMax,
      @JsonKey(name: 'nationaliteCode') String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') String nationality,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'isLicencie') bool isLicensee,
      @JsonKey(name: 'isInvite') bool isGuest,
      @JsonKey(name: 'Principal') bool isPrincipal,
      @JsonKey(name: 'Jours', readValue: _readAvailabilities)
      List<int> availabilities});
}

/// @nodoc
class __$$RefereeDtoImplCopyWithImpl<$Res>
    extends _$RefereeDtoCopyWithImpl<$Res, _$RefereeDtoImpl>
    implements _$$RefereeDtoImplCopyWith<$Res> {
  __$$RefereeDtoImplCopyWithImpl(
      _$RefereeDtoImpl _value, $Res Function(_$RefereeDtoImpl) _then)
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
    return _then(_$RefereeDtoImpl(
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
class _$RefereeDtoImpl implements _RefereeDto {
  const _$RefereeDtoImpl(
      {@JsonKey(name: 'Id') this.id = 0,
      @JsonKey(name: 'NumeroLicence') this.licenseeNumber = '',
      @JsonKey(name: 'Prenom') this.firstName = '',
      @JsonKey(name: 'Nom') this.lastName = '',
      @JsonKey(name: 'Sexe') this.gender = '',
      @JsonKey(name: 'Annee', readValue: _readYear) this.year = 0,
      @JsonKey(name: 'Niveau') this.level = '',
      @JsonKey(name: 'NiveauMax') this.levelMax = '',
      @JsonKey(name: 'nationaliteCode') this.nationalityCode = '',
      @JsonKey(name: 'nationaliteLabel') this.nationality = '',
      @JsonKey(name: 'isValid') this.isValid = false,
      @JsonKey(name: 'isLicencie') this.isLicensee = false,
      @JsonKey(name: 'isInvite') this.isGuest = false,
      @JsonKey(name: 'Principal') this.isPrincipal = false,
      @JsonKey(name: 'Jours', readValue: _readAvailabilities)
      final List<int> availabilities = const <int>[]})
      : _availabilities = availabilities;

  factory _$RefereeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefereeDtoImplFromJson(json);

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
  @JsonKey(name: 'Niveau')
  final String level;
  @override
  @JsonKey(name: 'NiveauMax')
  final String levelMax;
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
  @JsonKey(name: 'Principal')
  final bool isPrincipal;
  final List<int> _availabilities;
  @override
  @JsonKey(name: 'Jours', readValue: _readAvailabilities)
  List<int> get availabilities {
    if (_availabilities is EqualUnmodifiableListView) return _availabilities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availabilities);
  }

  @override
  String toString() {
    return 'RefereeDto(id: $id, licenseeNumber: $licenseeNumber, firstName: $firstName, lastName: $lastName, gender: $gender, year: $year, level: $level, levelMax: $levelMax, nationalityCode: $nationalityCode, nationality: $nationality, isValid: $isValid, isLicensee: $isLicensee, isGuest: $isGuest, isPrincipal: $isPrincipal, availabilities: $availabilities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefereeDtoImpl &&
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
  _$$RefereeDtoImplCopyWith<_$RefereeDtoImpl> get copyWith =>
      __$$RefereeDtoImplCopyWithImpl<_$RefereeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefereeDtoImplToJson(
      this,
    );
  }
}

abstract class _RefereeDto implements RefereeDto {
  const factory _RefereeDto(
      {@JsonKey(name: 'Id') final int id,
      @JsonKey(name: 'NumeroLicence') final String licenseeNumber,
      @JsonKey(name: 'Prenom') final String firstName,
      @JsonKey(name: 'Nom') final String lastName,
      @JsonKey(name: 'Sexe') final String gender,
      @JsonKey(name: 'Annee', readValue: _readYear) final int year,
      @JsonKey(name: 'Niveau') final String level,
      @JsonKey(name: 'NiveauMax') final String levelMax,
      @JsonKey(name: 'nationaliteCode') final String nationalityCode,
      @JsonKey(name: 'nationaliteLabel') final String nationality,
      @JsonKey(name: 'isValid') final bool isValid,
      @JsonKey(name: 'isLicencie') final bool isLicensee,
      @JsonKey(name: 'isInvite') final bool isGuest,
      @JsonKey(name: 'Principal') final bool isPrincipal,
      @JsonKey(name: 'Jours', readValue: _readAvailabilities)
      final List<int> availabilities}) = _$RefereeDtoImpl;

  factory _RefereeDto.fromJson(Map<String, dynamic> json) =
      _$RefereeDtoImpl.fromJson;

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
  @JsonKey(name: 'Niveau')
  String get level;
  @override
  @JsonKey(name: 'NiveauMax')
  String get levelMax;
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
  @JsonKey(name: 'Principal')
  bool get isPrincipal;
  @override
  @JsonKey(name: 'Jours', readValue: _readAvailabilities)
  List<int> get availabilities;
  @override
  @JsonKey(ignore: true)
  _$$RefereeDtoImplCopyWith<_$RefereeDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
