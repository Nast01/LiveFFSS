// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserDto _$UserDtoFromJson(Map<String, dynamic> json) {
  return _UserDto.fromJson(json);
}

/// @nodoc
mixin _$UserDto {
  String get label => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  UserDtoData get data => throw _privateConstructorUsedError;

  /// Serializes this UserDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoCopyWith<UserDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoCopyWith<$Res> {
  factory $UserDtoCopyWith(UserDto value, $Res Function(UserDto) then) =
      _$UserDtoCopyWithImpl<$Res, UserDto>;
  @useResult
  $Res call({String label, String type, UserDtoData data});

  $UserDtoDataCopyWith<$Res> get data;
}

/// @nodoc
class _$UserDtoCopyWithImpl<$Res, $Val extends UserDto>
    implements $UserDtoCopyWith<$Res> {
  _$UserDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? type = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDtoData,
    ) as $Val);
  }

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoDataCopyWith<$Res> get data {
    return $UserDtoDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserDtoImplCopyWith<$Res> implements $UserDtoCopyWith<$Res> {
  factory _$$UserDtoImplCopyWith(
          _$UserDtoImpl value, $Res Function(_$UserDtoImpl) then) =
      __$$UserDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String type, UserDtoData data});

  @override
  $UserDtoDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$UserDtoImplCopyWithImpl<$Res>
    extends _$UserDtoCopyWithImpl<$Res, _$UserDtoImpl>
    implements _$$UserDtoImplCopyWith<$Res> {
  __$$UserDtoImplCopyWithImpl(
      _$UserDtoImpl _value, $Res Function(_$UserDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? type = null,
    Object? data = null,
  }) {
    return _then(_$UserDtoImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as UserDtoData,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDtoImpl implements _UserDto {
  const _$UserDtoImpl(
      {required this.label, required this.type, required this.data});

  factory _$UserDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoImplFromJson(json);

  @override
  final String label;
  @override
  final String type;
  @override
  final UserDtoData data;

  @override
  String toString() {
    return 'UserDto(label: $label, type: $type, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, type, data);

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      __$$UserDtoImplCopyWithImpl<_$UserDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoImplToJson(
      this,
    );
  }
}

abstract class _UserDto implements UserDto {
  const factory _UserDto(
      {required final String label,
      required final String type,
      required final UserDtoData data}) = _$UserDtoImpl;

  factory _UserDto.fromJson(Map<String, dynamic> json) = _$UserDtoImpl.fromJson;

  @override
  String get label;
  @override
  String get type;
  @override
  UserDtoData get data;

  /// Create a copy of UserDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoImplCopyWith<_$UserDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDtoData _$UserDtoDataFromJson(Map<String, dynamic> json) {
  return _UserDtoData.fromJson(json);
}

/// @nodoc
mixin _$UserDtoData {
  String get role => throw _privateConstructorUsedError;
  @JsonKey(name: 'nom')
  String? get lastName => throw _privateConstructorUsedError;
  @JsonKey(name: 'prenom')
  String? get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'numero')
  String? get licenseeNumber => throw _privateConstructorUsedError;
  UserDtoClub? get club => throw _privateConstructorUsedError;

  /// Serializes this UserDtoData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoDataCopyWith<UserDtoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoDataCopyWith<$Res> {
  factory $UserDtoDataCopyWith(
          UserDtoData value, $Res Function(UserDtoData) then) =
      _$UserDtoDataCopyWithImpl<$Res, UserDtoData>;
  @useResult
  $Res call(
      {String role,
      @JsonKey(name: 'nom') String? lastName,
      @JsonKey(name: 'prenom') String? firstName,
      @JsonKey(name: 'numero') String? licenseeNumber,
      UserDtoClub? club});

  $UserDtoClubCopyWith<$Res>? get club;
}

/// @nodoc
class _$UserDtoDataCopyWithImpl<$Res, $Val extends UserDtoData>
    implements $UserDtoDataCopyWith<$Res> {
  _$UserDtoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? lastName = freezed,
    Object? firstName = freezed,
    Object? licenseeNumber = freezed,
    Object? club = freezed,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseeNumber: freezed == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      club: freezed == club
          ? _value.club
          : club // ignore: cast_nullable_to_non_nullable
              as UserDtoClub?,
    ) as $Val);
  }

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDtoClubCopyWith<$Res>? get club {
    if (_value.club == null) {
      return null;
    }

    return $UserDtoClubCopyWith<$Res>(_value.club!, (value) {
      return _then(_value.copyWith(club: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserDtoDataImplCopyWith<$Res>
    implements $UserDtoDataCopyWith<$Res> {
  factory _$$UserDtoDataImplCopyWith(
          _$UserDtoDataImpl value, $Res Function(_$UserDtoDataImpl) then) =
      __$$UserDtoDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String role,
      @JsonKey(name: 'nom') String? lastName,
      @JsonKey(name: 'prenom') String? firstName,
      @JsonKey(name: 'numero') String? licenseeNumber,
      UserDtoClub? club});

  @override
  $UserDtoClubCopyWith<$Res>? get club;
}

/// @nodoc
class __$$UserDtoDataImplCopyWithImpl<$Res>
    extends _$UserDtoDataCopyWithImpl<$Res, _$UserDtoDataImpl>
    implements _$$UserDtoDataImplCopyWith<$Res> {
  __$$UserDtoDataImplCopyWithImpl(
      _$UserDtoDataImpl _value, $Res Function(_$UserDtoDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? lastName = freezed,
    Object? firstName = freezed,
    Object? licenseeNumber = freezed,
    Object? club = freezed,
  }) {
    return _then(_$UserDtoDataImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseeNumber: freezed == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      club: freezed == club
          ? _value.club
          : club // ignore: cast_nullable_to_non_nullable
              as UserDtoClub?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDtoDataImpl implements _UserDtoData {
  const _$UserDtoDataImpl(
      {required this.role,
      @JsonKey(name: 'nom') this.lastName,
      @JsonKey(name: 'prenom') this.firstName,
      @JsonKey(name: 'numero') this.licenseeNumber,
      this.club});

  factory _$UserDtoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoDataImplFromJson(json);

  @override
  final String role;
  @override
  @JsonKey(name: 'nom')
  final String? lastName;
  @override
  @JsonKey(name: 'prenom')
  final String? firstName;
  @override
  @JsonKey(name: 'numero')
  final String? licenseeNumber;
  @override
  final UserDtoClub? club;

  @override
  String toString() {
    return 'UserDtoData(role: $role, lastName: $lastName, firstName: $firstName, licenseeNumber: $licenseeNumber, club: $club)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoDataImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.licenseeNumber, licenseeNumber) ||
                other.licenseeNumber == licenseeNumber) &&
            (identical(other.club, club) || other.club == club));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, role, lastName, firstName, licenseeNumber, club);

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoDataImplCopyWith<_$UserDtoDataImpl> get copyWith =>
      __$$UserDtoDataImplCopyWithImpl<_$UserDtoDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoDataImplToJson(
      this,
    );
  }
}

abstract class _UserDtoData implements UserDtoData {
  const factory _UserDtoData(
      {required final String role,
      @JsonKey(name: 'nom') final String? lastName,
      @JsonKey(name: 'prenom') final String? firstName,
      @JsonKey(name: 'numero') final String? licenseeNumber,
      final UserDtoClub? club}) = _$UserDtoDataImpl;

  factory _UserDtoData.fromJson(Map<String, dynamic> json) =
      _$UserDtoDataImpl.fromJson;

  @override
  String get role;
  @override
  @JsonKey(name: 'nom')
  String? get lastName;
  @override
  @JsonKey(name: 'prenom')
  String? get firstName;
  @override
  @JsonKey(name: 'numero')
  String? get licenseeNumber;
  @override
  UserDtoClub? get club;

  /// Create a copy of UserDtoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoDataImplCopyWith<_$UserDtoDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDtoClub _$UserDtoClubFromJson(Map<String, dynamic> json) {
  return _UserDtoClub.fromJson(json);
}

/// @nodoc
mixin _$UserDtoClub {
  String get label => throw _privateConstructorUsedError;

  /// Serializes this UserDtoClub to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDtoClub
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDtoClubCopyWith<UserDtoClub> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDtoClubCopyWith<$Res> {
  factory $UserDtoClubCopyWith(
          UserDtoClub value, $Res Function(UserDtoClub) then) =
      _$UserDtoClubCopyWithImpl<$Res, UserDtoClub>;
  @useResult
  $Res call({String label});
}

/// @nodoc
class _$UserDtoClubCopyWithImpl<$Res, $Val extends UserDtoClub>
    implements $UserDtoClubCopyWith<$Res> {
  _$UserDtoClubCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDtoClub
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDtoClubImplCopyWith<$Res>
    implements $UserDtoClubCopyWith<$Res> {
  factory _$$UserDtoClubImplCopyWith(
          _$UserDtoClubImpl value, $Res Function(_$UserDtoClubImpl) then) =
      __$$UserDtoClubImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label});
}

/// @nodoc
class __$$UserDtoClubImplCopyWithImpl<$Res>
    extends _$UserDtoClubCopyWithImpl<$Res, _$UserDtoClubImpl>
    implements _$$UserDtoClubImplCopyWith<$Res> {
  __$$UserDtoClubImplCopyWithImpl(
      _$UserDtoClubImpl _value, $Res Function(_$UserDtoClubImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDtoClub
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
  }) {
    return _then(_$UserDtoClubImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDtoClubImpl implements _UserDtoClub {
  const _$UserDtoClubImpl({required this.label});

  factory _$UserDtoClubImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDtoClubImplFromJson(json);

  @override
  final String label;

  @override
  String toString() {
    return 'UserDtoClub(label: $label)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDtoClubImpl &&
            (identical(other.label, label) || other.label == label));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label);

  /// Create a copy of UserDtoClub
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDtoClubImplCopyWith<_$UserDtoClubImpl> get copyWith =>
      __$$UserDtoClubImplCopyWithImpl<_$UserDtoClubImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDtoClubImplToJson(
      this,
    );
  }
}

abstract class _UserDtoClub implements UserDtoClub {
  const factory _UserDtoClub({required final String label}) = _$UserDtoClubImpl;

  factory _UserDtoClub.fromJson(Map<String, dynamic> json) =
      _$UserDtoClubImpl.fromJson;

  @override
  String get label;

  /// Create a copy of UserDtoClub
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDtoClubImplCopyWith<_$UserDtoClubImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
