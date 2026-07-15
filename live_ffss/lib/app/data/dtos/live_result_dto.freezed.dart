// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiveResultDto _$LiveResultDtoFromJson(Map<String, dynamic> json) {
  return _LiveResultDto.fromJson(json);
}

/// @nodoc
mixin _$LiveResultDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Numero')
  String get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'Engagement')
  EntryDto? get entry => throw _privateConstructorUsedError;
  @JsonKey(name: 'Resultat')
  ResultDto? get result => throw _privateConstructorUsedError;

  /// Serializes this LiveResultDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveResultDtoCopyWith<LiveResultDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveResultDtoCopyWith<$Res> {
  factory $LiveResultDtoCopyWith(
          LiveResultDto value, $Res Function(LiveResultDto) then) =
      _$LiveResultDtoCopyWithImpl<$Res, LiveResultDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Numero') String number,
      @JsonKey(name: 'Engagement') EntryDto? entry,
      @JsonKey(name: 'Resultat') ResultDto? result});

  $EntryDtoCopyWith<$Res>? get entry;
  $ResultDtoCopyWith<$Res>? get result;
}

/// @nodoc
class _$LiveResultDtoCopyWithImpl<$Res, $Val extends LiveResultDto>
    implements $LiveResultDtoCopyWith<$Res> {
  _$LiveResultDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
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

  /// Create a copy of LiveResultDto
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

  /// Create a copy of LiveResultDto
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
abstract class _$$LiveResultDtoImplCopyWith<$Res>
    implements $LiveResultDtoCopyWith<$Res> {
  factory _$$LiveResultDtoImplCopyWith(
          _$LiveResultDtoImpl value, $Res Function(_$LiveResultDtoImpl) then) =
      __$$LiveResultDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Numero') String number,
      @JsonKey(name: 'Engagement') EntryDto? entry,
      @JsonKey(name: 'Resultat') ResultDto? result});

  @override
  $EntryDtoCopyWith<$Res>? get entry;
  @override
  $ResultDtoCopyWith<$Res>? get result;
}

/// @nodoc
class __$$LiveResultDtoImplCopyWithImpl<$Res>
    extends _$LiveResultDtoCopyWithImpl<$Res, _$LiveResultDtoImpl>
    implements _$$LiveResultDtoImplCopyWith<$Res> {
  __$$LiveResultDtoImplCopyWithImpl(
      _$LiveResultDtoImpl _value, $Res Function(_$LiveResultDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of LiveResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? entry = freezed,
    Object? result = freezed,
  }) {
    return _then(_$LiveResultDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
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
class _$LiveResultDtoImpl implements _LiveResultDto {
  const _$LiveResultDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'Numero') this.number = '',
      @JsonKey(name: 'Engagement') this.entry,
      @JsonKey(name: 'Resultat') this.result});

  factory _$LiveResultDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveResultDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'Numero')
  final String number;
  @override
  @JsonKey(name: 'Engagement')
  final EntryDto? entry;
  @override
  @JsonKey(name: 'Resultat')
  final ResultDto? result;

  @override
  String toString() {
    return 'LiveResultDto(id: $id, number: $number, entry: $entry, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveResultDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.entry, entry) || other.entry == entry) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, entry, result);

  /// Create a copy of LiveResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveResultDtoImplCopyWith<_$LiveResultDtoImpl> get copyWith =>
      __$$LiveResultDtoImplCopyWithImpl<_$LiveResultDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveResultDtoImplToJson(
      this,
    );
  }
}

abstract class _LiveResultDto implements LiveResultDto {
  const factory _LiveResultDto(
          {@JsonKey(name: 'Id') required final int id,
          @JsonKey(name: 'Numero') final String number,
          @JsonKey(name: 'Engagement') final EntryDto? entry,
          @JsonKey(name: 'Resultat') final ResultDto? result}) =
      _$LiveResultDtoImpl;

  factory _LiveResultDto.fromJson(Map<String, dynamic> json) =
      _$LiveResultDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'Numero')
  String get number;
  @override
  @JsonKey(name: 'Engagement')
  EntryDto? get entry;
  @override
  @JsonKey(name: 'Resultat')
  ResultDto? get result;

  /// Create a copy of LiveResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveResultDtoImplCopyWith<_$LiveResultDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
