// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heat_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HeatDto _$HeatDtoFromJson(Map<String, dynamic> json) {
  return _HeatDto.fromJson(json);
}

/// @nodoc
mixin _$HeatDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fini')
  bool get done => throw _privateConstructorUsedError;
  @JsonKey(name: 'Numero', readValue: _readNumber)
  int get number => throw _privateConstructorUsedError;
  @JsonKey(name: 'UpdatedAt')
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'Debut')
  String? get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fin')
  String? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'epreuve')
  RaceDto? get race => throw _privateConstructorUsedError;
  @JsonKey(name: 'resultats')
  List<ResultDto> get results => throw _privateConstructorUsedError;

  /// Serializes this HeatDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatDtoCopyWith<HeatDto> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatDtoCopyWith<$Res> {
  factory $HeatDtoCopyWith(HeatDto value, $Res Function(HeatDto) then) =
      _$HeatDtoCopyWithImpl<$Res, HeatDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Fini') bool done,
      @JsonKey(name: 'Numero', readValue: _readNumber) int number,
      @JsonKey(name: 'UpdatedAt') String? updatedAt,
      @JsonKey(name: 'Debut') String? startDate,
      @JsonKey(name: 'Fin') String? endDate,
      @JsonKey(name: 'epreuve') RaceDto? race,
      @JsonKey(name: 'resultats') List<ResultDto> results});

  $RaceDtoCopyWith<$Res>? get race;
}

/// @nodoc
class _$HeatDtoCopyWithImpl<$Res, $Val extends HeatDto>
    implements $HeatDtoCopyWith<$Res> {
  _$HeatDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
    Object? updatedAt = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? race = freezed,
    Object? results = null,
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
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      race: freezed == race
          ? _value.race
          : race // ignore: cast_nullable_to_non_nullable
              as RaceDto?,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<ResultDto>,
    ) as $Val);
  }

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RaceDtoCopyWith<$Res>? get race {
    if (_value.race == null) {
      return null;
    }

    return $RaceDtoCopyWith<$Res>(_value.race!, (value) {
      return _then(_value.copyWith(race: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HeatDtoImplCopyWith<$Res> implements $HeatDtoCopyWith<$Res> {
  factory _$$HeatDtoImplCopyWith(
          _$HeatDtoImpl value, $Res Function(_$HeatDtoImpl) then) =
      __$$HeatDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Fini') bool done,
      @JsonKey(name: 'Numero', readValue: _readNumber) int number,
      @JsonKey(name: 'UpdatedAt') String? updatedAt,
      @JsonKey(name: 'Debut') String? startDate,
      @JsonKey(name: 'Fin') String? endDate,
      @JsonKey(name: 'epreuve') RaceDto? race,
      @JsonKey(name: 'resultats') List<ResultDto> results});

  @override
  $RaceDtoCopyWith<$Res>? get race;
}

/// @nodoc
class __$$HeatDtoImplCopyWithImpl<$Res>
    extends _$HeatDtoCopyWithImpl<$Res, _$HeatDtoImpl>
    implements _$$HeatDtoImplCopyWith<$Res> {
  __$$HeatDtoImplCopyWithImpl(
      _$HeatDtoImpl _value, $Res Function(_$HeatDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
    Object? updatedAt = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? race = freezed,
    Object? results = null,
  }) {
    return _then(_$HeatDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _value.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      race: freezed == race
          ? _value.race
          : race // ignore: cast_nullable_to_non_nullable
              as RaceDto?,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<ResultDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatDtoImpl implements _HeatDto {
  const _$HeatDtoImpl(
      {@JsonKey(name: 'Id') this.id = 0,
      @JsonKey(name: 'Nom') this.name = '',
      @JsonKey(name: 'Fini') this.done = false,
      @JsonKey(name: 'Numero', readValue: _readNumber) this.number = 0,
      @JsonKey(name: 'UpdatedAt') this.updatedAt,
      @JsonKey(name: 'Debut') this.startDate,
      @JsonKey(name: 'Fin') this.endDate,
      @JsonKey(name: 'epreuve') this.race,
      @JsonKey(name: 'resultats')
      final List<ResultDto> results = const <ResultDto>[]})
      : _results = results;

  factory _$HeatDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'Fini')
  final bool done;
  @override
  @JsonKey(name: 'Numero', readValue: _readNumber)
  final int number;
  @override
  @JsonKey(name: 'UpdatedAt')
  final String? updatedAt;
  @override
  @JsonKey(name: 'Debut')
  final String? startDate;
  @override
  @JsonKey(name: 'Fin')
  final String? endDate;
  @override
  @JsonKey(name: 'epreuve')
  final RaceDto? race;
  final List<ResultDto> _results;
  @override
  @JsonKey(name: 'resultats')
  List<ResultDto> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  String toString() {
    return 'HeatDto(id: $id, name: $name, done: $done, number: $number, updatedAt: $updatedAt, startDate: $startDate, endDate: $endDate, race: $race, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.race, race) || other.race == race) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      done,
      number,
      updatedAt,
      startDate,
      endDate,
      race,
      const DeepCollectionEquality().hash(_results));

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatDtoImplCopyWith<_$HeatDtoImpl> get copyWith =>
      __$$HeatDtoImplCopyWithImpl<_$HeatDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatDtoImplToJson(
      this,
    );
  }
}

abstract class _HeatDto implements HeatDto {
  const factory _HeatDto(
          {@JsonKey(name: 'Id') final int id,
          @JsonKey(name: 'Nom') final String name,
          @JsonKey(name: 'Fini') final bool done,
          @JsonKey(name: 'Numero', readValue: _readNumber) final int number,
          @JsonKey(name: 'UpdatedAt') final String? updatedAt,
          @JsonKey(name: 'Debut') final String? startDate,
          @JsonKey(name: 'Fin') final String? endDate,
          @JsonKey(name: 'epreuve') final RaceDto? race,
          @JsonKey(name: 'resultats') final List<ResultDto> results}) =
      _$HeatDtoImpl;

  factory _HeatDto.fromJson(Map<String, dynamic> json) = _$HeatDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'Fini')
  bool get done;
  @override
  @JsonKey(name: 'Numero', readValue: _readNumber)
  int get number;
  @override
  @JsonKey(name: 'UpdatedAt')
  String? get updatedAt;
  @override
  @JsonKey(name: 'Debut')
  String? get startDate;
  @override
  @JsonKey(name: 'Fin')
  String? get endDate;
  @override
  @JsonKey(name: 'epreuve')
  RaceDto? get race;
  @override
  @JsonKey(name: 'resultats')
  List<ResultDto> get results;

  /// Create a copy of HeatDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatDtoImplCopyWith<_$HeatDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
