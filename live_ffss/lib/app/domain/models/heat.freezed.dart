// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Heat _$HeatFromJson(Map<String, dynamic> json) {
  return _Heat.fromJson(json);
}

/// @nodoc
mixin _$Heat {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  bool get done => throw _privateConstructorUsedError;
  int get number => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HeatCopyWith<Heat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatCopyWith<$Res> {
  factory $HeatCopyWith(Heat value, $Res Function(Heat) then) =
      _$HeatCopyWithImpl<$Res, Heat>;
  @useResult
  $Res call({int id, String name, bool done, int number});
}

/// @nodoc
class _$HeatCopyWithImpl<$Res, $Val extends Heat>
    implements $HeatCopyWith<$Res> {
  _$HeatCopyWithImpl(this._value, this._then);

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
abstract class _$$HeatImplCopyWith<$Res> implements $HeatCopyWith<$Res> {
  factory _$$HeatImplCopyWith(
          _$HeatImpl value, $Res Function(_$HeatImpl) then) =
      __$$HeatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, bool done, int number});
}

/// @nodoc
class __$$HeatImplCopyWithImpl<$Res>
    extends _$HeatCopyWithImpl<$Res, _$HeatImpl>
    implements _$$HeatImplCopyWith<$Res> {
  __$$HeatImplCopyWithImpl(_$HeatImpl _value, $Res Function(_$HeatImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? done = null,
    Object? number = null,
  }) {
    return _then(_$HeatImpl(
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
class _$HeatImpl implements _Heat {
  const _$HeatImpl(
      {required this.id,
      required this.name,
      required this.done,
      required this.number});

  factory _$HeatImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final bool done;
  @override
  final int number;

  @override
  String toString() {
    return 'Heat(id: $id, name: $name, done: $done, number: $number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatImpl &&
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
  _$$HeatImplCopyWith<_$HeatImpl> get copyWith =>
      __$$HeatImplCopyWithImpl<_$HeatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatImplToJson(
      this,
    );
  }
}

abstract class _Heat implements Heat {
  const factory _Heat(
      {required final int id,
      required final String name,
      required final bool done,
      required final int number}) = _$HeatImpl;

  factory _Heat.fromJson(Map<String, dynamic> json) = _$HeatImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  bool get done;
  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$$HeatImplCopyWith<_$HeatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
