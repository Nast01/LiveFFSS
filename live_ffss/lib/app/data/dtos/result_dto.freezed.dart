// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResultDto _$ResultDtoFromJson(Map<String, dynamic> json) {
  return _ResultDto.fromJson(json);
}

/// @nodoc
mixin _$ResultDto {
  @JsonKey(name: 'Id', readValue: _readId)
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'isValid')
  bool get isValid => throw _privateConstructorUsedError;
  @JsonKey(name: 'Statut')
  int get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'statutLabel')
  String get statusLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'isDisqualifie')
  bool get isDisqualified => throw _privateConstructorUsedError;
  @JsonKey(name: 'Rang')
  int get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'Temps')
  int get time => throw _privateConstructorUsedError;
  @JsonKey(name: 'tempsLabel')
  String get timeLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'complement')
  String? get complement => throw _privateConstructorUsedError;
  @JsonKey(name: 'complementLabel')
  String? get complementLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'CodeDisqualification')
  String get disqualificationCode => throw _privateConstructorUsedError;
  @JsonKey(
      name: 'disqualificationReason', readValue: _readDisqualificationReason)
  String get disqualificationReason => throw _privateConstructorUsedError;
  @JsonKey(name: 'serie')
  HeatDto? get heat => throw _privateConstructorUsedError;
  @JsonKey(name: 'engagement')
  EntryDto? get entry => throw _privateConstructorUsedError;
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRecord')
  bool get isRecord => throw _privateConstructorUsedError;
  @JsonKey(name: 'isMeilleurPerformance')
  bool get isBestPerformance => throw _privateConstructorUsedError;
  @JsonKey(name: 'isRecordDeFrance')
  bool get isFranceRecord => throw _privateConstructorUsedError;
  @JsonKey(name: 'points')
  int get points => throw _privateConstructorUsedError;
  @JsonKey(name: 'TempsLive1')
  int get liveTime1 => throw _privateConstructorUsedError;
  @JsonKey(name: 'TempsLive2')
  int get liveTime2 => throw _privateConstructorUsedError;
  @JsonKey(name: 'TempsLive3')
  int get liveTime3 => throw _privateConstructorUsedError;

  /// Serializes this ResultDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultDtoCopyWith<ResultDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultDtoCopyWith<$Res> {
  factory $ResultDtoCopyWith(ResultDto value, $Res Function(ResultDto) then) =
      _$ResultDtoCopyWithImpl<$Res, ResultDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id', readValue: _readId) String id,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'isDisqualifie') bool isDisqualified,
      @JsonKey(name: 'Rang') int rank,
      @JsonKey(name: 'Temps') int time,
      @JsonKey(name: 'tempsLabel') String timeLabel,
      @JsonKey(name: 'complement') String? complement,
      @JsonKey(name: 'complementLabel') String? complementLabel,
      @JsonKey(name: 'CodeDisqualification') String disqualificationCode,
      @JsonKey(
          name: 'disqualificationReason',
          readValue: _readDisqualificationReason)
      String disqualificationReason,
      @JsonKey(name: 'serie') HeatDto? heat,
      @JsonKey(name: 'engagement') EntryDto? entry,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes,
      @JsonKey(name: 'isRecord') bool isRecord,
      @JsonKey(name: 'isMeilleurPerformance') bool isBestPerformance,
      @JsonKey(name: 'isRecordDeFrance') bool isFranceRecord,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'TempsLive1') int liveTime1,
      @JsonKey(name: 'TempsLive2') int liveTime2,
      @JsonKey(name: 'TempsLive3') int liveTime3});

  $HeatDtoCopyWith<$Res>? get heat;
  $EntryDtoCopyWith<$Res>? get entry;
}

/// @nodoc
class _$ResultDtoCopyWithImpl<$Res, $Val extends ResultDto>
    implements $ResultDtoCopyWith<$Res> {
  _$ResultDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isValid = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? isDisqualified = null,
    Object? rank = null,
    Object? time = null,
    Object? timeLabel = null,
    Object? complement = freezed,
    Object? complementLabel = freezed,
    Object? disqualificationCode = null,
    Object? disqualificationReason = null,
    Object? heat = freezed,
    Object? entry = freezed,
    Object? athletes = null,
    Object? isRecord = null,
    Object? isBestPerformance = null,
    Object? isFranceRecord = null,
    Object? points = null,
    Object? liveTime1 = null,
    Object? liveTime2 = null,
    Object? liveTime3 = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isDisqualified: null == isDisqualified
          ? _value.isDisqualified
          : isDisqualified // ignore: cast_nullable_to_non_nullable
              as bool,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      timeLabel: null == timeLabel
          ? _value.timeLabel
          : timeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      complementLabel: freezed == complementLabel
          ? _value.complementLabel
          : complementLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      disqualificationCode: null == disqualificationCode
          ? _value.disqualificationCode
          : disqualificationCode // ignore: cast_nullable_to_non_nullable
              as String,
      disqualificationReason: null == disqualificationReason
          ? _value.disqualificationReason
          : disqualificationReason // ignore: cast_nullable_to_non_nullable
              as String,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as HeatDto?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as EntryDto?,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
      isRecord: null == isRecord
          ? _value.isRecord
          : isRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isBestPerformance: null == isBestPerformance
          ? _value.isBestPerformance
          : isBestPerformance // ignore: cast_nullable_to_non_nullable
              as bool,
      isFranceRecord: null == isFranceRecord
          ? _value.isFranceRecord
          : isFranceRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime1: null == liveTime1
          ? _value.liveTime1
          : liveTime1 // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime2: null == liveTime2
          ? _value.liveTime2
          : liveTime2 // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime3: null == liveTime3
          ? _value.liveTime3
          : liveTime3 // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HeatDtoCopyWith<$Res>? get heat {
    if (_value.heat == null) {
      return null;
    }

    return $HeatDtoCopyWith<$Res>(_value.heat!, (value) {
      return _then(_value.copyWith(heat: value) as $Val);
    });
  }

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EntryDtoCopyWith<$Res>? get entry {
    if (_value.entry == null) {
      return null;
    }

    return $EntryDtoCopyWith<$Res>(_value.entry!, (value) {
      return _then(_value.copyWith(entry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResultDtoImplCopyWith<$Res>
    implements $ResultDtoCopyWith<$Res> {
  factory _$$ResultDtoImplCopyWith(
          _$ResultDtoImpl value, $Res Function(_$ResultDtoImpl) then) =
      __$$ResultDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id', readValue: _readId) String id,
      @JsonKey(name: 'isValid') bool isValid,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'isDisqualifie') bool isDisqualified,
      @JsonKey(name: 'Rang') int rank,
      @JsonKey(name: 'Temps') int time,
      @JsonKey(name: 'tempsLabel') String timeLabel,
      @JsonKey(name: 'complement') String? complement,
      @JsonKey(name: 'complementLabel') String? complementLabel,
      @JsonKey(name: 'CodeDisqualification') String disqualificationCode,
      @JsonKey(
          name: 'disqualificationReason',
          readValue: _readDisqualificationReason)
      String disqualificationReason,
      @JsonKey(name: 'serie') HeatDto? heat,
      @JsonKey(name: 'engagement') EntryDto? entry,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes,
      @JsonKey(name: 'isRecord') bool isRecord,
      @JsonKey(name: 'isMeilleurPerformance') bool isBestPerformance,
      @JsonKey(name: 'isRecordDeFrance') bool isFranceRecord,
      @JsonKey(name: 'points') int points,
      @JsonKey(name: 'TempsLive1') int liveTime1,
      @JsonKey(name: 'TempsLive2') int liveTime2,
      @JsonKey(name: 'TempsLive3') int liveTime3});

  @override
  $HeatDtoCopyWith<$Res>? get heat;
  @override
  $EntryDtoCopyWith<$Res>? get entry;
}

/// @nodoc
class __$$ResultDtoImplCopyWithImpl<$Res>
    extends _$ResultDtoCopyWithImpl<$Res, _$ResultDtoImpl>
    implements _$$ResultDtoImplCopyWith<$Res> {
  __$$ResultDtoImplCopyWithImpl(
      _$ResultDtoImpl _value, $Res Function(_$ResultDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? isValid = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? isDisqualified = null,
    Object? rank = null,
    Object? time = null,
    Object? timeLabel = null,
    Object? complement = freezed,
    Object? complementLabel = freezed,
    Object? disqualificationCode = null,
    Object? disqualificationReason = null,
    Object? heat = freezed,
    Object? entry = freezed,
    Object? athletes = null,
    Object? isRecord = null,
    Object? isBestPerformance = null,
    Object? isFranceRecord = null,
    Object? points = null,
    Object? liveTime1 = null,
    Object? liveTime2 = null,
    Object? liveTime3 = null,
  }) {
    return _then(_$ResultDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      isValid: null == isValid
          ? _value.isValid
          : isValid // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      isDisqualified: null == isDisqualified
          ? _value.isDisqualified
          : isDisqualified // ignore: cast_nullable_to_non_nullable
              as bool,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      timeLabel: null == timeLabel
          ? _value.timeLabel
          : timeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      complementLabel: freezed == complementLabel
          ? _value.complementLabel
          : complementLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      disqualificationCode: null == disqualificationCode
          ? _value.disqualificationCode
          : disqualificationCode // ignore: cast_nullable_to_non_nullable
              as String,
      disqualificationReason: null == disqualificationReason
          ? _value.disqualificationReason
          : disqualificationReason // ignore: cast_nullable_to_non_nullable
              as String,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as HeatDto?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as EntryDto?,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
      isRecord: null == isRecord
          ? _value.isRecord
          : isRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      isBestPerformance: null == isBestPerformance
          ? _value.isBestPerformance
          : isBestPerformance // ignore: cast_nullable_to_non_nullable
              as bool,
      isFranceRecord: null == isFranceRecord
          ? _value.isFranceRecord
          : isFranceRecord // ignore: cast_nullable_to_non_nullable
              as bool,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime1: null == liveTime1
          ? _value.liveTime1
          : liveTime1 // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime2: null == liveTime2
          ? _value.liveTime2
          : liveTime2 // ignore: cast_nullable_to_non_nullable
              as int,
      liveTime3: null == liveTime3
          ? _value.liveTime3
          : liveTime3 // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResultDtoImpl implements _ResultDto {
  const _$ResultDtoImpl(
      {@JsonKey(name: 'Id', readValue: _readId) this.id = '',
      @JsonKey(name: 'isValid') this.isValid = false,
      @JsonKey(name: 'Statut') this.status = 0,
      @JsonKey(name: 'statutLabel') this.statusLabel = '',
      @JsonKey(name: 'isDisqualifie') this.isDisqualified = false,
      @JsonKey(name: 'Rang') this.rank = 0,
      @JsonKey(name: 'Temps') this.time = 0,
      @JsonKey(name: 'tempsLabel') this.timeLabel = '',
      @JsonKey(name: 'complement') this.complement,
      @JsonKey(name: 'complementLabel') this.complementLabel,
      @JsonKey(name: 'CodeDisqualification') this.disqualificationCode = '',
      @JsonKey(
          name: 'disqualificationReason',
          readValue: _readDisqualificationReason)
      this.disqualificationReason = '',
      @JsonKey(name: 'serie') this.heat,
      @JsonKey(name: 'engagement') this.entry,
      @JsonKey(name: 'athletes')
      final List<AthleteDto> athletes = const <AthleteDto>[],
      @JsonKey(name: 'isRecord') this.isRecord = false,
      @JsonKey(name: 'isMeilleurPerformance') this.isBestPerformance = false,
      @JsonKey(name: 'isRecordDeFrance') this.isFranceRecord = false,
      @JsonKey(name: 'points') this.points = 0,
      @JsonKey(name: 'TempsLive1') this.liveTime1 = 0,
      @JsonKey(name: 'TempsLive2') this.liveTime2 = 0,
      @JsonKey(name: 'TempsLive3') this.liveTime3 = 0})
      : _athletes = athletes;

  factory _$ResultDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id', readValue: _readId)
  final String id;
  @override
  @JsonKey(name: 'isValid')
  final bool isValid;
  @override
  @JsonKey(name: 'Statut')
  final int status;
  @override
  @JsonKey(name: 'statutLabel')
  final String statusLabel;
  @override
  @JsonKey(name: 'isDisqualifie')
  final bool isDisqualified;
  @override
  @JsonKey(name: 'Rang')
  final int rank;
  @override
  @JsonKey(name: 'Temps')
  final int time;
  @override
  @JsonKey(name: 'tempsLabel')
  final String timeLabel;
  @override
  @JsonKey(name: 'complement')
  final String? complement;
  @override
  @JsonKey(name: 'complementLabel')
  final String? complementLabel;
  @override
  @JsonKey(name: 'CodeDisqualification')
  final String disqualificationCode;
  @override
  @JsonKey(
      name: 'disqualificationReason', readValue: _readDisqualificationReason)
  final String disqualificationReason;
  @override
  @JsonKey(name: 'serie')
  final HeatDto? heat;
  @override
  @JsonKey(name: 'engagement')
  final EntryDto? entry;
  final List<AthleteDto> _athletes;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  @override
  @JsonKey(name: 'isRecord')
  final bool isRecord;
  @override
  @JsonKey(name: 'isMeilleurPerformance')
  final bool isBestPerformance;
  @override
  @JsonKey(name: 'isRecordDeFrance')
  final bool isFranceRecord;
  @override
  @JsonKey(name: 'points')
  final int points;
  @override
  @JsonKey(name: 'TempsLive1')
  final int liveTime1;
  @override
  @JsonKey(name: 'TempsLive2')
  final int liveTime2;
  @override
  @JsonKey(name: 'TempsLive3')
  final int liveTime3;

  @override
  String toString() {
    return 'ResultDto(id: $id, isValid: $isValid, status: $status, statusLabel: $statusLabel, isDisqualified: $isDisqualified, rank: $rank, time: $time, timeLabel: $timeLabel, complement: $complement, complementLabel: $complementLabel, disqualificationCode: $disqualificationCode, disqualificationReason: $disqualificationReason, heat: $heat, entry: $entry, athletes: $athletes, isRecord: $isRecord, isBestPerformance: $isBestPerformance, isFranceRecord: $isFranceRecord, points: $points, liveTime1: $liveTime1, liveTime2: $liveTime2, liveTime3: $liveTime3)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.isValid, isValid) || other.isValid == isValid) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.isDisqualified, isDisqualified) ||
                other.isDisqualified == isDisqualified) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.timeLabel, timeLabel) ||
                other.timeLabel == timeLabel) &&
            (identical(other.complement, complement) ||
                other.complement == complement) &&
            (identical(other.complementLabel, complementLabel) ||
                other.complementLabel == complementLabel) &&
            (identical(other.disqualificationCode, disqualificationCode) ||
                other.disqualificationCode == disqualificationCode) &&
            (identical(other.disqualificationReason, disqualificationReason) ||
                other.disqualificationReason == disqualificationReason) &&
            (identical(other.heat, heat) || other.heat == heat) &&
            (identical(other.entry, entry) || other.entry == entry) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes) &&
            (identical(other.isRecord, isRecord) ||
                other.isRecord == isRecord) &&
            (identical(other.isBestPerformance, isBestPerformance) ||
                other.isBestPerformance == isBestPerformance) &&
            (identical(other.isFranceRecord, isFranceRecord) ||
                other.isFranceRecord == isFranceRecord) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.liveTime1, liveTime1) ||
                other.liveTime1 == liveTime1) &&
            (identical(other.liveTime2, liveTime2) ||
                other.liveTime2 == liveTime2) &&
            (identical(other.liveTime3, liveTime3) ||
                other.liveTime3 == liveTime3));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        isValid,
        status,
        statusLabel,
        isDisqualified,
        rank,
        time,
        timeLabel,
        complement,
        complementLabel,
        disqualificationCode,
        disqualificationReason,
        heat,
        entry,
        const DeepCollectionEquality().hash(_athletes),
        isRecord,
        isBestPerformance,
        isFranceRecord,
        points,
        liveTime1,
        liveTime2,
        liveTime3
      ]);

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultDtoImplCopyWith<_$ResultDtoImpl> get copyWith =>
      __$$ResultDtoImplCopyWithImpl<_$ResultDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultDtoImplToJson(
      this,
    );
  }
}

abstract class _ResultDto implements ResultDto {
  const factory _ResultDto(
      {@JsonKey(name: 'Id', readValue: _readId) final String id,
      @JsonKey(name: 'isValid') final bool isValid,
      @JsonKey(name: 'Statut') final int status,
      @JsonKey(name: 'statutLabel') final String statusLabel,
      @JsonKey(name: 'isDisqualifie') final bool isDisqualified,
      @JsonKey(name: 'Rang') final int rank,
      @JsonKey(name: 'Temps') final int time,
      @JsonKey(name: 'tempsLabel') final String timeLabel,
      @JsonKey(name: 'complement') final String? complement,
      @JsonKey(name: 'complementLabel') final String? complementLabel,
      @JsonKey(name: 'CodeDisqualification') final String disqualificationCode,
      @JsonKey(
          name: 'disqualificationReason',
          readValue: _readDisqualificationReason)
      final String disqualificationReason,
      @JsonKey(name: 'serie') final HeatDto? heat,
      @JsonKey(name: 'engagement') final EntryDto? entry,
      @JsonKey(name: 'athletes') final List<AthleteDto> athletes,
      @JsonKey(name: 'isRecord') final bool isRecord,
      @JsonKey(name: 'isMeilleurPerformance') final bool isBestPerformance,
      @JsonKey(name: 'isRecordDeFrance') final bool isFranceRecord,
      @JsonKey(name: 'points') final int points,
      @JsonKey(name: 'TempsLive1') final int liveTime1,
      @JsonKey(name: 'TempsLive2') final int liveTime2,
      @JsonKey(name: 'TempsLive3') final int liveTime3}) = _$ResultDtoImpl;

  factory _ResultDto.fromJson(Map<String, dynamic> json) =
      _$ResultDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id', readValue: _readId)
  String get id;
  @override
  @JsonKey(name: 'isValid')
  bool get isValid;
  @override
  @JsonKey(name: 'Statut')
  int get status;
  @override
  @JsonKey(name: 'statutLabel')
  String get statusLabel;
  @override
  @JsonKey(name: 'isDisqualifie')
  bool get isDisqualified;
  @override
  @JsonKey(name: 'Rang')
  int get rank;
  @override
  @JsonKey(name: 'Temps')
  int get time;
  @override
  @JsonKey(name: 'tempsLabel')
  String get timeLabel;
  @override
  @JsonKey(name: 'complement')
  String? get complement;
  @override
  @JsonKey(name: 'complementLabel')
  String? get complementLabel;
  @override
  @JsonKey(name: 'CodeDisqualification')
  String get disqualificationCode;
  @override
  @JsonKey(
      name: 'disqualificationReason', readValue: _readDisqualificationReason)
  String get disqualificationReason;
  @override
  @JsonKey(name: 'serie')
  HeatDto? get heat;
  @override
  @JsonKey(name: 'engagement')
  EntryDto? get entry;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes;
  @override
  @JsonKey(name: 'isRecord')
  bool get isRecord;
  @override
  @JsonKey(name: 'isMeilleurPerformance')
  bool get isBestPerformance;
  @override
  @JsonKey(name: 'isRecordDeFrance')
  bool get isFranceRecord;
  @override
  @JsonKey(name: 'points')
  int get points;
  @override
  @JsonKey(name: 'TempsLive1')
  int get liveTime1;
  @override
  @JsonKey(name: 'TempsLive2')
  int get liveTime2;
  @override
  @JsonKey(name: 'TempsLive3')
  int get liveTime3;

  /// Create a copy of ResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultDtoImplCopyWith<_$ResultDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
