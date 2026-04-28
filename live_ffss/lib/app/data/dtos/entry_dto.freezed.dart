// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EntryDto _$EntryDtoFromJson(Map<String, dynamic> json) {
  return _EntryDto.fromJson(json);
}

/// @nodoc
mixin _$EntryDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'categorie')
  CategoryDto get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'Statut')
  int get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'statutLabel')
  String get statusLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'performance')
  int get entryTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'performanceLabel')
  String get entryTimeLabel => throw _privateConstructorUsedError;
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EntryDtoCopyWith<EntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntryDtoCopyWith<$Res> {
  factory $EntryDtoCopyWith(EntryDto value, $Res Function(EntryDto) then) =
      _$EntryDtoCopyWithImpl<$Res, EntryDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'categorie') CategoryDto category,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'performance') int entryTime,
      @JsonKey(name: 'performanceLabel') String entryTimeLabel,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes});

  $CategoryDtoCopyWith<$Res> get category;
}

/// @nodoc
class _$EntryDtoCopyWithImpl<$Res, $Val extends EntryDto>
    implements $EntryDtoCopyWith<$Res> {
  _$EntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? athletes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryDto,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      athletes: null == athletes
          ? _value.athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CategoryDtoCopyWith<$Res> get category {
    return $CategoryDtoCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EntryDtoImplCopyWith<$Res>
    implements $EntryDtoCopyWith<$Res> {
  factory _$$EntryDtoImplCopyWith(
          _$EntryDtoImpl value, $Res Function(_$EntryDtoImpl) then) =
      __$$EntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'categorie') CategoryDto category,
      @JsonKey(name: 'Statut') int status,
      @JsonKey(name: 'statutLabel') String statusLabel,
      @JsonKey(name: 'performance') int entryTime,
      @JsonKey(name: 'performanceLabel') String entryTimeLabel,
      @JsonKey(name: 'athletes') List<AthleteDto> athletes});

  @override
  $CategoryDtoCopyWith<$Res> get category;
}

/// @nodoc
class __$$EntryDtoImplCopyWithImpl<$Res>
    extends _$EntryDtoCopyWithImpl<$Res, _$EntryDtoImpl>
    implements _$$EntryDtoImplCopyWith<$Res> {
  __$$EntryDtoImplCopyWithImpl(
      _$EntryDtoImpl _value, $Res Function(_$EntryDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? category = null,
    Object? status = null,
    Object? statusLabel = null,
    Object? entryTime = null,
    Object? entryTimeLabel = null,
    Object? athletes = null,
  }) {
    return _then(_$EntryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as CategoryDto,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
      statusLabel: null == statusLabel
          ? _value.statusLabel
          : statusLabel // ignore: cast_nullable_to_non_nullable
              as String,
      entryTime: null == entryTime
          ? _value.entryTime
          : entryTime // ignore: cast_nullable_to_non_nullable
              as int,
      entryTimeLabel: null == entryTimeLabel
          ? _value.entryTimeLabel
          : entryTimeLabel // ignore: cast_nullable_to_non_nullable
              as String,
      athletes: null == athletes
          ? _value._athletes
          : athletes // ignore: cast_nullable_to_non_nullable
              as List<AthleteDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EntryDtoImpl implements _EntryDto {
  const _$EntryDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'categorie') required this.category,
      @JsonKey(name: 'Statut') required this.status,
      @JsonKey(name: 'statutLabel') required this.statusLabel,
      @JsonKey(name: 'performance') required this.entryTime,
      @JsonKey(name: 'performanceLabel') required this.entryTimeLabel,
      @JsonKey(name: 'athletes')
      final List<AthleteDto> athletes = const <AthleteDto>[]})
      : _athletes = athletes;

  factory _$EntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntryDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'categorie')
  final CategoryDto category;
  @override
  @JsonKey(name: 'Statut')
  final int status;
  @override
  @JsonKey(name: 'statutLabel')
  final String statusLabel;
  @override
  @JsonKey(name: 'performance')
  final int entryTime;
  @override
  @JsonKey(name: 'performanceLabel')
  final String entryTimeLabel;
  final List<AthleteDto> _athletes;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes {
    if (_athletes is EqualUnmodifiableListView) return _athletes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_athletes);
  }

  @override
  String toString() {
    return 'EntryDto(id: $id, category: $category, status: $status, statusLabel: $statusLabel, entryTime: $entryTime, entryTimeLabel: $entryTimeLabel, athletes: $athletes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntryDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusLabel, statusLabel) ||
                other.statusLabel == statusLabel) &&
            (identical(other.entryTime, entryTime) ||
                other.entryTime == entryTime) &&
            (identical(other.entryTimeLabel, entryTimeLabel) ||
                other.entryTimeLabel == entryTimeLabel) &&
            const DeepCollectionEquality().equals(other._athletes, _athletes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      category,
      status,
      statusLabel,
      entryTime,
      entryTimeLabel,
      const DeepCollectionEquality().hash(_athletes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EntryDtoImplCopyWith<_$EntryDtoImpl> get copyWith =>
      __$$EntryDtoImplCopyWithImpl<_$EntryDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntryDtoImplToJson(
      this,
    );
  }
}

abstract class _EntryDto implements EntryDto {
  const factory _EntryDto(
      {@JsonKey(name: 'Id') required final int id,
      @JsonKey(name: 'categorie') required final CategoryDto category,
      @JsonKey(name: 'Statut') required final int status,
      @JsonKey(name: 'statutLabel') required final String statusLabel,
      @JsonKey(name: 'performance') required final int entryTime,
      @JsonKey(name: 'performanceLabel') required final String entryTimeLabel,
      @JsonKey(name: 'athletes')
      final List<AthleteDto> athletes}) = _$EntryDtoImpl;

  factory _EntryDto.fromJson(Map<String, dynamic> json) =
      _$EntryDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'categorie')
  CategoryDto get category;
  @override
  @JsonKey(name: 'Statut')
  int get status;
  @override
  @JsonKey(name: 'statutLabel')
  String get statusLabel;
  @override
  @JsonKey(name: 'performance')
  int get entryTime;
  @override
  @JsonKey(name: 'performanceLabel')
  String get entryTimeLabel;
  @override
  @JsonKey(name: 'athletes')
  List<AthleteDto> get athletes;
  @override
  @JsonKey(ignore: true)
  _$$EntryDtoImplCopyWith<_$EntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
