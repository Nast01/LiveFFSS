// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athlete_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AthleteEntryDto _$AthleteEntryDtoFromJson(Map<String, dynamic> json) {
  return _AthleteEntryDto.fromJson(json);
}

/// @nodoc
mixin _$AthleteEntryDto {
  @JsonKey(name: 'categorie')
  EntryCategoryDto? get category => throw _privateConstructorUsedError;

  /// Serializes this AthleteEntryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AthleteEntryDtoCopyWith<AthleteEntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AthleteEntryDtoCopyWith<$Res> {
  factory $AthleteEntryDtoCopyWith(
          AthleteEntryDto value, $Res Function(AthleteEntryDto) then) =
      _$AthleteEntryDtoCopyWithImpl<$Res, AthleteEntryDto>;
  @useResult
  $Res call({@JsonKey(name: 'categorie') EntryCategoryDto? category});

  $EntryCategoryDtoCopyWith<$Res>? get category;
}

/// @nodoc
class _$AthleteEntryDtoCopyWithImpl<$Res, $Val extends AthleteEntryDto>
    implements $AthleteEntryDtoCopyWith<$Res> {
  _$AthleteEntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EntryCategoryDto?,
    ) as $Val);
  }

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EntryCategoryDtoCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $EntryCategoryDtoCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AthleteEntryDtoImplCopyWith<$Res>
    implements $AthleteEntryDtoCopyWith<$Res> {
  factory _$$AthleteEntryDtoImplCopyWith(_$AthleteEntryDtoImpl value,
          $Res Function(_$AthleteEntryDtoImpl) then) =
      __$$AthleteEntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'categorie') EntryCategoryDto? category});

  @override
  $EntryCategoryDtoCopyWith<$Res>? get category;
}

/// @nodoc
class __$$AthleteEntryDtoImplCopyWithImpl<$Res>
    extends _$AthleteEntryDtoCopyWithImpl<$Res, _$AthleteEntryDtoImpl>
    implements _$$AthleteEntryDtoImplCopyWith<$Res> {
  __$$AthleteEntryDtoImplCopyWithImpl(
      _$AthleteEntryDtoImpl _value, $Res Function(_$AthleteEntryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = freezed,
  }) {
    return _then(_$AthleteEntryDtoImpl(
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as EntryCategoryDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AthleteEntryDtoImpl implements _AthleteEntryDto {
  const _$AthleteEntryDtoImpl({@JsonKey(name: 'categorie') this.category});

  factory _$AthleteEntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$AthleteEntryDtoImplFromJson(json);

  @override
  @JsonKey(name: 'categorie')
  final EntryCategoryDto? category;

  @override
  String toString() {
    return 'AthleteEntryDto(category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AthleteEntryDtoImpl &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category);

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AthleteEntryDtoImplCopyWith<_$AthleteEntryDtoImpl> get copyWith =>
      __$$AthleteEntryDtoImplCopyWithImpl<_$AthleteEntryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AthleteEntryDtoImplToJson(
      this,
    );
  }
}

abstract class _AthleteEntryDto implements AthleteEntryDto {
  const factory _AthleteEntryDto(
          {@JsonKey(name: 'categorie') final EntryCategoryDto? category}) =
      _$AthleteEntryDtoImpl;

  factory _AthleteEntryDto.fromJson(Map<String, dynamic> json) =
      _$AthleteEntryDtoImpl.fromJson;

  @override
  @JsonKey(name: 'categorie')
  EntryCategoryDto? get category;

  /// Create a copy of AthleteEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AthleteEntryDtoImplCopyWith<_$AthleteEntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EntryCategoryDto _$EntryCategoryDtoFromJson(Map<String, dynamic> json) {
  return _EntryCategoryDto.fromJson(json);
}

/// @nodoc
mixin _$EntryCategoryDto {
  @JsonKey(name: 'id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'label')
  String get name => throw _privateConstructorUsedError;

  /// Serializes this EntryCategoryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntryCategoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntryCategoryDtoCopyWith<EntryCategoryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryCategoryDtoCopyWith<$Res> {
  factory $EntryCategoryDtoCopyWith(
          EntryCategoryDto value, $Res Function(EntryCategoryDto) then) =
      _$EntryCategoryDtoCopyWithImpl<$Res, EntryCategoryDto>;
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'label') String name});
}

/// @nodoc
class _$EntryCategoryDtoCopyWithImpl<$Res, $Val extends EntryCategoryDto>
    implements $EntryCategoryDtoCopyWith<$Res> {
  _$EntryCategoryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntryCategoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EntryCategoryDtoImplCopyWith<$Res>
    implements $EntryCategoryDtoCopyWith<$Res> {
  factory _$$EntryCategoryDtoImplCopyWith(_$EntryCategoryDtoImpl value,
          $Res Function(_$EntryCategoryDtoImpl) then) =
      __$$EntryCategoryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'id') int id, @JsonKey(name: 'label') String name});
}

/// @nodoc
class __$$EntryCategoryDtoImplCopyWithImpl<$Res>
    extends _$EntryCategoryDtoCopyWithImpl<$Res, _$EntryCategoryDtoImpl>
    implements _$$EntryCategoryDtoImplCopyWith<$Res> {
  __$$EntryCategoryDtoImplCopyWithImpl(_$EntryCategoryDtoImpl _value,
      $Res Function(_$EntryCategoryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of EntryCategoryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$EntryCategoryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntryCategoryDtoImpl implements _EntryCategoryDto {
  const _$EntryCategoryDtoImpl(
      {@JsonKey(name: 'id') this.id = 0,
      @JsonKey(name: 'label') this.name = ''});

  factory _$EntryCategoryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryCategoryDtoImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final int id;
  @override
  @JsonKey(name: 'label')
  final String name;

  @override
  String toString() {
    return 'EntryCategoryDto(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryCategoryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of EntryCategoryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryCategoryDtoImplCopyWith<_$EntryCategoryDtoImpl> get copyWith =>
      __$$EntryCategoryDtoImplCopyWithImpl<_$EntryCategoryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryCategoryDtoImplToJson(
      this,
    );
  }
}

abstract class _EntryCategoryDto implements EntryCategoryDto {
  const factory _EntryCategoryDto(
      {@JsonKey(name: 'id') final int id,
      @JsonKey(name: 'label') final String name}) = _$EntryCategoryDtoImpl;

  factory _EntryCategoryDto.fromJson(Map<String, dynamic> json) =
      _$EntryCategoryDtoImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  int get id;
  @override
  @JsonKey(name: 'label')
  String get name;

  /// Create a copy of EntryCategoryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntryCategoryDtoImplCopyWith<_$EntryCategoryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
