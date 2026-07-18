// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'programme_site.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgrammeSite _$ProgrammeSiteFromJson(Map<String, dynamic> json) {
  return _ProgrammeSite.fromJson(json);
}

/// @nodoc
mixin _$ProgrammeSite {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  SiteType get type => throw _privateConstructorUsedError;

  /// Serializes this ProgrammeSite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgrammeSite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgrammeSiteCopyWith<ProgrammeSite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgrammeSiteCopyWith<$Res> {
  factory $ProgrammeSiteCopyWith(
          ProgrammeSite value, $Res Function(ProgrammeSite) then) =
      _$ProgrammeSiteCopyWithImpl<$Res, ProgrammeSite>;
  @useResult
  $Res call({int id, String name, SiteType type});
}

/// @nodoc
class _$ProgrammeSiteCopyWithImpl<$Res, $Val extends ProgrammeSite>
    implements $ProgrammeSiteCopyWith<$Res> {
  _$ProgrammeSiteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgrammeSite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SiteType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgrammeSiteImplCopyWith<$Res>
    implements $ProgrammeSiteCopyWith<$Res> {
  factory _$$ProgrammeSiteImplCopyWith(
          _$ProgrammeSiteImpl value, $Res Function(_$ProgrammeSiteImpl) then) =
      __$$ProgrammeSiteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name, SiteType type});
}

/// @nodoc
class __$$ProgrammeSiteImplCopyWithImpl<$Res>
    extends _$ProgrammeSiteCopyWithImpl<$Res, _$ProgrammeSiteImpl>
    implements _$$ProgrammeSiteImplCopyWith<$Res> {
  __$$ProgrammeSiteImplCopyWithImpl(
      _$ProgrammeSiteImpl _value, $Res Function(_$ProgrammeSiteImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgrammeSite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
  }) {
    return _then(_$ProgrammeSiteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as SiteType,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgrammeSiteImpl implements _ProgrammeSite {
  const _$ProgrammeSiteImpl(
      {required this.id, required this.name, required this.type});

  factory _$ProgrammeSiteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgrammeSiteImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final SiteType type;

  @override
  String toString() {
    return 'ProgrammeSite(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgrammeSiteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, type);

  /// Create a copy of ProgrammeSite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgrammeSiteImplCopyWith<_$ProgrammeSiteImpl> get copyWith =>
      __$$ProgrammeSiteImplCopyWithImpl<_$ProgrammeSiteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgrammeSiteImplToJson(
      this,
    );
  }
}

abstract class _ProgrammeSite implements ProgrammeSite {
  const factory _ProgrammeSite(
      {required final int id,
      required final String name,
      required final SiteType type}) = _$ProgrammeSiteImpl;

  factory _ProgrammeSite.fromJson(Map<String, dynamic> json) =
      _$ProgrammeSiteImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  SiteType get type;

  /// Create a copy of ProgrammeSite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgrammeSiteImplCopyWith<_$ProgrammeSiteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
