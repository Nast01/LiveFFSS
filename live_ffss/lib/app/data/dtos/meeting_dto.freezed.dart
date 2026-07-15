// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meeting_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeetingDto _$MeetingDtoFromJson(Map<String, dynamic> json) {
  return _MeetingDto.fromJson(json);
}

/// @nodoc
mixin _$MeetingDto {
  @JsonKey(name: 'Id')
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'Nom')
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'Description')
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'Jour')
  String get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'Debut')
  String get beginHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'Fin')
  String get endHour => throw _privateConstructorUsedError;
  @JsonKey(name: 'creneaus')
  List<SlotDto> get slots => throw _privateConstructorUsedError;

  /// Serializes this MeetingDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingDtoCopyWith<MeetingDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingDtoCopyWith<$Res> {
  factory $MeetingDtoCopyWith(
          MeetingDto value, $Res Function(MeetingDto) then) =
      _$MeetingDtoCopyWithImpl<$Res, MeetingDto>;
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Description') String description,
      @JsonKey(name: 'Jour') String date,
      @JsonKey(name: 'Debut') String beginHour,
      @JsonKey(name: 'Fin') String endHour,
      @JsonKey(name: 'creneaus') List<SlotDto> slots});
}

/// @nodoc
class _$MeetingDtoCopyWithImpl<$Res, $Val extends MeetingDto>
    implements $MeetingDtoCopyWith<$Res> {
  _$MeetingDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? date = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? slots = null,
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
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as String,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value.slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<SlotDto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MeetingDtoImplCopyWith<$Res>
    implements $MeetingDtoCopyWith<$Res> {
  factory _$$MeetingDtoImplCopyWith(
          _$MeetingDtoImpl value, $Res Function(_$MeetingDtoImpl) then) =
      __$$MeetingDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'Id') int id,
      @JsonKey(name: 'Nom') String name,
      @JsonKey(name: 'Description') String description,
      @JsonKey(name: 'Jour') String date,
      @JsonKey(name: 'Debut') String beginHour,
      @JsonKey(name: 'Fin') String endHour,
      @JsonKey(name: 'creneaus') List<SlotDto> slots});
}

/// @nodoc
class __$$MeetingDtoImplCopyWithImpl<$Res>
    extends _$MeetingDtoCopyWithImpl<$Res, _$MeetingDtoImpl>
    implements _$$MeetingDtoImplCopyWith<$Res> {
  __$$MeetingDtoImplCopyWithImpl(
      _$MeetingDtoImpl _value, $Res Function(_$MeetingDtoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? date = null,
    Object? beginHour = null,
    Object? endHour = null,
    Object? slots = null,
  }) {
    return _then(_$MeetingDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      beginHour: null == beginHour
          ? _value.beginHour
          : beginHour // ignore: cast_nullable_to_non_nullable
              as String,
      endHour: null == endHour
          ? _value.endHour
          : endHour // ignore: cast_nullable_to_non_nullable
              as String,
      slots: null == slots
          ? _value._slots
          : slots // ignore: cast_nullable_to_non_nullable
              as List<SlotDto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MeetingDtoImpl implements _MeetingDto {
  const _$MeetingDtoImpl(
      {@JsonKey(name: 'Id') required this.id,
      @JsonKey(name: 'Nom') required this.name,
      @JsonKey(name: 'Description') required this.description,
      @JsonKey(name: 'Jour') required this.date,
      @JsonKey(name: 'Debut') required this.beginHour,
      @JsonKey(name: 'Fin') required this.endHour,
      @JsonKey(name: 'creneaus') final List<SlotDto> slots = const <SlotDto>[]})
      : _slots = slots;

  factory _$MeetingDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeetingDtoImplFromJson(json);

  @override
  @JsonKey(name: 'Id')
  final int id;
  @override
  @JsonKey(name: 'Nom')
  final String name;
  @override
  @JsonKey(name: 'Description')
  final String description;
  @override
  @JsonKey(name: 'Jour')
  final String date;
  @override
  @JsonKey(name: 'Debut')
  final String beginHour;
  @override
  @JsonKey(name: 'Fin')
  final String endHour;
  final List<SlotDto> _slots;
  @override
  @JsonKey(name: 'creneaus')
  List<SlotDto> get slots {
    if (_slots is EqualUnmodifiableListView) return _slots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_slots);
  }

  @override
  String toString() {
    return 'MeetingDto(id: $id, name: $name, description: $description, date: $date, beginHour: $beginHour, endHour: $endHour, slots: $slots)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.beginHour, beginHour) ||
                other.beginHour == beginHour) &&
            (identical(other.endHour, endHour) || other.endHour == endHour) &&
            const DeepCollectionEquality().equals(other._slots, _slots));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, description, date,
      beginHour, endHour, const DeepCollectionEquality().hash(_slots));

  /// Create a copy of MeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingDtoImplCopyWith<_$MeetingDtoImpl> get copyWith =>
      __$$MeetingDtoImplCopyWithImpl<_$MeetingDtoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeetingDtoImplToJson(
      this,
    );
  }
}

abstract class _MeetingDto implements MeetingDto {
  const factory _MeetingDto(
      {@JsonKey(name: 'Id') required final int id,
      @JsonKey(name: 'Nom') required final String name,
      @JsonKey(name: 'Description') required final String description,
      @JsonKey(name: 'Jour') required final String date,
      @JsonKey(name: 'Debut') required final String beginHour,
      @JsonKey(name: 'Fin') required final String endHour,
      @JsonKey(name: 'creneaus') final List<SlotDto> slots}) = _$MeetingDtoImpl;

  factory _MeetingDto.fromJson(Map<String, dynamic> json) =
      _$MeetingDtoImpl.fromJson;

  @override
  @JsonKey(name: 'Id')
  int get id;
  @override
  @JsonKey(name: 'Nom')
  String get name;
  @override
  @JsonKey(name: 'Description')
  String get description;
  @override
  @JsonKey(name: 'Jour')
  String get date;
  @override
  @JsonKey(name: 'Debut')
  String get beginHour;
  @override
  @JsonKey(name: 'Fin')
  String get endHour;
  @override
  @JsonKey(name: 'creneaus')
  List<SlotDto> get slots;

  /// Create a copy of MeetingDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingDtoImplCopyWith<_$MeetingDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
