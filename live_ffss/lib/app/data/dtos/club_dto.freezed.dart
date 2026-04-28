// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClubDto _$ClubDtoFromJson(Map<String, dynamic> json) {
  return _ClubDto.fromJson(json);
}

/// @nodoc
mixin _$ClubDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomCompletOrga')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomCourt')
  String? get shortName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'bonnet')
  String? get capUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes => throw _privateConstructorUsedError;
  @JsonKey(name: 'officiels')
  List<RefereeDto> get referees => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClubDtoCopyWith<ClubDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubDtoCopyWith<$Res> {
  factory $ClubDtoCopyWith(ClubDto value, $Res Function(ClubDto) then) =
      _$ClubDtoCopyWithImpl<$Res, ClubDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NomCompletOrga') String name,
      @JsonKey(name: 'NomCourt') String? shortName,
      @JsonKey(name: 'logo') String? logoUrl,
      @JsonKey(name: 'bonnet') String? capUrl,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes,
      @JsonKey(name: 'officiels') List<RefereeDto> referees});
}

/// @nodoc
class _$ClubDtoCopyWithImpl<$Res, $Val extends ClubDto>
    implements $ClubDtoCopyWith<$Res> {
  _$ClubDtoCopyWithImpl(this._value, this._then);

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
              as List<AthleteDto>,
      referees: null == referees
          ? _value.referees
          : referees // ignore: cast_nullable_to_non_nullable
              as List<RefereeDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClubDtoImplCopyWith<$Res> implements $ClubDtoCopyWith<$Res> {
  factory _$$ClubDtoImplCopyWith(
          _$ClubDtoImpl value, $Res Function(_$ClubDtoImpl) then) =
      __$$ClubDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NomCompletOrga') String name,
      @JsonKey(name: 'NomCourt') String? shortName,
      @JsonKey(name: 'logo') String? logoUrl,
      @JsonKey(name: 'bonnet') String? capUrl,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes,
      @JsonKey(name: 'officiels') List<RefereeDto> referees});
}

/// @nodoc
class __$$ClubDtoImplCopyWithImpl<$Res>
    extends _$ClubDtoCopyWithImpl<$Res, _$ClubDtoImpl>
    implements _$$ClubDtoImplCopyWith<$Res> {
  __$$ClubDtoImplCopyWithImpl(
      _$ClubDtoImpl _value, $Res Function(_$ClubDtoImpl) _then)
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
    return _then(_$ClubDtoImpl(
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
              as List<AthleteDto>,
      referees: null == referees
          ? _value._referees
          : referees // ignore: cast_nullable_to_non_nullable
              as List<RefereeDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClubDtoImpl implements _ClubDto {
  const _$ClubDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'NomCompletOrga') required this.name,
      @JsonKey(name: 'NomCourt') this.shortName,
      @JsonKey(name: 'logo') this.logoUrl,
      @JsonKey(name: 'bonnet') this.capUrl,
      @JsonKey(name: 'athletes')
      final List<AthleteDto> athletes = const <AthleteDto>[],
      @JsonKey(name: 'officiels')
      final List<RefereeDto> referees = const <RefereeDto>[]})
      : _athletes = athletes,
        _referees = referees;

  factory _$ClubDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClubDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'NomCompletOrga')
  final String name;
  @override
  @JsonKey(name: 'NomCourt')
  final String? shortName;
  @override
  @JsonKey(name: 'logo')
  final String? logoUrl;
  @override
  @JsonKey(name: 'bonnet')
  final String? capUrl;
  final List<AthleteDto> _athletes;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  final List<RefereeDto> _referees;
  @override
  @JsonKey(name: 'officiels')
  List<RefereeDto> get referees {
    if (_referees is EqualUnmodifiableListView) return _referees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_referees);
  }

  @override
  String toString() {
    return 'ClubDto(id: $id, name: $name, shortName: $shortName, logoUrl: $logoUrl, capUrl: $capUrl, athletes: $athletes, referees: $referees)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubDtoImpl &&
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
  _$$ClubDtoImplCopyWith<_$ClubDtoImpl> get copyWith =>
      __$$ClubDtoImplCopyWithImpl<_$ClubDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClubDtoImplToJson(
      this,
    );
  }
}

abstract class _ClubDto implements ClubDto {
  const factory _ClubDto(
          {@JsonKey(name: 'Id') required final int id,
          @JsonKey(name: 'NomCompletOrga') required final String name,
          @JsonKey(name: 'NomCourt') final String? shortName,
          @JsonKey(name: 'logo') final String? logoUrl,
          @JsonKey(name: 'bonnet') final String? capUrl,
          @JsonKey(name: 'athletes') final List<AthleteDto> athletes,
          @JsonKey(name: 'officiels') final List<RefereeDto> referees}) =
      _$ClubDtoImpl;

  factory _ClubDto.fromJson(Map<String, dynamic> json) = _$ClubDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'NomCompletOrga')
  String get name;
  @override
  @JsonKey(name: 'NomCourt')
  String? get shortName;
  @override
  @JsonKey(name: 'logo')
  String? get logoUrl;
  @override
  @JsonKey(name: 'bonnet')
  String? get capUrl;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes;
  @override
  @JsonKey(name: 'officiels')
  List<RefereeDto> get referees;
  @override
  @JsonKey(ignore: true)
  _$$ClubDtoImplCopyWith<_$ClubDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
