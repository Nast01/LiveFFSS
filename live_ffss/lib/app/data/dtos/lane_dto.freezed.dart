// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lane_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LaneDto _$LaneDtoFromJson(Map<String, dynamic> json) {
  return _LaneDto.fromJson(json);
}

/// @nodoc
mixin _$LaneDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Numero')
  int get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String get label => throw _privateConstructorUsedError;
  @JsonKey(name: 'engagement')
  EntryDto? get entry => throw _privateConstructorUsedError;
  @JsonKey(name: 'resultat')
  ResultDto? get result => throw _privateConstructorUsedError;

  /// Serializes this LaneDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaneDtoCopyWith<LaneDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaneDtoCopyWith<$Res> {
  factory $LaneDtoCopyWith(LaneDto value, $Res Function(LaneDto) then) =
      _$LaneDtoCopyWithImpl<$Res, LaneDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Numero') int number,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'engagement') EntryDto? entry,
      @JsonKey(name: 'resultat') ResultDto? result});

  $EntryDtoCopyWith<$Res>? get entry;
  $ResultDtoCopyWith<$Res>? get result;
}

/// @nodoc
class _$LaneDtoCopyWithImpl<$Res, $Val extends LaneDto>
    implements $LaneDtoCopyWith<$Res> {
  _$LaneDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? label = null,
    Object? entry = freezed,
    Object? result = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as EntryDto?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ResultDto?,
    ) as $Val);
  }

  /// Create a copy of LaneDto
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

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultDtoCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ResultDtoCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LaneDtoImplCopyWith<$Res> implements $LaneDtoCopyWith<$Res> {
  factory _$$LaneDtoImplCopyWith(
          _$LaneDtoImpl value, $Res Function(_$LaneDtoImpl) then) =
      __$$LaneDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'id') int id,
      @JsonKey(name: 'Numero') int number,
      @JsonKey(name: 'label') String label,
      @JsonKey(name: 'engagement') EntryDto? entry,
      @JsonKey(name: 'resultat') ResultDto? result});

  @override
  $EntryDtoCopyWith<$Res>? get entry;
  @override
  $ResultDtoCopyWith<$Res>? get result;
}

/// @nodoc
class __$$LaneDtoImplCopyWithImpl<$Res>
    extends _$LaneDtoCopyWithImpl<$Res, _$LaneDtoImpl>
    implements _$$LaneDtoImplCopyWith<$Res> {
  __$$LaneDtoImplCopyWithImpl(
      _$LaneDtoImpl _value, $Res Function(_$LaneDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? label = null,
    Object? entry = freezed,
    Object? result = freezed,
  }) {
    return _then(_$LaneDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as EntryDto?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ResultDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LaneDtoImpl implements _LaneDto {
  const _$LaneDtoImpl(
      {@JsonKey(name: 'id') required this.id,
      @JsonKey(name: 'Numero') this.number = 0,
      @JsonKey(name: 'label') this.label = '',
      @JsonKey(name: 'engagement') this.entry,
      @JsonKey(name: 'resultat') this.result});

  factory _$LaneDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaneDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'Numero')
  final int number;
  @override
  @JsonKey(name: 'label')
  final String label;
  @override
  @JsonKey(name: 'engagement')
  final EntryDto? entry;
  @override
  @JsonKey(name: 'resultat')
  final ResultDto? result;

  @override
  String toString() {
    return 'LaneDto(id: $id, number: $number, label: $label, entry: $entry, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaneDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.entry, entry) || other.entry == entry) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, number, label, entry, result);

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaneDtoImplCopyWith<_$LaneDtoImpl> get copyWith =>
      __$$LaneDtoImplCopyWithImpl<_$LaneDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaneDtoImplToJson(
      this,
    );
  }
}

abstract class _LaneDto implements LaneDto {
  const factory _LaneDto(
      {@JsonKey(name: 'id') required final int id,
      @JsonKey(name: 'Numero') final int number,
      @JsonKey(name: 'label') final String label,
      @JsonKey(name: 'engagement') final EntryDto? entry,
      @JsonKey(name: 'resultat') final ResultDto? result}) = _$LaneDtoImpl;

  factory _LaneDto.fromJson(Map<String, dynamic> json) = _$LaneDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'Numero')
  int get number;
  @override
  @JsonKey(name: 'label')
  String get label;
  @override
  @JsonKey(name: 'engagement')
  EntryDto? get entry;
  @override
  @JsonKey(name: 'resultat')
  ResultDto? get result;

  /// Create a copy of LaneDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaneDtoImplCopyWith<_$LaneDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
