// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RunDto _$RunDtoFromJson(Map<String, dynamic> json) {
  return _RunDto.fromJson(json);
}

/// @nodoc
mixin _$RunDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'fullLabel')
  String get fullLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'statut')
  int get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'statutLabel')
  String get statusLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'site')
  String get site => throw _privateConstructorUsedError;
  @JsonKey(name: 'debut')
  String get beginTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'fin')
  String get endTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'serie')
  HeatDto? get heat => throw _privateConstructorUsedError;
  @JsonKey(name: 'liveResults')
  List<LiveResultDto> get liveResults => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RunDtoCopyWith<RunDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RunDtoCopyWith<$Res> {
  factory $RunDtoCopyWith(RunDto value, $Res Function(RunDto) then) =
      _$RunDtoCopyWithImpl<$Res, RunDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'site') String site,
      @JsonKey(name: 'debut') String beginTime,
      @JsonKey(name: 'fin') String endTime,
      @JsonKey(name: 'serie') HeatDto? heat,
      @JsonKey(name: 'liveResults') List<LiveResultDto> liveResults});

  $HeatDtoCopyWith<$Res>? get heat;
}

/// @nodoc
class _$RunDtoCopyWithImpl<$Res, $Val extends RunDto>
    implements $RunDtoCopyWith<$Res> {
  _$RunDtoCopyWithImpl(this._value, this._then);

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
              as int,
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
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as HeatDto?,
      liveResults: null == liveResults
          ? _value.liveResults
          : liveResults // ignore: cast_nullable_to_non_nullable
              as List<LiveResultDto>,
    ) as $Val);
  }

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
}

/// @nodoc
abstract class _$$RunDtoImplCopyWith<$Res> implements $RunDtoCopyWith<$Res> {
  factory _$$RunDtoImplCopyWith(
          _$RunDtoImpl value, $Res Function(_$RunDtoImpl) then) =
      __$$RunDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'fullLabel') String fullLabel,
      @JsonKey(name: 'statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'site') String site,
      @JsonKey(name: 'debut') String beginTime,
      @JsonKey(name: 'fin') String endTime,
      @JsonKey(name: 'serie') HeatDto? heat,
      @JsonKey(name: 'liveResults') List<LiveResultDto> liveResults});

  @override
  $HeatDtoCopyWith<$Res>? get heat;
}

/// @nodoc
class __$$RunDtoImplCopyWithImpl<$Res>
    extends _$RunDtoCopyWithImpl<$Res, _$RunDtoImpl>
    implements _$$RunDtoImplCopyWith<$Res> {
  __$$RunDtoImplCopyWithImpl(
      _$RunDtoImpl _value, $Res Function(_$RunDtoImpl) _then)
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
    return _then(_$RunDtoImpl(
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
              as int,
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
              as String,
      endTime: null == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as String,
      heat: freezed == heat
          ? _value.heat
          : heat // ignore: cast_nullable_to_non_nullable
              as HeatDto?,
      liveResults: null == liveResults
          ? _value._liveResults
          : liveResults // ignore: cast_nullable_to_non_nullable
              as List<LiveResultDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RunDtoImpl implements _RunDto {
  const _$RunDtoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'label') required this.label,
      @JsonKey(name: 'fullLabel') required this.fullLabel,
      @JsonKey(name: 'statut') required this.status,
      @JsonKey(name: 'statutLabel') required this.statusLabel,
      @JsonKey(name: 'site') required this.site,
      @JsonKey(name: 'debut') required this.beginTime,
      @JsonKey(name: 'fin') required this.endTime,
      @JsonKey(name: 'serie') this.heat,
      @JsonKey(name: 'liveResults')
      final List<LiveResultDto> liveResults = const <LiveResultDto>[]})
      : _liveResults = liveResults;

  factory _$RunDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RunDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'label')
  final String label;
  @override
  @JsonKey(name: 'fullLabel')
  final String fullLabel;
  @override
  @JsonKey(name: 'statut')
  final int status;
  @override
  @JsonKey(name: 'statutLabel')
  final String statusLabel;
  @override
  @JsonKey(name: 'site')
  final String site;
  @override
  @JsonKey(name: 'debut')
  final String beginTime;
  @override
  @JsonKey(name: 'fin')
  final String endTime;
  @override
  @JsonKey(name: 'serie')
  final HeatDto? heat;
  final List<LiveResultDto> _liveResults;
  @override
  @JsonKey(name: 'liveResults')
  List<LiveResultDto> get liveResults {
    if (_liveResults is EqualUnmodifiableListView) return _liveResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_liveResults);
  }

  @override
  String toString() {
    return 'RunDto(id: $id, name: $name, label: $label, fullLabel: $fullLabel, status: $status, statusLabel: $statusLabel, site: $site, beginTime: $beginTime, endTime: $endTime, heat: $heat, liveResults: $liveResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RunDtoImpl &&
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
  _$$RunDtoImplCopyWith<_$RunDtoImpl> get copyWith =>
      __$$RunDtoImplCopyWithImpl<_$RunDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RunDtoImplToJson(
      this,
    );
  }
}

abstract class _RunDto implements RunDto {
  const factory _RunDto(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'label') required final String label,
      @JsonKey(name: 'fullLabel') required final String fullLabel,
      @JsonKey(name: 'statut') required final int status,
      @JsonKey(name: 'statutLabel') required final String statusLabel,
      @JsonKey(name: 'site') required final String site,
      @JsonKey(name: 'debut') required final String beginTime,
      @JsonKey(name: 'fin') required final String endTime,
      @JsonKey(name: 'serie') final HeatDto? heat,
      @JsonKey(name: 'liveResults')
      final List<LiveResultDto> liveResults}) = _$RunDtoImpl;

  factory _RunDto.fromJson(Map<String, dynamic> json) = _$RunDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'label')
  String get label;
  @override
  @JsonKey(name: 'fullLabel')
  String get fullLabel;
  @override
  @JsonKey(name: 'statut')
  int get status;
  @override
  @JsonKey(name: 'statutLabel')
  String get statusLabel;
  @override
  @JsonKey(name: 'site')
  String get site;
  @override
  @JsonKey(name: 'debut')
  String get beginTime;
  @override
  @JsonKey(name: 'fin')
  String get endTime;
  @override
  @JsonKey(name: 'serie')
  HeatDto? get heat;
  @override
  @JsonKey(name: 'liveResults')
  List<LiveResultDto> get liveResults;
  @override
  @JsonKey(ignore: true)
  _$$RunDtoImplCopyWith<_$RunDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
