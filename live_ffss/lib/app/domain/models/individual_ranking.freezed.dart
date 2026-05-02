// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'individual_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IndividualRanking _$IndividualRankingFromJson(Map<String, dynamic> json) {
  return _IndividualRanking.fromJson(json);
}

/// @nodoc
mixin _$IndividualRanking {
  int get position => throw _privateConstructorUsedError;
  String get athleteFirstName => throw _privateConstructorUsedError;
  String get athleteLastName => throw _privateConstructorUsedError;
  String get clubName => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IndividualRankingCopyWith<IndividualRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IndividualRankingCopyWith<$Res> {
  factory $IndividualRankingCopyWith(
          IndividualRanking value, $Res Function(IndividualRanking) then) =
      _$IndividualRankingCopyWithImpl<$Res, IndividualRanking>;
  @useResult
  $Res call(
      {int position,
      String athleteFirstName,
      String athleteLastName,
      String clubName,
      int points});
}

/// @nodoc
class _$IndividualRankingCopyWithImpl<$Res, $Val extends IndividualRanking>
    implements $IndividualRankingCopyWith<$Res> {
  _$IndividualRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? athleteFirstName = null,
    Object? athleteLastName = null,
    Object? clubName = null,
    Object? points = null,
  }) {
    return _then(_value.copyWith(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      athleteFirstName: null == athleteFirstName
          ? _value.athleteFirstName
          : athleteFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      athleteLastName: null == athleteLastName
          ? _value.athleteLastName
          : athleteLastName // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$IndividualRankingImplCopyWith<$Res>
    implements $IndividualRankingCopyWith<$Res> {
  factory _$$IndividualRankingImplCopyWith(_$IndividualRankingImpl value,
          $Res Function(_$IndividualRankingImpl) then) =
      __$$IndividualRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int position,
      String athleteFirstName,
      String athleteLastName,
      String clubName,
      int points});
}

/// @nodoc
class __$$IndividualRankingImplCopyWithImpl<$Res>
    extends _$IndividualRankingCopyWithImpl<$Res, _$IndividualRankingImpl>
    implements _$$IndividualRankingImplCopyWith<$Res> {
  __$$IndividualRankingImplCopyWithImpl(_$IndividualRankingImpl _value,
      $Res Function(_$IndividualRankingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? position = null,
    Object? athleteFirstName = null,
    Object? athleteLastName = null,
    Object? clubName = null,
    Object? points = null,
  }) {
    return _then(_$IndividualRankingImpl(
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      athleteFirstName: null == athleteFirstName
          ? _value.athleteFirstName
          : athleteFirstName // ignore: cast_nullable_to_non_nullable
              as String,
      athleteLastName: null == athleteLastName
          ? _value.athleteLastName
          : athleteLastName // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$IndividualRankingImpl implements _IndividualRanking {
  const _$IndividualRankingImpl(
      {this.position = 0,
      this.athleteFirstName = '',
      this.athleteLastName = '',
      this.clubName = '',
      this.points = 0});

  factory _$IndividualRankingImpl.fromJson(Map<String, dynamic> json) =>
      _$$IndividualRankingImplFromJson(json);

  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey()
  final String athleteFirstName;
  @override
  @JsonKey()
  final String athleteLastName;
  @override
  @JsonKey()
  final String clubName;
  @override
  @JsonKey()
  final int points;

  @override
  String toString() {
    return 'IndividualRanking(position: $position, athleteFirstName: $athleteFirstName, athleteLastName: $athleteLastName, clubName: $clubName, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IndividualRankingImpl &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.athleteFirstName, athleteFirstName) ||
                other.athleteFirstName == athleteFirstName) &&
            (identical(other.athleteLastName, athleteLastName) ||
                other.athleteLastName == athleteLastName) &&
            (identical(other.clubName, clubName) ||
                other.clubName == clubName) &&
            (identical(other.points, points) || other.points == points));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, position, athleteFirstName,
      athleteLastName, clubName, points);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IndividualRankingImplCopyWith<_$IndividualRankingImpl> get copyWith =>
      __$$IndividualRankingImplCopyWithImpl<_$IndividualRankingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IndividualRankingImplToJson(
      this,
    );
  }
}

abstract class _IndividualRanking implements IndividualRanking {
  const factory _IndividualRanking(
      {final int position,
      final String athleteFirstName,
      final String athleteLastName,
      final String clubName,
      final int points}) = _$IndividualRankingImpl;

  factory _IndividualRanking.fromJson(Map<String, dynamic> json) =
      _$IndividualRankingImpl.fromJson;

  @override
  int get position;
  @override
  String get athleteFirstName;
  @override
  String get athleteLastName;
  @override
  String get clubName;
  @override
  int get points;
  @override
  @JsonKey(ignore: true)
  _$$IndividualRankingImplCopyWith<_$IndividualRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
