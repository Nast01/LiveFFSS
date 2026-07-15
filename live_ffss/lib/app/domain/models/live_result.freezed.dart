// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'live_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LiveResult _$LiveResultFromJson(Map<String, dynamic> json) {
  return _LiveResult.fromJson(json);
}

/// @nodoc
mixin _$LiveResult {
  int get id => throw _privateConstructorUsedError;
  String get number => throw _privateConstructorUsedError;
  Entry? get entry => throw _privateConstructorUsedError;
  Result? get result => throw _privateConstructorUsedError;

  /// Serializes this LiveResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LiveResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LiveResultCopyWith<LiveResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LiveResultCopyWith<$Res> {
  factory $LiveResultCopyWith(
          LiveResult value, $Res Function(LiveResult) then) =
      _$LiveResultCopyWithImpl<$Res, LiveResult>;
  @useResult
  $Res call({int id, String number, Entry? entry, Result? result});

  $EntryCopyWith<$Res>? get entry;
  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$LiveResultCopyWithImpl<$Res, $Val extends LiveResult>
    implements $LiveResultCopyWith<$Res> {
  _$LiveResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LiveResult
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
              as Entry?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as Result?,
    ) as $Val);
  }

  /// Create a copy of LiveResult
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

  /// Create a copy of LiveResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResultCopyWith<$Res>? get result {
    if (_value.result == null) {
      return null;
    }

    return $ResultCopyWith<$Res>(_value.result!, (value) {
      return _then(_value.copyWith(result: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$LiveResultImplCopyWith<$Res>
    implements $LiveResultCopyWith<$Res> {
  factory _$$LiveResultImplCopyWith(
          _$LiveResultImpl value, $Res Function(_$LiveResultImpl) then) =
      __$$LiveResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String number, Entry? entry, Result? result});

  @override
  $EntryCopyWith<$Res>? get entry;
  @override
  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$LiveResultImplCopyWithImpl<$Res>
    extends _$LiveResultCopyWithImpl<$Res, _$LiveResultImpl>
    implements _$$LiveResultImplCopyWith<$Res> {
  __$$LiveResultImplCopyWithImpl(
      _$LiveResultImpl _value, $Res Function(_$LiveResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of LiveResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? number = null,
    Object? entry = freezed,
    Object? result = freezed,
  }) {
    return _then(_$LiveResultImpl(
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
              as Entry?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as Result?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LiveResultImpl implements _LiveResult {
  const _$LiveResultImpl(
      {required this.id, this.number = '', this.entry, this.result});

  factory _$LiveResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$LiveResultImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final String number;
  @override
  final Entry? entry;
  @override
  final Result? result;

  @override
  String toString() {
    return 'LiveResult(id: $id, number: $number, entry: $entry, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.entry, entry) || other.entry == entry) &&
            (identical(other.result, result) || other.result == result));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, number, entry, result);

  /// Create a copy of LiveResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveResultImplCopyWith<_$LiveResultImpl> get copyWith =>
      __$$LiveResultImplCopyWithImpl<_$LiveResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LiveResultImplToJson(
      this,
    );
  }
}

abstract class _LiveResult implements LiveResult {
  const factory _LiveResult(
      {required final int id,
      final String number,
      final Entry? entry,
      final Result? result}) = _$LiveResultImpl;

  factory _LiveResult.fromJson(Map<String, dynamic> json) =
      _$LiveResultImpl.fromJson;

  @override
  int get id;
  @override
  String get number;
  @override
  Entry? get entry;
  @override
  Result? get result;

  /// Create a copy of LiveResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LiveResultImplCopyWith<_$LiveResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
