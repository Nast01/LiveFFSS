// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lane.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lane _$LaneFromJson(Map<String, dynamic> json) {
  return _Lane.fromJson(json);
}

/// @nodoc
mixin _$Lane {
  int get id => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  Entry? get entry => throw _privateConstructorUsedError;
  Result? get result => throw _privateConstructorUsedError;

  /// Serializes this Lane to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lane
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LaneCopyWith<Lane> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LaneCopyWith<$Res> {
  factory $LaneCopyWith(Lane value, $Res Function(Lane) then) =
      _$LaneCopyWithImpl<$Res, Lane>;
  @useResult
  $Res call({int id, int number, String label, Entry? entry, Result? result});

  $EntryCopyWith<$Res>? get entry;
  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class _$LaneCopyWithImpl<$Res, $Val extends Lane>
    implements $LaneCopyWith<$Res> {
  _$LaneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lane
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
              as Entry?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as Result?,
    ) as $Val);
  }

  /// Create a copy of Lane
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

  /// Create a copy of Lane
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
abstract class _$$LaneImplCopyWith<$Res> implements $LaneCopyWith<$Res> {
  factory _$$LaneImplCopyWith(
          _$LaneImpl value, $Res Function(_$LaneImpl) then) =
      __$$LaneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int number, String label, Entry? entry, Result? result});

  @override
  $EntryCopyWith<$Res>? get entry;
  @override
  $ResultCopyWith<$Res>? get result;
}

/// @nodoc
class __$$LaneImplCopyWithImpl<$Res>
    extends _$LaneCopyWithImpl<$Res, _$LaneImpl>
    implements _$$LaneImplCopyWith<$Res> {
  __$$LaneImplCopyWithImpl(_$LaneImpl _value, $Res Function(_$LaneImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lane
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
    return _then(_$LaneImpl(
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
class _$LaneImpl implements _Lane {
  const _$LaneImpl(
      {required this.id,
      this.number = 0,
      this.label = '',
      this.entry,
      this.result});

  factory _$LaneImpl.fromJson(Map<String, dynamic> json) =>
      _$$LaneImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey()
  final int number;
  @override
  @JsonKey()
  final String label;
  @override
  final Entry? entry;
  @override
  final Result? result;

  @override
  String toString() {
    return 'Lane(id: $id, number: $number, label: $label, entry: $entry, result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LaneImpl &&
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

  /// Create a copy of Lane
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LaneImplCopyWith<_$LaneImpl> get copyWith =>
      __$$LaneImplCopyWithImpl<_$LaneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LaneImplToJson(
      this,
    );
  }
}

abstract class _Lane implements Lane {
  const factory _Lane(
      {required final int id,
      final int number,
      final String label,
      final Entry? entry,
      final Result? result}) = _$LaneImpl;

  factory _Lane.fromJson(Map<String, dynamic> json) = _$LaneImpl.fromJson;

  @override
  int get id;
  @override
  int get number;
  @override
  String get label;
  @override
  Entry? get entry;
  @override
  Result? get result;

  /// Create a copy of Lane
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LaneImplCopyWith<_$LaneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
