// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CompetitionDto _$CompetitionDtoFromJson(Map<String, dynamic> json) {
  return _CompetitionDto.fromJson(json);
}

/// @nodoc
mixin _$CompetitionDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Debut')
  String? get beginDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fin')
  String? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'DebutEngagement')
  String? get beginEntryLimitDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'FinEngagement')
  String? get endEntryLimitDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'Lieu')
  String? get location => throw _privateConstructorUsedError;
  @JsonKey(name: 'Statut')
  int get statusCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'statutLabel')
  String get statusLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'Specialite')
  int get speciality => throw _privateConstructorUsedError;
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'water')
  String get typeWater => throw _privateConstructorUsedError;
  @JsonKey(name: 'bassin')
  String get typePool => throw _privateConstructorUsedError;
  @JsonKey(name: 'chronoLabel')
  String get typeChrono => throw _privateConstructorUsedError;
  bool get isEligibleToNationalRecord => throw _privateConstructorUsedError;
  @JsonKey(name: 'numberOfLanes')
  int? get numberOfLanes => throw _privateConstructorUsedError;
  @JsonKey(name: 'Organisme')
  CompetitionOrganismeDto get organisme => throw _privateConstructorUsedError;
  bool get hasBegun => throw _privateConstructorUsedError;
  @JsonKey(name: 'hasResultat')
  bool get hasResult => throw _privateConstructorUsedError;
  bool get hasPassed => throw _privateConstructorUsedError;
  @JsonKey(name: 'Niveau')
  int get level => throw _privateConstructorUsedError;
  @JsonKey(name: 'niveauLabel')
  String get levelLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'JugePrincipal')
  String? get refereePrincipal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompetitionDtoCopyWith<CompetitionDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetitionDtoCopyWith<$Res> {
  factory $CompetitionDtoCopyWith(
          CompetitionDto value, $Res Function(CompetitionDto) then) =
      _$CompetitionDtoCopyWithImpl<$Res, CompetitionDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Debut') String? beginDate,
      @JsonKey(name: 'Fin') String? endDate,
      @JsonKey(name: 'DebutEngagement') String? beginEntryLimitDate,
      @JsonKey(name: 'FinEngagement') String? endEntryLimitDate,
      @JsonKey(name: 'Lieu') String? location,
      @JsonKey(name: 'Statut') int statusCode,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'Description') String? description,
      @JsonKey(name: 'Specialite') int speciality,
      @JsonKey(name: 'specialiteLabel') String specialityLabel,
      @JsonKey(name: 'water') String typeWater,
      @JsonKey(name: 'bassin') String typePool,
      @JsonKey(name: 'chronoLabel') String typeChrono,
      bool isEligibleToNationalRecord,
      @JsonKey(name: 'numberOfLanes') int? numberOfLanes,
      @JsonKey(name: 'Organisme') CompetitionOrganismeDto organisme,
      bool hasBegun,
      @JsonKey(name: 'hasResultat') bool hasResult,
      bool hasPassed,
      @JsonKey(name: 'Niveau') int level,
      @JsonKey(name: 'niveauLabel') String levelLabel,
      @JsonKey(name: 'JugePrincipal') String? refereePrincipal});

  $CompetitionOrganismeDtoCopyWith<$Res> get organisme;
}

/// @nodoc
class _$CompetitionDtoCopyWithImpl<$Res, $Val extends CompetitionDto>
    implements $CompetitionDtoCopyWith<$Res> {
  _$CompetitionDtoCopyWithImpl(this._value, this._then);

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
    Object? numberOfLanes = freezed,
    Object? organisme = null,
    Object? hasBegun = null,
    Object? hasResult = null,
    Object? hasPassed = null,
    Object? level = null,
    Object? levelLabel = null,
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
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      beginEntryLimitDate: freezed == beginEntryLimitDate
          ? _value.beginEntryLimitDate
          : beginEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endEntryLimitDate: freezed == endEntryLimitDate
          ? _value.endEntryLimitDate
          : endEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as String?,
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
      numberOfLanes: freezed == numberOfLanes
          ? _value.numberOfLanes
          : numberOfLanes // ignore: cast_nullable_to_non_nullable
              as int?,
      organisme: null == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as CompetitionOrganismeDto,
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
      refereePrincipal: freezed == refereePrincipal
          ? _value.refereePrincipal
          : refereePrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CompetitionOrganismeDtoCopyWith<$Res> get organisme {
    return $CompetitionOrganismeDtoCopyWith<$Res>(_value.organisme, (value) {
      return _then(_value.copyWith(organisme: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CompetitionDtoImplCopyWith<$Res>
    implements $CompetitionDtoCopyWith<$Res> {
  factory _$$CompetitionDtoImplCopyWith(_$CompetitionDtoImpl value,
          $Res Function(_$CompetitionDtoImpl) then) =
      __$$CompetitionDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Debut') String? beginDate,
      @JsonKey(name: 'Fin') String? endDate,
      @JsonKey(name: 'DebutEngagement') String? beginEntryLimitDate,
      @JsonKey(name: 'FinEngagement') String? endEntryLimitDate,
      @JsonKey(name: 'Lieu') String? location,
      @JsonKey(name: 'Statut') int statusCode,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'Description') String? description,
      @JsonKey(name: 'Specialite') int speciality,
      @JsonKey(name: 'specialiteLabel') String specialityLabel,
      @JsonKey(name: 'water') String typeWater,
      @JsonKey(name: 'bassin') String typePool,
      @JsonKey(name: 'chronoLabel') String typeChrono,
      bool isEligibleToNationalRecord,
      @JsonKey(name: 'numberOfLanes') int? numberOfLanes,
      @JsonKey(name: 'Organisme') CompetitionOrganismeDto organisme,
      bool hasBegun,
      @JsonKey(name: 'hasResultat') bool hasResult,
      bool hasPassed,
      @JsonKey(name: 'Niveau') int level,
      @JsonKey(name: 'niveauLabel') String levelLabel,
      @JsonKey(name: 'JugePrincipal') String? refereePrincipal});

  @override
  $CompetitionOrganismeDtoCopyWith<$Res> get organisme;
}

/// @nodoc
class __$$CompetitionDtoImplCopyWithImpl<$Res>
    extends _$CompetitionDtoCopyWithImpl<$Res, _$CompetitionDtoImpl>
    implements _$$CompetitionDtoImplCopyWith<$Res> {
  __$$CompetitionDtoImplCopyWithImpl(
      _$CompetitionDtoImpl _value, $Res Function(_$CompetitionDtoImpl) _then)
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
    Object? numberOfLanes = freezed,
    Object? organisme = null,
    Object? hasBegun = null,
    Object? hasResult = null,
    Object? hasPassed = null,
    Object? level = null,
    Object? levelLabel = null,
    Object? refereePrincipal = freezed,
  }) {
    return _then(_$CompetitionDtoImpl(
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
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      beginEntryLimitDate: freezed == beginEntryLimitDate
          ? _value.beginEntryLimitDate
          : beginEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endEntryLimitDate: freezed == endEntryLimitDate
          ? _value.endEntryLimitDate
          : endEntryLimitDate // ignore: cast_nullable_to_non_nullable
              as String?,
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
      numberOfLanes: freezed == numberOfLanes
          ? _value.numberOfLanes
          : numberOfLanes // ignore: cast_nullable_to_non_nullable
              as int?,
      organisme: null == organisme
          ? _value.organisme
          : organisme // ignore: cast_nullable_to_non_nullable
              as CompetitionOrganismeDto,
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
      refereePrincipal: freezed == refereePrincipal
          ? _value.refereePrincipal
          : refereePrincipal // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetitionDtoImpl implements _CompetitionDto {
  const _$CompetitionDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'Debut') this.beginDate,
      @JsonKey(name: 'Fin') this.endDate,
      @JsonKey(name: 'DebutEngagement') this.beginEntryLimitDate,
      @JsonKey(name: 'FinEngagement') this.endEntryLimitDate,
      @JsonKey(name: 'Lieu') this.location,
      @JsonKey(name: 'Statut') required this.statusCode,
      @JsonKey(name: 'statutLabel') required this.statusLabel,
      @JsonKey(name: 'Description') this.description,
      @JsonKey(name: 'Specialite') required this.speciality,
      @JsonKey(name: 'specialiteLabel') required this.specialityLabel,
      @JsonKey(name: 'water') required this.typeWater,
      @JsonKey(name: 'bassin') required this.typePool,
      @JsonKey(name: 'chronoLabel') required this.typeChrono,
      required this.isEligibleToNationalRecord,
      @JsonKey(name: 'numberOfLanes') this.numberOfLanes,
      @JsonKey(name: 'Organisme') required this.organisme,
      required this.hasBegun,
      @JsonKey(name: 'hasResultat') required this.hasResult,
      required this.hasPassed,
      @JsonKey(name: 'Niveau') required this.level,
      @JsonKey(name: 'niveauLabel') required this.levelLabel,
      @JsonKey(name: 'JugePrincipal') this.refereePrincipal});

  factory _$CompetitionDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetitionDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'Debut')
  final String? beginDate;
  @override
  @JsonKey(name: 'Fin')
  final String? endDate;
  @override
  @JsonKey(name: 'DebutEngagement')
  final String? beginEntryLimitDate;
  @override
  @JsonKey(name: 'FinEngagement')
  final String? endEntryLimitDate;
  @override
  @JsonKey(name: 'Lieu')
  final String? location;
  @override
  @JsonKey(name: 'Statut')
  final int statusCode;
  @override
  @JsonKey(name: 'statutLabel')
  final String statusLabel;
  @override
  @JsonKey(name: 'Description')
  final String? description;
  @override
  @JsonKey(name: 'Specialite')
  final int speciality;
  @override
  @JsonKey(name: 'specialiteLabel')
  final String specialityLabel;
  @override
  @JsonKey(name: 'water')
  final String typeWater;
  @override
  @JsonKey(name: 'bassin')
  final String typePool;
  @override
  @JsonKey(name: 'chronoLabel')
  final String typeChrono;
  @override
  final bool isEligibleToNationalRecord;
  @override
  @JsonKey(name: 'numberOfLanes')
  final int? numberOfLanes;
  @override
  @JsonKey(name: 'Organisme')
  final CompetitionOrganismeDto organisme;
  @override
  final bool hasBegun;
  @override
  @JsonKey(name: 'hasResultat')
  final bool hasResult;
  @override
  final bool hasPassed;
  @override
  @JsonKey(name: 'Niveau')
  final int level;
  @override
  @JsonKey(name: 'niveauLabel')
  final String levelLabel;
  @override
  @JsonKey(name: 'JugePrincipal')
  final String? refereePrincipal;

  @override
  String toString() {
    return 'CompetitionDto(id: $id, name: $name, beginDate: $beginDate, endDate: $endDate, beginEntryLimitDate: $beginEntryLimitDate, endEntryLimitDate: $endEntryLimitDate, location: $location, statusCode: $statusCode, statusLabel: $statusLabel, description: $description, speciality: $speciality, specialityLabel: $specialityLabel, typeWater: $typeWater, typePool: $typePool, typeChrono: $typeChrono, isEligibleToNationalRecord: $isEligibleToNationalRecord, numberOfLanes: $numberOfLanes, organisme: $organisme, hasBegun: $hasBegun, hasResult: $hasResult, hasPassed: $hasPassed, level: $level, levelLabel: $levelLabel, refereePrincipal: $refereePrincipal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetitionDtoImpl &&
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
            (identical(other.organisme, organisme) ||
                other.organisme == organisme) &&
            (identical(other.hasBegun, hasBegun) ||
                other.hasBegun == hasBegun) &&
            (identical(other.hasResult, hasResult) ||
                other.hasResult == hasResult) &&
            (identical(other.hasPassed, hasPassed) ||
                other.hasPassed == hasPassed) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.levelLabel, levelLabel) ||
                other.levelLabel == levelLabel) &&
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
        organisme,
        hasBegun,
        hasResult,
        hasPassed,
        level,
        levelLabel,
        refereePrincipal
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetitionDtoImplCopyWith<_$CompetitionDtoImpl> get copyWith =>
      __$$CompetitionDtoImplCopyWithImpl<_$CompetitionDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetitionDtoImplToJson(
      this,
    );
  }
}

abstract class _CompetitionDto implements CompetitionDto {
  const factory _CompetitionDto(
      {@JsonKey(name: 'Id') required final int id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'Debut') final String? beginDate,
      @JsonKey(name: 'Fin') final String? endDate,
      @JsonKey(name: 'DebutEngagement') final String? beginEntryLimitDate,
      @JsonKey(name: 'FinEngagement') final String? endEntryLimitDate,
      @JsonKey(name: 'Lieu') final String? location,
      @JsonKey(name: 'Statut') required final int statusCode,
      @JsonKey(name: 'statutLabel') required final String statusLabel,
      @JsonKey(name: 'Description') final String? description,
      @JsonKey(name: 'Specialite') required final int speciality,
      @JsonKey(name: 'specialiteLabel') required final String specialityLabel,
      @JsonKey(name: 'water') required final String typeWater,
      @JsonKey(name: 'bassin') required final String typePool,
      @JsonKey(name: 'chronoLabel') required final String typeChrono,
      required final bool isEligibleToNationalRecord,
      @JsonKey(name: 'numberOfLanes') final int? numberOfLanes,
      @JsonKey(name: 'Organisme')
      required final CompetitionOrganismeDto organisme,
      required final bool hasBegun,
      @JsonKey(name: 'hasResultat') required final bool hasResult,
      required final bool hasPassed,
      @JsonKey(name: 'Niveau') required final int level,
      @JsonKey(name: 'niveauLabel') required final String levelLabel,
      @JsonKey(name: 'JugePrincipal')
      final String? refereePrincipal}) = _$CompetitionDtoImpl;

  factory _CompetitionDto.fromJson(Map<String, dynamic> json) =
      _$CompetitionDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'Debut')
  String? get beginDate;
  @override
  @JsonKey(name: 'Fin')
  String? get endDate;
  @override
  @JsonKey(name: 'DebutEngagement')
  String? get beginEntryLimitDate;
  @override
  @JsonKey(name: 'FinEngagement')
  String? get endEntryLimitDate;
  @override
  @JsonKey(name: 'Lieu')
  String? get location;
  @override
  @JsonKey(name: 'Statut')
  int get statusCode;
  @override
  @JsonKey(name: 'statutLabel')
  String get statusLabel;
  @override
  @JsonKey(name: 'Description')
  String? get description;
  @override
  @JsonKey(name: 'Specialite')
  int get speciality;
  @override
  @JsonKey(name: 'specialiteLabel')
  String get specialityLabel;
  @override
  @JsonKey(name: 'water')
  String get typeWater;
  @override
  @JsonKey(name: 'bassin')
  String get typePool;
  @override
  @JsonKey(name: 'chronoLabel')
  String get typeChrono;
  @override
  bool get isEligibleToNationalRecord;
  @override
  @JsonKey(name: 'numberOfLanes')
  int? get numberOfLanes;
  @override
  @JsonKey(name: 'Organisme')
  CompetitionOrganismeDto get organisme;
  @override
  bool get hasBegun;
  @override
  @JsonKey(name: 'hasResultat')
  bool get hasResult;
  @override
  bool get hasPassed;
  @override
  @JsonKey(name: 'Niveau')
  int get level;
  @override
  @JsonKey(name: 'niveauLabel')
  String get levelLabel;
  @override
  @JsonKey(name: 'JugePrincipal')
  String? get refereePrincipal;
  @override
  @JsonKey(ignore: true)
  _$$CompetitionDtoImplCopyWith<_$CompetitionDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompetitionOrganismeDto _$CompetitionOrganismeDtoFromJson(
    Map<String, dynamic> json) {
  return _CompetitionOrganismeDto.fromJson(json);
}

/// @nodoc
mixin _$CompetitionOrganismeDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomOrga')
  String get organizerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomCompletOrga')
  String? get clubFullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'NomCourt')
  String? get shortName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo')
  String? get logoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'bonnet')
  String? get capUrl => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompetitionOrganismeDtoCopyWith<CompetitionOrganismeDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompetitionOrganismeDtoCopyWith<$Res> {
  factory $CompetitionOrganismeDtoCopyWith(CompetitionOrganismeDto value,
          $Res Function(CompetitionOrganismeDto) then) =
      _$CompetitionOrganismeDtoCopyWithImpl<$Res, CompetitionOrganismeDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NomOrga') String organizerName,
      @JsonKey(name: 'NomCompletOrga') String? clubFullName,
      @JsonKey(name: 'NomCourt') String? shortName,
      @JsonKey(name: 'logo') String? logoUrl,
      @JsonKey(name: 'bonnet') String? capUrl});
}

/// @nodoc
class _$CompetitionOrganismeDtoCopyWithImpl<$Res,
        $Val extends CompetitionOrganismeDto>
    implements $CompetitionOrganismeDtoCopyWith<$Res> {
  _$CompetitionOrganismeDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizerName = null,
    Object? clubFullName = freezed,
    Object? shortName = freezed,
    Object? logoUrl = freezed,
    Object? capUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      organizerName: null == organizerName
          ? _value.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      clubFullName: freezed == clubFullName
          ? _value.clubFullName
          : clubFullName // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CompetitionOrganismeDtoImplCopyWith<$Res>
    implements $CompetitionOrganismeDtoCopyWith<$Res> {
  factory _$$CompetitionOrganismeDtoImplCopyWith(
          _$CompetitionOrganismeDtoImpl value,
          $Res Function(_$CompetitionOrganismeDtoImpl) then) =
      __$$CompetitionOrganismeDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'NomOrga') String organizerName,
      @JsonKey(name: 'NomCompletOrga') String? clubFullName,
      @JsonKey(name: 'NomCourt') String? shortName,
      @JsonKey(name: 'logo') String? logoUrl,
      @JsonKey(name: 'bonnet') String? capUrl});
}

/// @nodoc
class __$$CompetitionOrganismeDtoImplCopyWithImpl<$Res>
    extends _$CompetitionOrganismeDtoCopyWithImpl<$Res,
        _$CompetitionOrganismeDtoImpl>
    implements _$$CompetitionOrganismeDtoImplCopyWith<$Res> {
  __$$CompetitionOrganismeDtoImplCopyWithImpl(
      _$CompetitionOrganismeDtoImpl _value,
      $Res Function(_$CompetitionOrganismeDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? organizerName = null,
    Object? clubFullName = freezed,
    Object? shortName = freezed,
    Object? logoUrl = freezed,
    Object? capUrl = freezed,
  }) {
    return _then(_$CompetitionOrganismeDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      organizerName: null == organizerName
          ? _value.organizerName
          : organizerName // ignore: cast_nullable_to_non_nullable
              as String,
      clubFullName: freezed == clubFullName
          ? _value.clubFullName
          : clubFullName // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CompetitionOrganismeDtoImpl implements _CompetitionOrganismeDto {
  const _$CompetitionOrganismeDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'NomOrga') required this.organizerName,
      @JsonKey(name: 'NomCompletOrga') this.clubFullName,
      @JsonKey(name: 'NomCourt') this.shortName,
      @JsonKey(name: 'logo') this.logoUrl,
      @JsonKey(name: 'bonnet') this.capUrl});

  factory _$CompetitionOrganismeDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompetitionOrganismeDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'NomOrga')
  final String organizerName;
  @override
  @JsonKey(name: 'NomCompletOrga')
  final String? clubFullName;
  @override
  @JsonKey(name: 'NomCourt')
  final String? shortName;
  @override
  @JsonKey(name: 'logo')
  final String? logoUrl;
  @override
  @JsonKey(name: 'bonnet')
  final String? capUrl;

  @override
  String toString() {
    return 'CompetitionOrganismeDto(id: $id, organizerName: $organizerName, clubFullName: $clubFullName, shortName: $shortName, logoUrl: $logoUrl, capUrl: $capUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompetitionOrganismeDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.organizerName, organizerName) ||
                other.organizerName == organizerName) &&
            (identical(other.clubFullName, clubFullName) ||
                other.clubFullName == clubFullName) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.capUrl, capUrl) || other.capUrl == capUrl));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, organizerName, clubFullName, shortName, logoUrl, capUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompetitionOrganismeDtoImplCopyWith<_$CompetitionOrganismeDtoImpl>
      get copyWith => __$$CompetitionOrganismeDtoImplCopyWithImpl<
          _$CompetitionOrganismeDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompetitionOrganismeDtoImplToJson(
      this,
    );
  }
}

abstract class _CompetitionOrganismeDto implements CompetitionOrganismeDto {
  const factory _CompetitionOrganismeDto(
          {@JsonKey(name: 'Id') required final int id,
          @JsonKey(name: 'NomOrga') required final String organizerName,
          @JsonKey(name: 'NomCompletOrga') final String? clubFullName,
          @JsonKey(name: 'NomCourt') final String? shortName,
          @JsonKey(name: 'logo') final String? logoUrl,
          @JsonKey(name: 'bonnet') final String? capUrl}) =
      _$CompetitionOrganismeDtoImpl;

  factory _CompetitionOrganismeDto.fromJson(Map<String, dynamic> json) =
      _$CompetitionOrganismeDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'NomOrga')
  String get organizerName;
  @override
  @JsonKey(name: 'NomCompletOrga')
  String? get clubFullName;
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
  @JsonKey(ignore: true)
  _$$CompetitionOrganismeDtoImplCopyWith<_$CompetitionOrganismeDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
