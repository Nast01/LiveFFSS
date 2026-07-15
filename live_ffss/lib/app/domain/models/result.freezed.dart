// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Result _$ResultFromJson(Map<String, dynamic> json) {
  return _Result.fromJson(json);
}

/// @nodoc
mixin _$Result {
  String get id => throw _privateConstructorUsedError;
  bool get isValid => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;
  String get statusLabel => throw _privateConstructorUsedError;
  bool get isDisqualified => throw _privateConstructorUsedError;
  int get rank => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  String get timeLabel => throw _privateConstructorUsedError;
  String? get complement => throw _privateConstructorUsedError;
  String? get complementLabel => throw _privateConstructorUsedError;
  String get disqualificationCode => throw _privateConstructorUsedError;
  String get disqualificationReason => throw _privateConstructorUsedError;
  Heat? get heat => throw _privateConstructorUsedError;
  Entry? get entry => throw _privateConstructorUsedError;
  List<Athlete> get athletes => throw _privateConstructorUsedError;
  bool get isRecord => throw _privateConstructorUsedError;
  bool get isBestPerformance => throw _privateConstructorUsedError;
  bool get isFranceRecord => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get liveTime1 => throw _privateConstructorUsedError;
  int get liveTime2 => throw _privateConstructorUsedError;
  int get liveTime3 => throw _privateConstructorUsedError;

  /// Serializes this Result to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResultCopyWith<Result> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResultCopyWith<$Res> {
  factory $ResultCopyWith(Result value, $Res Function(Result) then) =
      _$ResultCopyWithImpl<$Res, Result>;
  @useResult
  $Res call(
      {String id,
      bool isValid,
      int status,
      String statusLabel,
      bool isDisqualified,
      int rank,
      int time,
      String timeLabel,
      String? complement,
      String? complementLabel,
      String disqualificationCode,
      String disqualificationReason,
      Heat? heat,
      Entry? entry,
      List<Athlete> athletes,
      bool isRecord,
      bool isBestPerformance,
      bool isFranceRecord,
      int points,
      int liveTime1,
      int liveTime2,
      int liveTime3});

  $HeatCopyWith<$Res>? get heat;
  $EntryCopyWith<$Res>? get entry;
}

/// @nodoc
class _$ResultCopyWithImpl<$Res, $Val extends Result>
    implements $ResultCopyWith<$Res> {
  _$ResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Result
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
              as Heat?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as Entry?,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
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

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HeatCopyWith<$Res>? get heat {
    if (_value.heat == null) {
      return null;
    }

    return $HeatCopyWith<$Res>(_value.heat!, (value) {
      return _then(_value.copyWith(heat: value) as $Val);
    });
  }

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EntryCopyWith<$Res>? get entry {
    if (_value.entry == null) {
      return null;
    }

    return $EntryCopyWith<$Res>(_value.entry!, (value) {
      return _then(_value.copyWith(entry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ResultImplCopyWith<$Res> implements $ResultCopyWith<$Res> {
  factory _$$ResultImplCopyWith(
          _$ResultImpl value, $Res Function(_$ResultImpl) then) =
      __$$ResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      bool isValid,
      int status,
      String statusLabel,
      bool isDisqualified,
      int rank,
      int time,
      String timeLabel,
      String? complement,
      String? complementLabel,
      String disqualificationCode,
      String disqualificationReason,
      Heat? heat,
      Entry? entry,
      List<Athlete> athletes,
      bool isRecord,
      bool isBestPerformance,
      bool isFranceRecord,
      int points,
      int liveTime1,
      int liveTime2,
      int liveTime3});

  @override
  $HeatCopyWith<$Res>? get heat;
  @override
  $EntryCopyWith<$Res>? get entry;
}

/// @nodoc
class __$$ResultImplCopyWithImpl<$Res>
    extends _$ResultCopyWithImpl<$Res, _$ResultImpl>
    implements _$$ResultImplCopyWith<$Res> {
  __$$ResultImplCopyWithImpl(
      _$ResultImpl _value, $Res Function(_$ResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of Result
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
    return _then(_$ResultImpl(
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
              as Heat?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as Entry?,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<Athlete>,
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
class _$ResultImpl implements _Result {
  const _$ResultImpl(
      {required this.id,
      required this.isValid,
      required this.status,
      required this.statusLabel,
      this.isDisqualified = false,
      required this.rank,
      required this.time,
      required this.timeLabel,
      this.complement,
      this.complementLabel,
      this.disqualificationCode = '',
      this.disqualificationReason = '',
      this.heat,
      this.entry,
      final List<Athlete> athletes = const <Athlete>[],
      this.isRecord = false,
      this.isBestPerformance = false,
      this.isFranceRecord = false,
      this.points = 0,
      this.liveTime1 = 0,
      this.liveTime2 = 0,
      this.liveTime3 = 0})
      : _athletes = athletes;

  factory _$ResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResultImplFromJson(json);

  @override
  final String id;
  @override
  final bool isValid;
  @override
  final int status;
  @override
  final String statusLabel;
  @override
  @JsonKey()
  final bool isDisqualified;
  @override
  final int rank;
  @override
  final int time;
  @override
  final String timeLabel;
  @override
  final String? complement;
  @override
  final String? complementLabel;
  @override
  @JsonKey()
  final String disqualificationCode;
  @override
  @JsonKey()
  final String disqualificationReason;
  @override
  final Heat? heat;
  @override
  final Entry? entry;
  final List<Athlete> _athletes;
  @override
  @JsonKey()
  List<Athlete> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  @override
  @JsonKey()
  final bool isRecord;
  @override
  @JsonKey()
  final bool isBestPerformance;
  @override
  @JsonKey()
  final bool isFranceRecord;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int liveTime1;
  @override
  @JsonKey()
  final int liveTime2;
  @override
  @JsonKey()
  final int liveTime3;

  @override
  String toString() {
    return 'Result(id: $id, isValid: $isValid, status: $status, statusLabel: $statusLabel, isDisqualified: $isDisqualified, rank: $rank, time: $time, timeLabel: $timeLabel, complement: $complement, complementLabel: $complementLabel, disqualificationCode: $disqualificationCode, disqualificationReason: $disqualificationReason, heat: $heat, entry: $entry, athletes: $athletes, isRecord: $isRecord, isBestPerformance: $isBestPerformance, isFranceRecord: $isFranceRecord, points: $points, liveTime1: $liveTime1, liveTime2: $liveTime2, liveTime3: $liveTime3)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResultImpl &&
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

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      __$$ResultImplCopyWithImpl<_$ResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResultImplToJson(
      this,
    );
  }
}

abstract class _Result implements Result {
  const factory _Result(
      {required final String id,
      required final bool isValid,
      required final int status,
      required final String statusLabel,
      final bool isDisqualified,
      required final int rank,
      required final int time,
      required final String timeLabel,
      final String? complement,
      final String? complementLabel,
      final String disqualificationCode,
      final String disqualificationReason,
      final Heat? heat,
      final Entry? entry,
      final List<Athlete> athletes,
      final bool isRecord,
      final bool isBestPerformance,
      final bool isFranceRecord,
      final int points,
      final int liveTime1,
      final int liveTime2,
      final int liveTime3}) = _$ResultImpl;

  factory _Result.fromJson(Map<String, dynamic> json) = _$ResultImpl.fromJson;

  @override
  String get id;
  @override
  bool get isValid;
  @override
  int get status;
  @override
  String get statusLabel;
  @override
  bool get isDisqualified;
  @override
  int get rank;
  @override
  int get time;
  @override
  String get timeLabel;
  @override
  String? get complement;
  @override
  String? get complementLabel;
  @override
  String get disqualificationCode;
  @override
  String get disqualificationReason;
  @override
  Heat? get heat;
  @override
  Entry? get entry;
  @override
  List<Athlete> get athletes;
  @override
  bool get isRecord;
  @override
  bool get isBestPerformance;
  @override
  bool get isFranceRecord;
  @override
  int get points;
  @override
  int get liveTime1;
  @override
  int get liveTime2;
  @override
  int get liveTime3;

  /// Create a copy of Result
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResultImplCopyWith<_$ResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
