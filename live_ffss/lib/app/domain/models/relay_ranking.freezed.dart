// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relay_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RelayRanking _$RelayRankingFromJson(Map<String, dynamic> json) {
  return _RelayRanking.fromJson(json);
}

/// @nodoc
mixin _$RelayRanking {
  int get position => throw _privateConstructorUsedError;
  String get clubName => throw _privateConstructorUsedError;
  String get teamName => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RelayRankingCopyWith<RelayRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelayRankingCopyWith<$Res> {
  factory $RelayRankingCopyWith(
          RelayRanking value, $Res Function(RelayRanking) then) =
      _$RelayRankingCopyWithImpl<$Res, RelayRanking>;
  @useResult
  $Res call({int position, String clubName, String teamName, int points});
}

/// @nodoc
class _$RelayRankingCopyWithImpl<$Res, $Val extends RelayRanking>
    implements $RelayRankingCopyWith<$Res> {
  _$RelayRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? clubName = null,
    Object? teamName = null,
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
      teamName: null == teamName
          ? _value.teamName
          : teamName // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelayRankingImplCopyWith<$Res>
    implements $RelayRankingCopyWith<$Res> {
  factory _$$RelayRankingImplCopyWith(
          _$RelayRankingImpl value, $Res Function(_$RelayRankingImpl) then) =
      __$$RelayRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int position, String clubName, String teamName, int points});
}

/// @nodoc
class __$$RelayRankingImplCopyWithImpl<$Res>
    extends _$RelayRankingCopyWithImpl<$Res, _$RelayRankingImpl>
    implements _$$RelayRankingImplCopyWith<$Res> {
  __$$RelayRankingImplCopyWithImpl(
      _$RelayRankingImpl _value, $Res Function(_$RelayRankingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? clubName = null,
    Object? teamName = null,
    Object? points = null,
  }) {
    return _then(_$RelayRankingImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      clubName: null == clubName
          ? _value.clubName
          : clubName // ignore: cast_nullable_to_non_nullable
              as String,
      teamName: null == teamName
          ? _value.teamName
          : teamName // ignore: cast_nullable_to_non_nullable
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
class _$RelayRankingImpl implements _RelayRanking {
  const _$RelayRankingImpl(
      {this.position = 0,
      this.clubName = '',
      this.teamName = '',
      this.points = 0});

  factory _$RelayRankingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelayRankingImplFromJson(json);

  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey()
  final String clubName;
  @override
  @JsonKey()
  final String teamName;
  @override
  @JsonKey()
  final int points;

  @override
  String toString() {
    return 'RelayRanking(position: $position, clubName: $clubName, teamName: $teamName, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelayRankingImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.teamName, teamName) ||
                other.teamName == teamName) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, position, clubName, teamName, points);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RelayRankingImplCopyWith<_$RelayRankingImpl> get copyWith =>
      __$$RelayRankingImplCopyWithImpl<_$RelayRankingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelayRankingImplToJson(
      this,
    );
  }
}

abstract class _RelayRanking implements RelayRanking {
  const factory _RelayRanking(
      {final int position,
      final String clubName,
      final String teamName,
      final int points}) = _$RelayRankingImpl;

  factory _RelayRanking.fromJson(Map<String, dynamic> json) =
      _$RelayRankingImpl.fromJson;

  @override
  int get position;
  @override
  String get clubName;
  @override
  String get teamName;
  @override
  int get points;
  @override
  @JsonKey(ignore: true)
  _$$RelayRankingImplCopyWith<_$RelayRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
