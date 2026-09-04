// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heat_result_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HeatResultDto _$HeatResultDtoFromJson(Map<String, dynamic> json) {
  return _HeatResultDto.fromJson(json);
}

/// @nodoc
mixin _$HeatResultDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Rang')
  int? get rank => throw _privateConstructorUsedError;
  @JsonKey(name: 'isDisqualifie')
  bool get isDisqualified => throw _privateConstructorUsedError;
  @JsonKey(name: 'complement')
  String? get complement => throw _privateConstructorUsedError;
  @JsonKey(name: 'Statut')
  int? get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'engagement')
  HeatResultEntryDto? get entry => throw _privateConstructorUsedError;

  /// Serializes this HeatResultDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatResultDtoCopyWith<HeatResultDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatResultDtoCopyWith<$Res> {
  factory $HeatResultDtoCopyWith(
          HeatResultDto value, $Res Function(HeatResultDto) then) =
      _$HeatResultDtoCopyWithImpl<$Res, HeatResultDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Rang') int? rank,
      @JsonKey(name: 'isDisqualifie') bool isDisqualified,
      @JsonKey(name: 'complement') String? complement,
      @JsonKey(name: 'Statut') int? status,
      @JsonKey(name: 'engagement') HeatResultEntryDto? entry});

  $HeatResultEntryDtoCopyWith<$Res>? get entry;
}

/// @nodoc
class _$HeatResultDtoCopyWithImpl<$Res, $Val extends HeatResultDto>
    implements $HeatResultDtoCopyWith<$Res> {
  _$HeatResultDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rank = freezed,
    Object? isDisqualified = null,
    Object? complement = freezed,
    Object? status = freezed,
    Object? entry = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      isDisqualified: null == isDisqualified
          ? _value.isDisqualified
          : isDisqualified // ignore: cast_nullable_to_non_nullable
              as bool,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as HeatResultEntryDto?,
    ) as $Val);
  }

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HeatResultEntryDtoCopyWith<$Res>? get entry {
    if (_value.entry == null) {
      return null;
    }

    return $HeatResultEntryDtoCopyWith<$Res>(_value.entry!, (value) {
      return _then(_value.copyWith(entry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HeatResultDtoImplCopyWith<$Res>
    implements $HeatResultDtoCopyWith<$Res> {
  factory _$$HeatResultDtoImplCopyWith(
          _$HeatResultDtoImpl value, $Res Function(_$HeatResultDtoImpl) then) =
      __$$HeatResultDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Rang') int? rank,
      @JsonKey(name: 'isDisqualifie') bool isDisqualified,
      @JsonKey(name: 'complement') String? complement,
      @JsonKey(name: 'Statut') int? status,
      @JsonKey(name: 'engagement') HeatResultEntryDto? entry});

  @override
  $HeatResultEntryDtoCopyWith<$Res>? get entry;
}

/// @nodoc
class __$$HeatResultDtoImplCopyWithImpl<$Res>
    extends _$HeatResultDtoCopyWithImpl<$Res, _$HeatResultDtoImpl>
    implements _$$HeatResultDtoImplCopyWith<$Res> {
  __$$HeatResultDtoImplCopyWithImpl(
      _$HeatResultDtoImpl _value, $Res Function(_$HeatResultDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rank = freezed,
    Object? isDisqualified = null,
    Object? complement = freezed,
    Object? status = freezed,
    Object? entry = freezed,
  }) {
    return _then(_$HeatResultDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      isDisqualified: null == isDisqualified
          ? _value.isDisqualified
          : isDisqualified // ignore: cast_nullable_to_non_nullable
              as bool,
      complement: freezed == complement
          ? _value.complement
          : complement // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int?,
      entry: freezed == entry
          ? _value.entry
          : entry // ignore: cast_nullable_to_non_nullable
              as HeatResultEntryDto?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatResultDtoImpl implements _HeatResultDto {
  const _$HeatResultDtoImpl(
      {@JsonKey(name: 'Id') this.id = 0,
      @JsonKey(name: 'Rang') this.rank,
      @JsonKey(name: 'isDisqualifie') this.isDisqualified = false,
      @JsonKey(name: 'complement') this.complement,
      @JsonKey(name: 'Statut') this.status,
      @JsonKey(name: 'engagement') this.entry});

  factory _$HeatResultDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatResultDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'Rang')
  final int? rank;
  @override
  @JsonKey(name: 'isDisqualifie')
  final bool isDisqualified;
  @override
  @JsonKey(name: 'complement')
  final String? complement;
  @override
  @JsonKey(name: 'Statut')
  final int? status;
  @override
  @JsonKey(name: 'engagement')
  final HeatResultEntryDto? entry;

  @override
  String toString() {
    return 'HeatResultDto(id: $id, rank: $rank, isDisqualified: $isDisqualified, complement: $complement, status: $status, entry: $entry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatResultDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.isDisqualified, isDisqualified) ||
                other.isDisqualified == isDisqualified) &&
            (identical(other.complement, complement) ||
                other.complement == complement) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.entry, entry) || other.entry == entry));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, rank, isDisqualified, complement, status, entry);

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatResultDtoImplCopyWith<_$HeatResultDtoImpl> get copyWith =>
      __$$HeatResultDtoImplCopyWithImpl<_$HeatResultDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatResultDtoImplToJson(
      this,
    );
  }
}

abstract class _HeatResultDto implements HeatResultDto {
  const factory _HeatResultDto(
          {@JsonKey(name: 'Id') final int id,
          @JsonKey(name: 'Rang') final int? rank,
          @JsonKey(name: 'isDisqualifie') final bool isDisqualified,
          @JsonKey(name: 'complement') final String? complement,
          @JsonKey(name: 'Statut') final int? status,
          @JsonKey(name: 'engagement') final HeatResultEntryDto? entry}) =
      _$HeatResultDtoImpl;

  factory _HeatResultDto.fromJson(Map<String, dynamic> json) =
      _$HeatResultDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'Rang')
  int? get rank;
  @override
  @JsonKey(name: 'isDisqualifie')
  bool get isDisqualified;
  @override
  @JsonKey(name: 'complement')
  String? get complement;
  @override
  @JsonKey(name: 'Statut')
  int? get status;
  @override
  @JsonKey(name: 'engagement')
  HeatResultEntryDto? get entry;

  /// Create a copy of HeatResultDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatResultDtoImplCopyWith<_$HeatResultDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HeatResultEntryDto _$HeatResultEntryDtoFromJson(Map<String, dynamic> json) {
  return _HeatResultEntryDto.fromJson(json);
}

/// @nodoc
mixin _$HeatResultEntryDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;

  /// Serializes this HeatResultEntryDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeatResultEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatResultEntryDtoCopyWith<HeatResultEntryDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatResultEntryDtoCopyWith<$Res> {
  factory $HeatResultEntryDtoCopyWith(
          HeatResultEntryDto value, $Res Function(HeatResultEntryDto) then) =
      _$HeatResultEntryDtoCopyWithImpl<$Res, HeatResultEntryDto>;
  @useResult
  $Res call({@JsonKey(name: 'Id') int id});
}

/// @nodoc
class _$HeatResultEntryDtoCopyWithImpl<$Res, $Val extends HeatResultEntryDto>
    implements $HeatResultEntryDtoCopyWith<$Res> {
  _$HeatResultEntryDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeatResultEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HeatResultEntryDtoImplCopyWith<$Res>
    implements $HeatResultEntryDtoCopyWith<$Res> {
  factory _$$HeatResultEntryDtoImplCopyWith(_$HeatResultEntryDtoImpl value,
          $Res Function(_$HeatResultEntryDtoImpl) then) =
      __$$HeatResultEntryDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'Id') int id});
}

/// @nodoc
class __$$HeatResultEntryDtoImplCopyWithImpl<$Res>
    extends _$HeatResultEntryDtoCopyWithImpl<$Res, _$HeatResultEntryDtoImpl>
    implements _$$HeatResultEntryDtoImplCopyWith<$Res> {
  __$$HeatResultEntryDtoImplCopyWithImpl(_$HeatResultEntryDtoImpl _value,
      $Res Function(_$HeatResultEntryDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HeatResultEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
  }) {
    return _then(_$HeatResultEntryDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatResultEntryDtoImpl implements _HeatResultEntryDto {
  const _$HeatResultEntryDtoImpl({@JsonKey(name: 'Id') this.id = 0});

  factory _$HeatResultEntryDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatResultEntryDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;

  @override
  String toString() {
    return 'HeatResultEntryDto(id: $id)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatResultEntryDtoImpl &&
            (identical(other.id, id) || other.id == id));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id);

  /// Create a copy of HeatResultEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatResultEntryDtoImplCopyWith<_$HeatResultEntryDtoImpl> get copyWith =>
      __$$HeatResultEntryDtoImplCopyWithImpl<_$HeatResultEntryDtoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatResultEntryDtoImplToJson(
      this,
    );
  }
}

abstract class _HeatResultEntryDto implements HeatResultEntryDto {
  const factory _HeatResultEntryDto({@JsonKey(name: 'Id') final int id}) =
      _$HeatResultEntryDtoImpl;

  factory _HeatResultEntryDto.fromJson(Map<String, dynamic> json) =
      _$HeatResultEntryDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;

  /// Create a copy of HeatResultEntryDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatResultEntryDtoImplCopyWith<_$HeatResultEntryDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
