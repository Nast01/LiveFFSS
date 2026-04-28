// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Club _$ClubFromJson(Map<String, dynamic> json) {
  return _Club.fromJson(json);
}

/// @nodoc
mixin _$Club {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get shortName => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get capUrl => throw _privateConstructorUsedError;
  List<Athlete> get athletes => throw _privateConstructorUsedError;
  List<Referee> get referees => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClubCopyWith<Club> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubCopyWith<$Res> {
  factory $ClubCopyWith(Club value, $Res Function(Club) then) =
      _$ClubCopyWithImpl<$Res, Club>;
  @useResult
  $Res call(
      {int id,
      String name,
      String? shortName,
      String? logoUrl,
      String? capUrl,
      List<Athlete> athletes,
      List<Referee> referees});
}

/// @nodoc
class _$ClubCopyWithImpl<$Res, $Val extends Club>
    implements $ClubCopyWith<$Res> {
  _$ClubCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = freezed,
    Object? logoUrl = freezed,
    Object? capUrl = freezed,
    Object? athletes = null,
    Object? referees = null,
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
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      capUrl: freezed == capUrl
          ? _value.capUrl
          : capUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
      referees: null == referees
          ? _value.referees
          : referees // ignore: cast_nullable_to_non_nullable
              as List<Referee>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClubImplCopyWith<$Res> implements $ClubCopyWith<$Res> {
  factory _$$ClubImplCopyWith(
          _$ClubImpl value, $Res Function(_$ClubImpl) then) =
      __$$ClubImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String? shortName,
      String? logoUrl,
      String? capUrl,
      List<Athlete> athletes,
      List<Referee> referees});
}

/// @nodoc
class __$$ClubImplCopyWithImpl<$Res>
    extends _$ClubCopyWithImpl<$Res, _$ClubImpl>
    implements _$$ClubImplCopyWith<$Res> {
  __$$ClubImplCopyWithImpl(_$ClubImpl _value, $Res Function(_$ClubImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? shortName = freezed,
    Object? logoUrl = freezed,
    Object? capUrl = freezed,
    Object? athletes = null,
    Object? referees = null,
  }) {
    return _then(_$ClubImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      capUrl: freezed == capUrl
          ? _value.capUrl
          : capUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
      referees: null == referees
          ? _value._referees
          : referees // ignore: cast_nullable_to_non_nullable
              as List<Referee>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClubImpl implements _Club {
  const _$ClubImpl(
      {required this.id,
      required this.name,
      this.shortName,
      this.logoUrl,
      this.capUrl,
      final List<Athlete> athletes = const <Athlete>[],
      final List<Referee> referees = const <Referee>[]})
      : _athletes = athletes,
        _referees = referees;

  factory _$ClubImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClubImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? shortName;
  @override
  final String? logoUrl;
  @override
  final String? capUrl;
  final List<Athlete> _athletes;
  @override
  @JsonKey()
  List<Athlete> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  final List<Referee> _referees;
  @override
  @JsonKey()
  List<Referee> get referees {
    if (_referees is EqualUnmodifiableListView) return _referees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referees);
  }

  @override
  String toString() {
    return 'Club(id: $id, name: $name, shortName: $shortName, logoUrl: $logoUrl, capUrl: $capUrl, athletes: $athletes, referees: $referees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.capUrl, capUrl) || other.capUrl == capUrl) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes) &&
            const DeepCollectionEquality().equals(other._referees, _referees));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      shortName,
      logoUrl,
      capUrl,
      const DeepCollectionEquality().hash(_athletes),
      const DeepCollectionEquality().hash(_referees));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClubImplCopyWith<_$ClubImpl> get copyWith =>
      __$$ClubImplCopyWithImpl<_$ClubImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClubImplToJson(
      this,
    );
  }
}

abstract class _Club implements Club {
  const factory _Club(
      {required final int id,
      required final String name,
      final String? shortName,
      final String? logoUrl,
      final String? capUrl,
      final List<Athlete> athletes,
      final List<Referee> referees}) = _$ClubImpl;

  factory _Club.fromJson(Map<String, dynamic> json) = _$ClubImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get shortName;
  @override
  String? get logoUrl;
  @override
  String? get capUrl;
  @override
  List<Athlete> get athletes;
  @override
  List<Referee> get referees;
  @override
  @JsonKey(ignore: true)
  _$$ClubImplCopyWith<_$ClubImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
