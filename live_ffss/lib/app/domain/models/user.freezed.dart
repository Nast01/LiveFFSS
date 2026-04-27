// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String get token => throw _privateConstructorUsedError;
  DateTime get tokenExpiration => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  UserType get type => throw _privateConstructorUsedError;
  UserRole get role => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get licenseeNumber => throw _privateConstructorUsedError;
  String? get clubName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call(
      {String token,
      DateTime tokenExpiration,
      String label,
      UserType type,
      UserRole role,
      String? firstName,
      String? lastName,
      String? licenseeNumber,
      String? clubName});
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? tokenExpiration = null,
    Object? label = null,
    Object? type = null,
    Object? role = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? licenseeNumber = freezed,
    Object? clubName = freezed,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpiration: null == tokenExpiration
          ? _value.tokenExpiration
          : tokenExpiration // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UserType,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseeNumber: freezed == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      clubName: freezed == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
          _$UserImpl value, $Res Function(_$UserImpl) then) =
      __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String token,
      DateTime tokenExpiration,
      String label,
      UserType type,
      UserRole role,
      String? firstName,
      String? lastName,
      String? licenseeNumber,
      String? clubName});
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? tokenExpiration = null,
    Object? label = null,
    Object? type = null,
    Object? role = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? licenseeNumber = freezed,
    Object? clubName = freezed,
  }) {
    return _then(_$UserImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      tokenExpiration: null == tokenExpiration
          ? _value.tokenExpiration
          : tokenExpiration // ignore: cast_nullable_to_non_nullable
              as DateTime,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as UserType,
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as UserRole,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      licenseeNumber: freezed == licenseeNumber
          ? _value.licenseeNumber
          : licenseeNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      clubName: freezed == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl(
      {required this.token,
      required this.tokenExpiration,
      required this.label,
      required this.type,
      required this.role,
      this.firstName,
      this.lastName,
      this.licenseeNumber,
      this.clubName});

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String token;
  @override
  final DateTime tokenExpiration;
  @override
  final String label;
  @override
  final UserType type;
  @override
  final UserRole role;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? licenseeNumber;
  @override
  final String? clubName;

  @override
  String toString() {
    return 'User(token: $token, tokenExpiration: $tokenExpiration, label: $label, type: $type, role: $role, firstName: $firstName, lastName: $lastName, licenseeNumber: $licenseeNumber, clubName: $clubName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.tokenExpiration, tokenExpiration) ||
                other.tokenExpiration == tokenExpiration) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.licenseeNumber, licenseeNumber) ||
                other.licenseeNumber == licenseeNumber) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token, tokenExpiration, label,
      type, role, firstName, lastName, licenseeNumber, clubName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(
      this,
    );
  }
}

abstract class _User implements User {
  const factory _User(
      {required final String token,
      required final DateTime tokenExpiration,
      required final String label,
      required final UserType type,
      required final UserRole role,
      final String? firstName,
      final String? lastName,
      final String? licenseeNumber,
      final String? clubName}) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String get token;
  @override
  DateTime get tokenExpiration;
  @override
  String get label;
  @override
  UserType get type;
  @override
  UserRole get role;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get licenseeNumber;
  @override
  String? get clubName;
  @override
  @JsonKey(ignore: true)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
