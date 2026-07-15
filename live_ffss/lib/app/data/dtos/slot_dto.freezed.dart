// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlotDto _$SlotDtoFromJson(Map<String, dynamic> json) {
  return _SlotDto.fromJson(json);
}

/// @nodoc
mixin _$SlotDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Debut')
  String get beginHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fin')
  String get endHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'partie')
  RaceFormatDetailDto? get raceFormatDetail =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'courses')
  List<RunDto> get runs => throw _privateConstructorUsedError;

  /// Serializes this SlotDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotDtoCopyWith<SlotDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotDtoCopyWith<$Res> {
  factory $SlotDtoCopyWith(SlotDto value, $Res Function(SlotDto) then) =
      _$SlotDtoCopyWithImpl<$Res, SlotDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Debut') String beginHour,
      @JsonKey(name: 'Fin') String endHour,
      @JsonKey(name: 'partie') RaceFormatDetailDto? raceFormatDetail,
      @JsonKey(name: 'courses') List<RunDto> runs});

  $RaceFormatDetailDtoCopyWith<$Res>? get raceFormatDetail;
}

/// @nodoc
class _$SlotDtoCopyWithImpl<$Res, $Val extends SlotDto>
    implements $SlotDtoCopyWith<$Res> {
  _$SlotDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? raceFormatDetail = freezed,
    Object? runs = null,
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
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as String,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as String,
      raceFormatDetail: freezed == raceFormatDetail
          ? _value.raceFormatDetail
          : raceFormatDetail // ignore: cast_nullable_to_non_nullable
              as RaceFormatDetailDto?,
      runs: null == runs
          ? _value.runs
          : runs // ignore: cast_nullable_to_non_nullable
              as List<RunDto>,
    ) as $Val);
  }

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RaceFormatDetailDtoCopyWith<$Res>? get raceFormatDetail {
    if (_value.raceFormatDetail == null) {
      return null;
    }

    return $RaceFormatDetailDtoCopyWith<$Res>(_value.raceFormatDetail!,
        (value) {
      return _then(_value.copyWith(raceFormatDetail: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SlotDtoImplCopyWith<$Res> implements $SlotDtoCopyWith<$Res> {
  factory _$$SlotDtoImplCopyWith(
          _$SlotDtoImpl value, $Res Function(_$SlotDtoImpl) then) =
      __$$SlotDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Debut') String beginHour,
      @JsonKey(name: 'Fin') String endHour,
      @JsonKey(name: 'partie') RaceFormatDetailDto? raceFormatDetail,
      @JsonKey(name: 'courses') List<RunDto> runs});

  @override
  $RaceFormatDetailDtoCopyWith<$Res>? get raceFormatDetail;
}

/// @nodoc
class __$$SlotDtoImplCopyWithImpl<$Res>
    extends _$SlotDtoCopyWithImpl<$Res, _$SlotDtoImpl>
    implements _$$SlotDtoImplCopyWith<$Res> {
  __$$SlotDtoImplCopyWithImpl(
      _$SlotDtoImpl _value, $Res Function(_$SlotDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? raceFormatDetail = freezed,
    Object? runs = null,
  }) {
    return _then(_$SlotDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as String,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as String,
      raceFormatDetail: freezed == raceFormatDetail
          ? _value.raceFormatDetail
          : raceFormatDetail // ignore: cast_nullable_to_non_nullable
              as RaceFormatDetailDto?,
      runs: null == runs
          ? _value._runs
          : runs // ignore: cast_nullable_to_non_nullable
              as List<RunDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotDtoImpl implements _SlotDto {
  const _$SlotDtoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'Debut') required this.beginHour,
      @JsonKey(name: 'Fin') required this.endHour,
      @JsonKey(name: 'partie') this.raceFormatDetail,
      @JsonKey(name: 'courses') final List<RunDto> runs = const <RunDto>[]})
      : _runs = runs;

  factory _$SlotDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'Debut')
  final String beginHour;
  @override
  @JsonKey(name: 'Fin')
  final String endHour;
  @override
  @JsonKey(name: 'partie')
  final RaceFormatDetailDto? raceFormatDetail;
  final List<RunDto> _runs;
  @override
  @JsonKey(name: 'courses')
  List<RunDto> get runs {
    if (_runs is EqualUnmodifiableListView) return _runs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_runs);
  }

  @override
  String toString() {
    return 'SlotDto(id: $id, name: $name, beginHour: $beginHour, endHour: $endHour, raceFormatDetail: $raceFormatDetail, runs: $runs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.beginHour, beginHour) ||
                other.beginHour == beginHour) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            (identical(other.raceFormatDetail, raceFormatDetail) ||
                other.raceFormatDetail == raceFormatDetail) &&
            const DeepCollectionEquality().equals(other._runs, _runs));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, beginHour, endHour,
      raceFormatDetail, const DeepCollectionEquality().hash(_runs));

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotDtoImplCopyWith<_$SlotDtoImpl> get copyWith =>
      __$$SlotDtoImplCopyWithImpl<_$SlotDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotDtoImplToJson(
      this,
    );
  }
}

abstract class _SlotDto implements SlotDto {
  const factory _SlotDto(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'Debut') required final String beginHour,
      @JsonKey(name: 'Fin') required final String endHour,
      @JsonKey(name: 'partie') final RaceFormatDetailDto? raceFormatDetail,
      @JsonKey(name: 'courses') final List<RunDto> runs}) = _$SlotDtoImpl;

  factory _SlotDto.fromJson(Map<String, dynamic> json) = _$SlotDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'Debut')
  String get beginHour;
  @override
  @JsonKey(name: 'Fin')
  String get endHour;
  @override
  @JsonKey(name: 'partie')
  RaceFormatDetailDto? get raceFormatDetail;
  @override
  @JsonKey(name: 'courses')
  List<RunDto> get runs;

  /// Create a copy of SlotDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotDtoImplCopyWith<_$SlotDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
