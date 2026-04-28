// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Run _$RunFromJson(Map<String, dynamic> json) {
  return _Run.fromJson(json);
}

/// @nodoc
mixin _$Run {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get fullLabel => throw _privateConstructorUsedError;
  RunStatus get status => throw _privateConstructorUsedError;
  String get statusLabel => throw _privateConstructorUsedError;
  String get site => throw _privateConstructorUsedError;
  DateTime get beginTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  Heat? get heat => throw _privateConstructorUsedError;
  List<LiveResult> get liveResults => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RunCopyWith<Run> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunCopyWith<$Res> {
  factory $RunCopyWith(Run value, $Res Function(Run) then) =
      _$RunCopyWithImpl<$Res, Run>;
  @useResult
  $Res call(
      {int id,
      String name,
      String label,
      String fullLabel,
      RunStatus status,
      String statusLabel,
      String site,
      DateTime beginTime,
      DateTime endTime,
      Heat? heat,
      List<LiveResult> liveResults});

  $HeatCopyWith<$Res>? get heat;
}

/// @nodoc
class _$RunCopyWithImpl<$Res, $Val extends Run> implements $RunCopyWith<$Res> {
  _$RunCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? site = null,
    Object? beginTime = null,
    Object? endTime = null,
    Object? heat = freezed,
    Object? liveResults = null,
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
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RunStatus,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      site: null == site
          ? _value.site
          : site // ignore: cast_nullable_to_non_nullable
              as String,
      beginTime: null == beginTime
          ? _value.beginTime
          : beginTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as Heat?,
      liveResults: null == liveResults
          ? _value.liveResults
          : liveResults // ignore: cast_nullable_to_non_nullable
              as List<LiveResult>,
    ) as $Val);
  }

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
}

/// @nodoc
abstract class _$$RunImplCopyWith<$Res> implements $RunCopyWith<$Res> {
  factory _$$RunImplCopyWith(_$RunImpl value, $Res Function(_$RunImpl) then) =
      __$$RunImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String label,
      String fullLabel,
      RunStatus status,
      String statusLabel,
      String site,
      DateTime beginTime,
      DateTime endTime,
      Heat? heat,
      List<LiveResult> liveResults});

  @override
  $HeatCopyWith<$Res>? get heat;
}

/// @nodoc
class __$$RunImplCopyWithImpl<$Res> extends _$RunCopyWithImpl<$Res, _$RunImpl>
    implements _$$RunImplCopyWith<$Res> {
  __$$RunImplCopyWithImpl(_$RunImpl _value, $Res Function(_$RunImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? site = null,
    Object? beginTime = null,
    Object? endTime = null,
    Object? heat = freezed,
    Object? liveResults = null,
  }) {
    return _then(_$RunImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RunStatus,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      site: null == site
          ? _value.site
          : site // ignore: cast_nullable_to_non_nullable
              as String,
      beginTime: null == beginTime
          ? _value.beginTime
          : beginTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as Heat?,
      liveResults: null == liveResults
          ? _value._liveResults
          : liveResults // ignore: cast_nullable_to_non_nullable
              as List<LiveResult>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RunImpl implements _Run {
  const _$RunImpl(
      {required this.id,
      required this.name,
      required this.label,
      required this.fullLabel,
      required this.status,
      required this.statusLabel,
      required this.site,
      required this.beginTime,
      required this.endTime,
      this.heat,
      final List<LiveResult> liveResults = const <LiveResult>[]})
      : _liveResults = liveResults;

  factory _$RunImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String label;
  @override
  final String fullLabel;
  @override
  final RunStatus status;
  @override
  final String statusLabel;
  @override
  final String site;
  @override
  final DateTime beginTime;
  @override
  final DateTime endTime;
  @override
  final Heat? heat;
  final List<LiveResult> _liveResults;
  @override
  @JsonKey()
  List<LiveResult> get liveResults {
    if (_liveResults is EqualUnmodifiableListView) return _liveResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_liveResults);
  }

  @override
  String toString() {
    return 'Run(id: $id, name: $name, label: $label, fullLabel: $fullLabel, status: $status, statusLabel: $statusLabel, site: $site, beginTime: $beginTime, endTime: $endTime, heat: $heat, liveResults: $liveResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullLabel, fullLabel) ||
                other.fullLabel == fullLabel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.site, site) || other.site == site) &&
            (identical(other.beginTime, beginTime) ||
                other.beginTime == beginTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.heat, heat) || other.heat == heat) &&
            const DeepCollectionEquality()
                .equals(other._liveResults, _liveResults));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      label,
      fullLabel,
      status,
      statusLabel,
      site,
      beginTime,
      endTime,
      heat,
      const DeepCollectionEquality().hash(_liveResults));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RunImplCopyWith<_$RunImpl> get copyWith =>
      __$$RunImplCopyWithImpl<_$RunImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunImplToJson(
      this,
    );
  }
}

abstract class _Run implements Run {
  const factory _Run(
      {required final int id,
      required final String name,
      required final String label,
      required final String fullLabel,
      required final RunStatus status,
      required final String statusLabel,
      required final String site,
      required final DateTime beginTime,
      required final DateTime endTime,
      final Heat? heat,
      final List<LiveResult> liveResults}) = _$RunImpl;

  factory _Run.fromJson(Map<String, dynamic> json) = _$RunImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get label;
  @override
  String get fullLabel;
  @override
  RunStatus get status;
  @override
  String get statusLabel;
  @override
  String get site;
  @override
  DateTime get beginTime;
  @override
  DateTime get endTime;
  @override
  Heat? get heat;
  @override
  List<LiveResult> get liveResults;
  @override
  @JsonKey(ignore: true)
  _$$RunImplCopyWith<_$RunImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
