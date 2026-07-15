// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'race_format_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RaceFormatConfiguration _$RaceFormatConfigurationFromJson(
    Map<String, dynamic> json) {
  return _RaceFormatConfiguration.fromJson(json);
}

/// @nodoc
mixin _$RaceFormatConfiguration {
  int get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  String get fullLabel => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  String get genderLabel => throw _privateConstructorUsedError;
  Discipline get discipline => throw _privateConstructorUsedError;
  List<Category> get categories => throw _privateConstructorUsedError;

  /// Serializes this RaceFormatConfiguration to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaceFormatConfigurationCopyWith<RaceFormatConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaceFormatConfigurationCopyWith<$Res> {
  factory $RaceFormatConfigurationCopyWith(RaceFormatConfiguration value,
          $Res Function(RaceFormatConfiguration) then) =
      _$RaceFormatConfigurationCopyWithImpl<$Res, RaceFormatConfiguration>;
  @useResult
  $Res call(
      {int id,
      String label,
      String fullLabel,
      String gender,
      String genderLabel,
      Discipline discipline,
      List<Category> categories});

  $DisciplineCopyWith<$Res> get discipline;
}

/// @nodoc
class _$RaceFormatConfigurationCopyWithImpl<$Res,
        $Val extends RaceFormatConfiguration>
    implements $RaceFormatConfigurationCopyWith<$Res> {
  _$RaceFormatConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? gender = null,
    Object? genderLabel = null,
    Object? discipline = null,
    Object? categories = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      genderLabel: null == genderLabel
          ? _value.genderLabel
          : genderLabel // ignore: cast_nullable_to_non_nullable
              as String,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as Discipline,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
    ) as $Val);
  }

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DisciplineCopyWith<$Res> get discipline {
    return $DisciplineCopyWith<$Res>(_value.discipline, (value) {
      return _then(_value.copyWith(discipline: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RaceFormatConfigurationImplCopyWith<$Res>
    implements $RaceFormatConfigurationCopyWith<$Res> {
  factory _$$RaceFormatConfigurationImplCopyWith(
          _$RaceFormatConfigurationImpl value,
          $Res Function(_$RaceFormatConfigurationImpl) then) =
      __$$RaceFormatConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String label,
      String fullLabel,
      String gender,
      String genderLabel,
      Discipline discipline,
      List<Category> categories});

  @override
  $DisciplineCopyWith<$Res> get discipline;
}

/// @nodoc
class __$$RaceFormatConfigurationImplCopyWithImpl<$Res>
    extends _$RaceFormatConfigurationCopyWithImpl<$Res,
        _$RaceFormatConfigurationImpl>
    implements _$$RaceFormatConfigurationImplCopyWith<$Res> {
  __$$RaceFormatConfigurationImplCopyWithImpl(
      _$RaceFormatConfigurationImpl _value,
      $Res Function(_$RaceFormatConfigurationImpl) _then)
      : super(_value, _then);

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? fullLabel = null,
    Object? gender = null,
    Object? genderLabel = null,
    Object? discipline = null,
    Object? categories = null,
  }) {
    return _then(_$RaceFormatConfigurationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      fullLabel: null == fullLabel
          ? _value.fullLabel
          : fullLabel // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      genderLabel: null == genderLabel
          ? _value.genderLabel
          : genderLabel // ignore: cast_nullable_to_non_nullable
              as String,
      discipline: null == discipline
          ? _value.discipline
          : discipline // ignore: cast_nullable_to_non_nullable
              as Discipline,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<Category>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RaceFormatConfigurationImpl implements _RaceFormatConfiguration {
  const _$RaceFormatConfigurationImpl(
      {required this.id,
      required this.label,
      required this.fullLabel,
      required this.gender,
      required this.genderLabel,
      required this.discipline,
      final List<Category> categories = const <Category>[]})
      : _categories = categories;

  factory _$RaceFormatConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaceFormatConfigurationImplFromJson(json);

  @override
  final int id;
  @override
  final String label;
  @override
  final String fullLabel;
  @override
  final String gender;
  @override
  final String genderLabel;
  @override
  final Discipline discipline;
  final List<Category> _categories;
  @override
  @JsonKey()
  List<Category> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  String toString() {
    return 'RaceFormatConfiguration(id: $id, label: $label, fullLabel: $fullLabel, gender: $gender, genderLabel: $genderLabel, discipline: $discipline, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaceFormatConfigurationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.fullLabel, fullLabel) ||
                other.fullLabel == fullLabel) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.genderLabel, genderLabel) ||
                other.genderLabel == genderLabel) &&
            (identical(other.discipline, discipline) ||
                other.discipline == discipline) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      label,
      fullLabel,
      gender,
      genderLabel,
      discipline,
      const DeepCollectionEquality().hash(_categories));

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaceFormatConfigurationImplCopyWith<_$RaceFormatConfigurationImpl>
      get copyWith => __$$RaceFormatConfigurationImplCopyWithImpl<
          _$RaceFormatConfigurationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaceFormatConfigurationImplToJson(
      this,
    );
  }
}

abstract class _RaceFormatConfiguration implements RaceFormatConfiguration {
  const factory _RaceFormatConfiguration(
      {required final int id,
      required final String label,
      required final String fullLabel,
      required final String gender,
      required final String genderLabel,
      required final Discipline discipline,
      final List<Category> categories}) = _$RaceFormatConfigurationImpl;

  factory _RaceFormatConfiguration.fromJson(Map<String, dynamic> json) =
      _$RaceFormatConfigurationImpl.fromJson;

  @override
  int get id;
  @override
  String get label;
  @override
  String get fullLabel;
  @override
  String get gender;
  @override
  String get genderLabel;
  @override
  Discipline get discipline;
  @override
  List<Category> get categories;

  /// Create a copy of RaceFormatConfiguration
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaceFormatConfigurationImplCopyWith<_$RaceFormatConfigurationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
