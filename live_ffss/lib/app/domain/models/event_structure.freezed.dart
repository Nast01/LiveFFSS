// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_structure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventStructure _$EventStructureFromJson(Map<String, dynamic> json) {
  return _EventStructure.fromJson(json);
}

/// @nodoc
mixin _$EventStructure {
  int get raceId => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  String get raceLabel => throw _privateConstructorUsedError;
  String get categoryLabel =>
      throw _privateConstructorUsedError; // Race size; drives seriesCount = ceil(entries / spotsPerRace).
  int get spotsPerRace => throw _privateConstructorUsedError;
  List<RoundLevel> get levels => throw _privateConstructorUsedError;

  /// Serializes this EventStructure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventStructure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventStructureCopyWith<EventStructure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventStructureCopyWith<$Res> {
  factory $EventStructureCopyWith(
          EventStructure value, $Res Function(EventStructure) then) =
      _$EventStructureCopyWithImpl<$Res, EventStructure>;
  @useResult
  $Res call(
      {int raceId,
      int categoryId,
      String raceLabel,
      String categoryLabel,
      int spotsPerRace,
      List<RoundLevel> levels});
}

/// @nodoc
class _$EventStructureCopyWithImpl<$Res, $Val extends EventStructure>
    implements $EventStructureCopyWith<$Res> {
  _$EventStructureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventStructure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceId = null,
    Object? categoryId = null,
    Object? raceLabel = null,
    Object? categoryLabel = null,
    Object? spotsPerRace = null,
    Object? levels = null,
  }) {
    return _then(_value.copyWith(
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      raceLabel: null == raceLabel
          ? _value.raceLabel
          : raceLabel // ignore: cast_nullable_to_non_nullable
              as String,
      categoryLabel: null == categoryLabel
          ? _value.categoryLabel
          : categoryLabel // ignore: cast_nullable_to_non_nullable
              as String,
      spotsPerRace: null == spotsPerRace
          ? _value.spotsPerRace
          : spotsPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      levels: null == levels
          ? _value.levels
          : levels // ignore: cast_nullable_to_non_nullable
              as List<RoundLevel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventStructureImplCopyWith<$Res>
    implements $EventStructureCopyWith<$Res> {
  factory _$$EventStructureImplCopyWith(_$EventStructureImpl value,
          $Res Function(_$EventStructureImpl) then) =
      __$$EventStructureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int raceId,
      int categoryId,
      String raceLabel,
      String categoryLabel,
      int spotsPerRace,
      List<RoundLevel> levels});
}

/// @nodoc
class __$$EventStructureImplCopyWithImpl<$Res>
    extends _$EventStructureCopyWithImpl<$Res, _$EventStructureImpl>
    implements _$$EventStructureImplCopyWith<$Res> {
  __$$EventStructureImplCopyWithImpl(
      _$EventStructureImpl _value, $Res Function(_$EventStructureImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventStructure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? raceId = null,
    Object? categoryId = null,
    Object? raceLabel = null,
    Object? categoryLabel = null,
    Object? spotsPerRace = null,
    Object? levels = null,
  }) {
    return _then(_$EventStructureImpl(
      raceId: null == raceId
          ? _value.raceId
          : raceId // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      raceLabel: null == raceLabel
          ? _value.raceLabel
          : raceLabel // ignore: cast_nullable_to_non_nullable
              as String,
      categoryLabel: null == categoryLabel
          ? _value.categoryLabel
          : categoryLabel // ignore: cast_nullable_to_non_nullable
              as String,
      spotsPerRace: null == spotsPerRace
          ? _value.spotsPerRace
          : spotsPerRace // ignore: cast_nullable_to_non_nullable
              as int,
      levels: null == levels
          ? _value._levels
          : levels // ignore: cast_nullable_to_non_nullable
              as List<RoundLevel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventStructureImpl implements _EventStructure {
  const _$EventStructureImpl(
      {required this.raceId,
      required this.categoryId,
      required this.raceLabel,
      required this.categoryLabel,
      this.spotsPerRace = 8,
      final List<RoundLevel> levels = const <RoundLevel>[]})
      : _levels = levels;

  factory _$EventStructureImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventStructureImplFromJson(json);

  @override
  final int raceId;
  @override
  final int categoryId;
  @override
  final String raceLabel;
  @override
  final String categoryLabel;
// Race size; drives seriesCount = ceil(entries / spotsPerRace).
  @override
  @JsonKey()
  final int spotsPerRace;
  final List<RoundLevel> _levels;
  @override
  @JsonKey()
  List<RoundLevel> get levels {
    if (_levels is EqualUnmodifiableListView) return _levels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_levels);
  }

  @override
  String toString() {
    return 'EventStructure(raceId: $raceId, categoryId: $categoryId, raceLabel: $raceLabel, categoryLabel: $categoryLabel, spotsPerRace: $spotsPerRace, levels: $levels)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventStructureImpl &&
            (identical(other.raceId, raceId) || other.raceId == raceId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.raceLabel, raceLabel) ||
                other.raceLabel == raceLabel) &&
            (identical(other.categoryLabel, categoryLabel) ||
                other.categoryLabel == categoryLabel) &&
            (identical(other.spotsPerRace, spotsPerRace) ||
                other.spotsPerRace == spotsPerRace) &&
            const DeepCollectionEquality().equals(other._levels, _levels));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      raceId,
      categoryId,
      raceLabel,
      categoryLabel,
      spotsPerRace,
      const DeepCollectionEquality().hash(_levels));

  /// Create a copy of EventStructure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventStructureImplCopyWith<_$EventStructureImpl> get copyWith =>
      __$$EventStructureImplCopyWithImpl<_$EventStructureImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventStructureImplToJson(
      this,
    );
  }
}

abstract class _EventStructure implements EventStructure {
  const factory _EventStructure(
      {required final int raceId,
      required final int categoryId,
      required final String raceLabel,
      required final String categoryLabel,
      final int spotsPerRace,
      final List<RoundLevel> levels}) = _$EventStructureImpl;

  factory _EventStructure.fromJson(Map<String, dynamic> json) =
      _$EventStructureImpl.fromJson;

  @override
  int get raceId;
  @override
  int get categoryId;
  @override
  String get raceLabel;
  @override
  String
      get categoryLabel; // Race size; drives seriesCount = ceil(entries / spotsPerRace).
  @override
  int get spotsPerRace;
  @override
  List<RoundLevel> get levels;

  /// Create a copy of EventStructure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventStructureImplCopyWith<_$EventStructureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
