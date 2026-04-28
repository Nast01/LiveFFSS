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

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
      @JsonKey(name: 'Numero', readValue: _readNumber) int number});
}

/// @nodoc
class _$HeatDtoCopyWithImpl<$Res, $Val extends HeatDto>
    implements $HeatDtoCopyWith<$Res> {
  _$HeatDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
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
    ) as $Val);
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
      @JsonKey(name: 'Numero', readValue: _readNumber) int number});
}

/// @nodoc
class __$$HeatDtoImplCopyWithImpl<$Res>
    extends _$HeatDtoCopyWithImpl<$Res, _$HeatDtoImpl>
    implements _$$HeatDtoImplCopyWith<$Res> {
  __$$HeatDtoImplCopyWithImpl(
      _$HeatDtoImpl _value, $Res Function(_$HeatDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatDtoImpl implements _HeatDto {
  const _$HeatDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'Fini') required this.done,
      @JsonKey(name: 'Numero', readValue: _readNumber) required this.number});

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
  String toString() {
    return 'HeatDto(id: $id, name: $name, done: $done, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.number, number) || other.number == number));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, done, number);

  @JsonKey(ignore: true)
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
      {@JsonKey(name: 'Id') required final int id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'Fini') required final bool done,
      @JsonKey(name: 'Numero', readValue: _readNumber)
      required final int number}) = _$HeatDtoImpl;

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
  @JsonKey(ignore: true)
  _$$HeatDtoImplCopyWith<_$HeatDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
