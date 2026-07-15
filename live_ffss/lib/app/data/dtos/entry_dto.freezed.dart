// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EntryDto _$EntryDtoFromJson(Map<String, dynamic> json) {
  return _EntryDto.fromJson(json);
}

/// @nodoc
mixin _$EntryDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'IdEpreuve')
  int get raceId => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie')
  CategoryDto get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'IdOrganisme')
  int get organismeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'Organisme')
  ClubDto? get organisme => throw _privateConstructorUsedError;
  @JsonKey(name: 'Statut')
  int get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'statutLabel')
  String get statusLabel =>
      throw _privateConstructorUsedError; // Entry-level performance exists on the results endpoint's nested
// engagement, not on the engagement list (where it's per-athlete).
  @JsonKey(name: 'performance')
  int get entryTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'performanceLabel')
  String get entryTimeLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'forfait')
  bool get isForfeit => throw _privateConstructorUsedError;
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes => throw _privateConstructorUsedError;

  /// Serializes this EntryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntryDtoCopyWith<EntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryDtoCopyWith<$Res> {
  factory $EntryDtoCopyWith(EntryDto value, $Res Function(EntryDto) then) =
      _$EntryDtoCopyWithImpl<$Res, EntryDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdEpreuve') int raceId,
      @JsonKey(name: 'categorie') CategoryDto category,
      @JsonKey(name: 'IdOrganisme') int organismeId,
      @JsonKey(name: 'Organisme') ClubDto? organisme,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'performance') int entryTime,
      @JsonKey(name: 'performanceLabel') String entryTimeLabel,
      @JsonKey(name: 'forfait') bool isForfeit,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes});

  $CategoryDtoCopyWith<$Res> get category;
  $ClubDtoCopyWith<$Res>? get organisme;
}

/// @nodoc
class _$EntryDtoCopyWithImpl<$Res, $Val extends EntryDto>
    implements $EntryDtoCopyWith<$Res> {
  _$EntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raceId = null,
    Object? category = null,
    Object? organismeId = null,
    Object? organisme = freezed,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? isForfeit = null,
    Object? athletes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryDto,
      organismeId: null == organismeId
          ? _value.organismeId
          : organismeId // ignore: cast_nullable_to_non_nullable
              as int,
      organisme: freezed == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as ClubDto?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isForfeit: null == isForfeit
          ? _value.isForfeit
          : isForfeit // ignore: cast_nullable_to_non_nullable
              as bool,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
    ) as $Val);
  }

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryDtoCopyWith<$Res> get category {
    return $CategoryDtoCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ClubDtoCopyWith<$Res>? get organisme {
    if (_value.organisme == null) {
      return null;
    }

    return $ClubDtoCopyWith<$Res>(_value.organisme!, (value) {
      return _then(_value.copyWith(organisme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EntryDtoImplCopyWith<$Res>
    implements $EntryDtoCopyWith<$Res> {
  factory _$$EntryDtoImplCopyWith(
          _$EntryDtoImpl value, $Res Function(_$EntryDtoImpl) then) =
      __$$EntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'IdEpreuve') int raceId,
      @JsonKey(name: 'categorie') CategoryDto category,
      @JsonKey(name: 'IdOrganisme') int organismeId,
      @JsonKey(name: 'Organisme') ClubDto? organisme,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'performance') int entryTime,
      @JsonKey(name: 'performanceLabel') String entryTimeLabel,
      @JsonKey(name: 'forfait') bool isForfeit,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes});

  @override
  $CategoryDtoCopyWith<$Res> get category;
  @override
  $ClubDtoCopyWith<$Res>? get organisme;
}

/// @nodoc
class __$$EntryDtoImplCopyWithImpl<$Res>
    extends _$EntryDtoCopyWithImpl<$Res, _$EntryDtoImpl>
    implements _$$EntryDtoImplCopyWith<$Res> {
  __$$EntryDtoImplCopyWithImpl(
      _$EntryDtoImpl _value, $Res Function(_$EntryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? raceId = null,
    Object? category = null,
    Object? organismeId = null,
    Object? organisme = freezed,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? isForfeit = null,
    Object? athletes = null,
  }) {
    return _then(_$EntryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryDto,
      organismeId: null == organismeId
          ? _value.organismeId
          : organismeId // ignore: cast_nullable_to_non_nullable
              as int,
      organisme: freezed == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as ClubDto?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isForfeit: null == isForfeit
          ? _value.isForfeit
          : isForfeit // ignore: cast_nullable_to_non_nullable
              as bool,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntryDtoImpl implements _EntryDto {
  const _$EntryDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'IdEpreuve') this.raceId = 0,
      @JsonKey(name: 'categorie') required this.category,
      @JsonKey(name: 'IdOrganisme') this.organismeId = 0,
      @JsonKey(name: 'Organisme') this.organisme,
      @JsonKey(name: 'Statut') required this.status,
      @JsonKey(name: 'statutLabel') required this.statusLabel,
      @JsonKey(name: 'performance') this.entryTime = 0,
      @JsonKey(name: 'performanceLabel') this.entryTimeLabel = '',
      @JsonKey(name: 'forfait') this.isForfeit = false,
      @JsonKey(name: 'athletes')
      final List<AthleteDto> athletes = const <AthleteDto>[]})
      : _athletes = athletes;

  factory _$EntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'IdEpreuve')
  final int raceId;
  @override
  @JsonKey(name: 'categorie')
  final CategoryDto category;
  @override
  @JsonKey(name: 'IdOrganisme')
  final int organismeId;
  @override
  @JsonKey(name: 'Organisme')
  final ClubDto? organisme;
  @override
  @JsonKey(name: 'Statut')
  final int status;
  @override
  @JsonKey(name: 'statutLabel')
  final String statusLabel;
// Entry-level performance exists on the results endpoint's nested
// engagement, not on the engagement list (where it's per-athlete).
  @override
  @JsonKey(name: 'performance')
  final int entryTime;
  @override
  @JsonKey(name: 'performanceLabel')
  final String entryTimeLabel;
  @override
  @JsonKey(name: 'forfait')
  final bool isForfeit;
  final List<AthleteDto> _athletes;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  @override
  String toString() {
    return 'EntryDto(id: $id, raceId: $raceId, category: $category, organismeId: $organismeId, organisme: $organisme, status: $status, statusLabel: $statusLabel, entryTime: $entryTime, entryTimeLabel: $entryTimeLabel, isForfeit: $isForfeit, athletes: $athletes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.raceId, raceId) || other.raceId == raceId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.organismeId, organismeId) ||
                other.organismeId == organismeId) &&
            (identical(other.organisme, organisme) ||
                other.organisme == organisme) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.entryTime, entryTime) ||
                other.entryTime == entryTime) &&
            (identical(other.entryTimeLabel, entryTimeLabel) ||
                other.entryTimeLabel == entryTimeLabel) &&
            (identical(other.isForfeit, isForfeit) ||
                other.isForfeit == isForfeit) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      raceId,
      category,
      organismeId,
      organisme,
      status,
      statusLabel,
      entryTime,
      entryTimeLabel,
      isForfeit,
      const DeepCollectionEquality().hash(_athletes));

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryDtoImplCopyWith<_$EntryDtoImpl> get copyWith =>
      __$$EntryDtoImplCopyWithImpl<_$EntryDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryDtoImplToJson(
      this,
    );
  }
}

abstract class _EntryDto implements EntryDto {
  const factory _EntryDto(
          {@JsonKey(name: 'Id') required final int id,
          @JsonKey(name: 'IdEpreuve') final int raceId,
          @JsonKey(name: 'categorie') required final CategoryDto category,
          @JsonKey(name: 'IdOrganisme') final int organismeId,
          @JsonKey(name: 'Organisme') final ClubDto? organisme,
          @JsonKey(name: 'Statut') required final int status,
          @JsonKey(name: 'statutLabel') required final String statusLabel,
          @JsonKey(name: 'performance') final int entryTime,
          @JsonKey(name: 'performanceLabel') final String entryTimeLabel,
          @JsonKey(name: 'forfait') final bool isForfeit,
          @JsonKey(name: 'athletes') final List<AthleteDto> athletes}) =
      _$EntryDtoImpl;

  factory _EntryDto.fromJson(Map<String, dynamic> json) =
      _$EntryDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'IdEpreuve')
  int get raceId;
  @override
  @JsonKey(name: 'categorie')
  CategoryDto get category;
  @override
  @JsonKey(name: 'IdOrganisme')
  int get organismeId;
  @override
  @JsonKey(name: 'Organisme')
  ClubDto? get organisme;
  @override
  @JsonKey(name: 'Statut')
  int get status;
  @override
  @JsonKey(name: 'statutLabel')
  String
      get statusLabel; // Entry-level performance exists on the results endpoint's nested
// engagement, not on the engagement list (where it's per-athlete).
  @override
  @JsonKey(name: 'performance')
  int get entryTime;
  @override
  @JsonKey(name: 'performanceLabel')
  String get entryTimeLabel;
  @override
  @JsonKey(name: 'forfait')
  bool get isForfeit;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes;

  /// Create a copy of EntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntryDtoImplCopyWith<_$EntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
