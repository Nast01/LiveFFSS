// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClubRanking _$ClubRankingFromJson(Map<String, dynamic> json) {
  return _ClubRanking.fromJson(json);
}

/// @nodoc
mixin _$ClubRanking {
  int get position => throw _privateConstructorUsedError;
  String get clubName => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  /// Serializes this ClubRanking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClubRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClubRankingCopyWith<ClubRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClubRankingCopyWith<$Res> {
  factory $ClubRankingCopyWith(
          ClubRanking value, $Res Function(ClubRanking) then) =
      _$ClubRankingCopyWithImpl<$Res, ClubRanking>;
  @useResult
  $Res call({int position, String clubName, int points});
}

/// @nodoc
class _$ClubRankingCopyWithImpl<$Res, $Val extends ClubRanking>
    implements $ClubRankingCopyWith<$Res> {
  _$ClubRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClubRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? clubName = null,
    Object? points = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClubRankingImplCopyWith<$Res>
    implements $ClubRankingCopyWith<$Res> {
  factory _$$ClubRankingImplCopyWith(
          _$ClubRankingImpl value, $Res Function(_$ClubRankingImpl) then) =
      __$$ClubRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int position, String clubName, int points});
}

/// @nodoc
class __$$ClubRankingImplCopyWithImpl<$Res>
    extends _$ClubRankingCopyWithImpl<$Res, _$ClubRankingImpl>
    implements _$$ClubRankingImplCopyWith<$Res> {
  __$$ClubRankingImplCopyWithImpl(
      _$ClubRankingImpl _value, $Res Function(_$ClubRankingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClubRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? clubName = null,
    Object? points = null,
  }) {
    return _then(_$ClubRankingImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClubRankingImpl implements _ClubRanking {
  const _$ClubRankingImpl(
      {this.position = 0, this.clubName = '', this.points = 0});

  factory _$ClubRankingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClubRankingImplFromJson(json);

  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey()
  final String clubName;
  @override
  @JsonKey()
  final int points;

  @override
  String toString() {
    return 'ClubRanking(position: $position, clubName: $clubName, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClubRankingImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, position, clubName, points);

  /// Create a copy of ClubRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClubRankingImplCopyWith<_$ClubRankingImpl> get copyWith =>
      __$$ClubRankingImplCopyWithImpl<_$ClubRankingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClubRankingImplToJson(
      this,
    );
  }
}

abstract class _ClubRanking implements ClubRanking {
  const factory _ClubRanking(
      {final int position,
      final String clubName,
      final int points}) = _$ClubRankingImpl;

  factory _ClubRanking.fromJson(Map<String, dynamic> json) =
      _$ClubRankingImpl.fromJson;

  @override
  int get position;
  @override
  String get clubName;
  @override
  int get points;

  /// Create a copy of ClubRanking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClubRankingImplCopyWith<_$ClubRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
