// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Competition _$CompetitionFromJson(Map<String, dynamic> json) {
  return _Competition.fromJson(json);
}

/// @nodoc
mixin _$Competition {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime? get beginDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  DateTime? get beginEntryLimitDate => throw _privateConstructorUsedError;
  DateTime? get endEntryLimitDate => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int get statusCode => throw _privateConstructorUsedError;
  String get statusLabel => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int get speciality => throw _privateConstructorUsedError;
  String get specialityLabel => throw _privateConstructorUsedError;
  String get typeWater => throw _privateConstructorUsedError;
  String get typePool => throw _privateConstructorUsedError;
  String get typeChrono => throw _privateConstructorUsedError;
  bool get isEligibleToNationalRecord => throw _privateConstructorUsedError;
  int get numberOfLanes => throw _privateConstructorUsedError;
  String get organizer => throw _privateConstructorUsedError;
  bool get hasBegun => throw _privateConstructorUsedError;
  bool get hasResult => throw _privateConstructorUsedError;
  bool get hasPassed => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;
  String get levelLabel => throw _privateConstructorUsedError;
  Club get organizerClub => throw _privateConstructorUsedError;
  String? get refereePrincipal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompetitionCopyWith<Competition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetitionCopyWith<$Res> {
  factory $CompetitionCopyWith(
          Competition value, $Res Function(Competition) then) =
      _$CompetitionCopyWithImpl<$Res, Competition>;
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime? beginDate,
      DateTime? endDate,
      DateTime? beginEntryLimitDate,
      DateTime? endEntryLimitDate,
      String? location,
      int statusCode,
      String statusLabel,
      String? description,
      int speciality,
      String specialityLabel,
      String typeWater,
      String typePool,
      String typeChrono,
      bool isEligibleToNationalRecord,
      int numberOfLanes,
      String organizer,
      bool hasBegun,
      bool hasResult,
      bool hasPassed,
      int level,
      String levelLabel,
      Club organizerClub,
      String? refereePrincipal});

  $ClubCopyWith<$Res> get organizerClub;
}

/// @nodoc
class _$CompetitionCopyWithImpl<$Res, $Val extends Competition>
    implements $CompetitionCopyWith<$Res> {
  _$CompetitionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginDate = freezed,
    Object? endDate = freezed,
    Object? beginEntryLimitDate = freezed,
    Object? endEntryLimitDate = freezed,
    Object? location = freezed,
    Object? statusCode = null,
    Object? statusLabel = null,
    Object? description = freezed,
    Object? speciality = null,
    Object? specialityLabel = null,
    Object? typeWater = null,
    Object? typePool = null,
    Object? typeChrono = null,
    Object? isEligibleToNationalRecord = null,
    Object? numberOfLanes = null,
    Object? organizer = null,
    Object? hasBegun = null,
    Object? hasResult = null,
    Object? hasPassed = null,
    Object? level = null,
    Object? levelLabel = null,
    Object? organizerClub = null,
    Object? refereePrincipal = freezed,
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
      beginDate: freezed == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      beginEntryLimitDate: freezed == beginEntryLimitDate
          ? _value.beginEntryLimitDate
          : beginEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endEntryLimitDate: freezed == endEntryLimitDate
          ? _value.endEntryLimitDate
          : endEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      speciality: null == speciality
          ? _value.speciality
          : speciality // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      typeWater: null == typeWater
          ? _value.typeWater
          : typeWater // ignore: cast_nullable_to_non_nullable
              as String,
      typePool: null == typePool
          ? _value.typePool
          : typePool // ignore: cast_nullable_to_non_nullable
              as String,
      typeChrono: null == typeChrono
          ? _value.typeChrono
          : typeChrono // ignore: cast_nullable_to_non_nullable
              as String,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      numberOfLanes: null == numberOfLanes
          ? _value.numberOfLanes
          : numberOfLanes // ignore: cast_nullable_to_non_nullable
              as int,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as String,
      hasBegun: null == hasBegun
          ? _value.hasBegun
          : hasBegun // ignore: cast_nullable_to_non_nullable
              as bool,
      hasResult: null == hasResult
          ? _value.hasResult
          : hasResult // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPassed: null == hasPassed
          ? _value.hasPassed
          : hasPassed // ignore: cast_nullable_to_non_nullable
              as bool,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      levelLabel: null == levelLabel
          ? _value.levelLabel
          : levelLabel // ignore: cast_nullable_to_non_nullable
              as String,
      organizerClub: null == organizerClub
          ? _value.organizerClub
          : organizerClub // ignore: cast_nullable_to_non_nullable
              as Club,
      refereePrincipal: freezed == refereePrincipal
          ? _value.refereePrincipal
          : refereePrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ClubCopyWith<$Res> get organizerClub {
    return $ClubCopyWith<$Res>(_value.organizerClub, (value) {
      return _then(_value.copyWith(organizerClub: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompetitionImplCopyWith<$Res>
    implements $CompetitionCopyWith<$Res> {
  factory _$$CompetitionImplCopyWith(
          _$CompetitionImpl value, $Res Function(_$CompetitionImpl) then) =
      __$$CompetitionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      DateTime? beginDate,
      DateTime? endDate,
      DateTime? beginEntryLimitDate,
      DateTime? endEntryLimitDate,
      String? location,
      int statusCode,
      String statusLabel,
      String? description,
      int speciality,
      String specialityLabel,
      String typeWater,
      String typePool,
      String typeChrono,
      bool isEligibleToNationalRecord,
      int numberOfLanes,
      String organizer,
      bool hasBegun,
      bool hasResult,
      bool hasPassed,
      int level,
      String levelLabel,
      Club organizerClub,
      String? refereePrincipal});

  @override
  $ClubCopyWith<$Res> get organizerClub;
}

/// @nodoc
class __$$CompetitionImplCopyWithImpl<$Res>
    extends _$CompetitionCopyWithImpl<$Res, _$CompetitionImpl>
    implements _$$CompetitionImplCopyWith<$Res> {
  __$$CompetitionImplCopyWithImpl(
      _$CompetitionImpl _value, $Res Function(_$CompetitionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginDate = freezed,
    Object? endDate = freezed,
    Object? beginEntryLimitDate = freezed,
    Object? endEntryLimitDate = freezed,
    Object? location = freezed,
    Object? statusCode = null,
    Object? statusLabel = null,
    Object? description = freezed,
    Object? speciality = null,
    Object? specialityLabel = null,
    Object? typeWater = null,
    Object? typePool = null,
    Object? typeChrono = null,
    Object? isEligibleToNationalRecord = null,
    Object? numberOfLanes = null,
    Object? organizer = null,
    Object? hasBegun = null,
    Object? hasResult = null,
    Object? hasPassed = null,
    Object? level = null,
    Object? levelLabel = null,
    Object? organizerClub = null,
    Object? refereePrincipal = freezed,
  }) {
    return _then(_$CompetitionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      beginDate: freezed == beginDate
          ? _value.beginDate
          : beginDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      beginEntryLimitDate: freezed == beginEntryLimitDate
          ? _value.beginEntryLimitDate
          : beginEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endEntryLimitDate: freezed == endEntryLimitDate
          ? _value.endEntryLimitDate
          : endEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      speciality: null == speciality
          ? _value.speciality
          : speciality // ignore: cast_nullable_to_non_nullable
              as int,
      specialityLabel: null == specialityLabel
          ? _value.specialityLabel
          : specialityLabel // ignore: cast_nullable_to_non_nullable
              as String,
      typeWater: null == typeWater
          ? _value.typeWater
          : typeWater // ignore: cast_nullable_to_non_nullable
              as String,
      typePool: null == typePool
          ? _value.typePool
          : typePool // ignore: cast_nullable_to_non_nullable
              as String,
      typeChrono: null == typeChrono
          ? _value.typeChrono
          : typeChrono // ignore: cast_nullable_to_non_nullable
              as String,
      isEligibleToNationalRecord: null == isEligibleToNationalRecord
          ? _value.isEligibleToNationalRecord
          : isEligibleToNationalRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      numberOfLanes: null == numberOfLanes
          ? _value.numberOfLanes
          : numberOfLanes // ignore: cast_nullable_to_non_nullable
              as int,
      organizer: null == organizer
          ? _value.organizer
          : organizer // ignore: cast_nullable_to_non_nullable
              as String,
      hasBegun: null == hasBegun
          ? _value.hasBegun
          : hasBegun // ignore: cast_nullable_to_non_nullable
              as bool,
      hasResult: null == hasResult
          ? _value.hasResult
          : hasResult // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPassed: null == hasPassed
          ? _value.hasPassed
          : hasPassed // ignore: cast_nullable_to_non_nullable
              as bool,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      levelLabel: null == levelLabel
          ? _value.levelLabel
          : levelLabel // ignore: cast_nullable_to_non_nullable
              as String,
      organizerClub: null == organizerClub
          ? _value.organizerClub
          : organizerClub // ignore: cast_nullable_to_non_nullable
              as Club,
      refereePrincipal: freezed == refereePrincipal
          ? _value.refereePrincipal
          : refereePrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetitionImpl implements _Competition {
  const _$CompetitionImpl(
      {required this.id,
      required this.name,
      this.beginDate,
      this.endDate,
      this.beginEntryLimitDate,
      this.endEntryLimitDate,
      this.location,
      required this.statusCode,
      required this.statusLabel,
      this.description,
      required this.speciality,
      required this.specialityLabel,
      required this.typeWater,
      required this.typePool,
      required this.typeChrono,
      required this.isEligibleToNationalRecord,
      required this.numberOfLanes,
      required this.organizer,
      required this.hasBegun,
      required this.hasResult,
      required this.hasPassed,
      required this.level,
      required this.levelLabel,
      required this.organizerClub,
      this.refereePrincipal});

  factory _$CompetitionImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetitionImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final DateTime? beginDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime? beginEntryLimitDate;
  @override
  final DateTime? endEntryLimitDate;
  @override
  final String? location;
  @override
  final int statusCode;
  @override
  final String statusLabel;
  @override
  final String? description;
  @override
  final int speciality;
  @override
  final String specialityLabel;
  @override
  final String typeWater;
  @override
  final String typePool;
  @override
  final String typeChrono;
  @override
  final bool isEligibleToNationalRecord;
  @override
  final int numberOfLanes;
  @override
  final String organizer;
  @override
  final bool hasBegun;
  @override
  final bool hasResult;
  @override
  final bool hasPassed;
  @override
  final int level;
  @override
  final String levelLabel;
  @override
  final Club organizerClub;
  @override
  final String? refereePrincipal;

  @override
  String toString() {
    return 'Competition(id: $id, name: $name, beginDate: $beginDate, endDate: $endDate, beginEntryLimitDate: $beginEntryLimitDate, endEntryLimitDate: $endEntryLimitDate, location: $location, statusCode: $statusCode, statusLabel: $statusLabel, description: $description, speciality: $speciality, specialityLabel: $specialityLabel, typeWater: $typeWater, typePool: $typePool, typeChrono: $typeChrono, isEligibleToNationalRecord: $isEligibleToNationalRecord, numberOfLanes: $numberOfLanes, organizer: $organizer, hasBegun: $hasBegun, hasResult: $hasResult, hasPassed: $hasPassed, level: $level, levelLabel: $levelLabel, organizerClub: $organizerClub, refereePrincipal: $refereePrincipal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetitionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.beginDate, beginDate) ||
                other.beginDate == beginDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.beginEntryLimitDate, beginEntryLimitDate) ||
                other.beginEntryLimitDate == beginEntryLimitDate) &&
            (identical(other.endEntryLimitDate, endEntryLimitDate) ||
                other.endEntryLimitDate == endEntryLimitDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.speciality, speciality) ||
                other.speciality == speciality) &&
            (identical(other.specialityLabel, specialityLabel) ||
                other.specialityLabel == specialityLabel) &&
            (identical(other.typeWater, typeWater) ||
                other.typeWater == typeWater) &&
            (identical(other.typePool, typePool) ||
                other.typePool == typePool) &&
            (identical(other.typeChrono, typeChrono) ||
                other.typeChrono == typeChrono) &&
            (identical(other.isEligibleToNationalRecord,
                    isEligibleToNationalRecord) ||
                other.isEligibleToNationalRecord ==
                    isEligibleToNationalRecord) &&
            (identical(other.numberOfLanes, numberOfLanes) ||
                other.numberOfLanes == numberOfLanes) &&
            (identical(other.organizer, organizer) ||
                other.organizer == organizer) &&
            (identical(other.hasBegun, hasBegun) ||
                other.hasBegun == hasBegun) &&
            (identical(other.hasResult, hasResult) ||
                other.hasResult == hasResult) &&
            (identical(other.hasPassed, hasPassed) ||
                other.hasPassed == hasPassed) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.levelLabel, levelLabel) ||
                other.levelLabel == levelLabel) &&
            (identical(other.organizerClub, organizerClub) ||
                other.organizerClub == organizerClub) &&
            (identical(other.refereePrincipal, refereePrincipal) ||
                other.refereePrincipal == refereePrincipal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        beginDate,
        endDate,
        beginEntryLimitDate,
        endEntryLimitDate,
        location,
        statusCode,
        statusLabel,
        description,
        speciality,
        specialityLabel,
        typeWater,
        typePool,
        typeChrono,
        isEligibleToNationalRecord,
        numberOfLanes,
        organizer,
        hasBegun,
        hasResult,
        hasPassed,
        level,
        levelLabel,
        organizerClub,
        refereePrincipal
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetitionImplCopyWith<_$CompetitionImpl> get copyWith =>
      __$$CompetitionImplCopyWithImpl<_$CompetitionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetitionImplToJson(
      this,
    );
  }
}

abstract class _Competition implements Competition {
  const factory _Competition(
      {required final int id,
      required final String name,
      final DateTime? beginDate,
      final DateTime? endDate,
      final DateTime? beginEntryLimitDate,
      final DateTime? endEntryLimitDate,
      final String? location,
      required final int statusCode,
      required final String statusLabel,
      final String? description,
      required final int speciality,
      required final String specialityLabel,
      required final String typeWater,
      required final String typePool,
      required final String typeChrono,
      required final bool isEligibleToNationalRecord,
      required final int numberOfLanes,
      required final String organizer,
      required final bool hasBegun,
      required final bool hasResult,
      required final bool hasPassed,
      required final int level,
      required final String levelLabel,
      required final Club organizerClub,
      final String? refereePrincipal}) = _$CompetitionImpl;

  factory _Competition.fromJson(Map<String, dynamic> json) =
      _$CompetitionImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  DateTime? get beginDate;
  @override
  DateTime? get endDate;
  @override
  DateTime? get beginEntryLimitDate;
  @override
  DateTime? get endEntryLimitDate;
  @override
  String? get location;
  @override
  int get statusCode;
  @override
  String get statusLabel;
  @override
  String? get description;
  @override
  int get speciality;
  @override
  String get specialityLabel;
  @override
  String get typeWater;
  @override
  String get typePool;
  @override
  String get typeChrono;
  @override
  bool get isEligibleToNationalRecord;
  @override
  int get numberOfLanes;
  @override
  String get organizer;
  @override
  bool get hasBegun;
  @override
  bool get hasResult;
  @override
  bool get hasPassed;
  @override
  int get level;
  @override
  String get levelLabel;
  @override
  Club get organizerClub;
  @override
  String? get refereePrincipal;
  @override
  @JsonKey(ignore: true)
  _$$CompetitionImplCopyWith<_$CompetitionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
