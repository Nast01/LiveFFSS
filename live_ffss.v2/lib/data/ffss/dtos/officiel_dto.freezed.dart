// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'officiel_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OfficielDto {

@JsonKey(name: 'Id', readValue: readInt) int? get id;@JsonKey(name: 'Prenom') String? get firstName;@JsonKey(name: 'Nom') String? get lastName;@JsonKey(name: 'Niveau') String? get level;@JsonKey(name: 'Principal') bool? get principal;@JsonKey(name: 'Jours', readValue: readList) List<Object?>? get days;@JsonKey(name: 'joursLabel') String? get daysLabel;@JsonKey(name: 'officielClubLabel') String? get club;
/// Create a copy of OfficielDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfficielDtoCopyWith<OfficielDto> get copyWith => _$OfficielDtoCopyWithImpl<OfficielDto>(this as OfficielDto, _$identity);

  /// Serializes this OfficielDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfficielDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfficielDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.principal, _this.principal) || other.principal == _this.principal)&&const DeepCollectionEquality().equals(other.days, _this.days)&&(identical(other.daysLabel, _this.daysLabel) || other.daysLabel == _this.daysLabel)&&(identical(other.club, _this.club) || other.club == _this.club));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfficielDto;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.level,_this.principal,const DeepCollectionEquality().hash(_this.days),_this.daysLabel,_this.club);
}

@override
String toString() {
  final _this = this as OfficielDto;
  return 'OfficielDto(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, level: ${_this.level}, principal: ${_this.principal}, days: ${_this.days}, daysLabel: ${_this.daysLabel}, club: ${_this.club})';
}


}

/// @nodoc
abstract mixin class $OfficielDtoCopyWith<$Res>  {
  factory $OfficielDtoCopyWith(OfficielDto value, $Res Function(OfficielDto) _then) = _$OfficielDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Prenom') String? firstName,@JsonKey(name: 'Nom') String? lastName,@JsonKey(name: 'Niveau') String? level,@JsonKey(name: 'Principal') bool? principal,@JsonKey(name: 'Jours', readValue: readList) List<Object?>? days,@JsonKey(name: 'joursLabel') String? daysLabel,@JsonKey(name: 'officielClubLabel') String? club
});




}
/// @nodoc
class _$OfficielDtoCopyWithImpl<$Res>
    implements $OfficielDtoCopyWith<$Res> {
  _$OfficielDtoCopyWithImpl(this._self, this._then);

  final OfficielDto _self;
  final $Res Function(OfficielDto) _then;

/// Create a copy of OfficielDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? level = freezed,Object? principal = freezed,Object? days = freezed,Object? daysLabel = freezed,Object? club = freezed,}) {
  return _then(OfficielDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,principal: freezed == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool?,days: freezed == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<Object?>?,daysLabel: freezed == daysLabel ? _self.daysLabel : daysLabel // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfficielDto].
extension OfficielDtoPatterns on OfficielDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfficielDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfficielDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfficielDto value)  $default,){
final _that = this;
switch (_that) {
case _OfficielDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfficielDto value)?  $default,){
final _that = this;
switch (_that) {
case _OfficielDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Niveau')  String? level, @JsonKey(name: 'Principal')  bool? principal, @JsonKey(name: 'Jours', readValue: readList)  List<Object?>? days, @JsonKey(name: 'joursLabel')  String? daysLabel, @JsonKey(name: 'officielClubLabel')  String? club)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfficielDto() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Niveau')  String? level, @JsonKey(name: 'Principal')  bool? principal, @JsonKey(name: 'Jours', readValue: readList)  List<Object?>? days, @JsonKey(name: 'joursLabel')  String? daysLabel, @JsonKey(name: 'officielClubLabel')  String? club)  $default,) {final _that = this;
switch (_that) {
case _OfficielDto():
return $default(_that.id,_that.firstName,_that.lastName,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'Id', readValue: readInt)  int? id, @JsonKey(name: 'Prenom')  String? firstName, @JsonKey(name: 'Nom')  String? lastName, @JsonKey(name: 'Niveau')  String? level, @JsonKey(name: 'Principal')  bool? principal, @JsonKey(name: 'Jours', readValue: readList)  List<Object?>? days, @JsonKey(name: 'joursLabel')  String? daysLabel, @JsonKey(name: 'officielClubLabel')  String? club)?  $default,) {final _that = this;
switch (_that) {
case _OfficielDto() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfficielDto implements OfficielDto {
  const _OfficielDto({@JsonKey(name: 'Id', readValue: readInt) this.id, @JsonKey(name: 'Prenom') this.firstName, @JsonKey(name: 'Nom') this.lastName, @JsonKey(name: 'Niveau') this.level, @JsonKey(name: 'Principal') this.principal, @JsonKey(name: 'Jours', readValue: readList)  List<Object?>? days, @JsonKey(name: 'joursLabel') this.daysLabel, @JsonKey(name: 'officielClubLabel') this.club}): _days = days;
  factory _OfficielDto.fromJson(Map<String, dynamic> json) => _$OfficielDtoFromJson(json);

@override@JsonKey(name: 'Id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'Prenom') final  String? firstName;
@override@JsonKey(name: 'Nom') final  String? lastName;
@override@JsonKey(name: 'Niveau') final  String? level;
@override@JsonKey(name: 'Principal') final  bool? principal;
 final  List<Object?>? _days;
@override@JsonKey(name: 'Jours', readValue: readList) List<Object?>? get days {
  final value = _days;
  if (value == null) return null;
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'joursLabel') final  String? daysLabel;
@override@JsonKey(name: 'officielClubLabel') final  String? club;

/// Create a copy of OfficielDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfficielDtoCopyWith<_OfficielDto> get copyWith => __$OfficielDtoCopyWithImpl<_OfficielDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfficielDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfficielDto&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.level, level) || other.level == level)&&(identical(other.principal, principal) || other.principal == principal)&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.daysLabel, daysLabel) || other.daysLabel == daysLabel)&&(identical(other.club, club) || other.club == club));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,level,principal,const DeepCollectionEquality().hash(_days),daysLabel,club);
}

@override
String toString() {
    return 'OfficielDto(id: $id, firstName: $firstName, lastName: $lastName, level: $level, principal: $principal, days: $days, daysLabel: $daysLabel, club: $club)';
}


}

/// @nodoc
abstract mixin class _$OfficielDtoCopyWith<$Res> implements $OfficielDtoCopyWith<$Res> {
  factory _$OfficielDtoCopyWith(_OfficielDto value, $Res Function(_OfficielDto) _then) = __$OfficielDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'Id', readValue: readInt) int? id,@JsonKey(name: 'Prenom') String? firstName,@JsonKey(name: 'Nom') String? lastName,@JsonKey(name: 'Niveau') String? level,@JsonKey(name: 'Principal') bool? principal,@JsonKey(name: 'Jours', readValue: readList) List<Object?>? days,@JsonKey(name: 'joursLabel') String? daysLabel,@JsonKey(name: 'officielClubLabel') String? club
});




}
/// @nodoc
class __$OfficielDtoCopyWithImpl<$Res>
    implements _$OfficielDtoCopyWith<$Res> {
  __$OfficielDtoCopyWithImpl(this._self, this._then);

  final _OfficielDto _self;
  final $Res Function(_OfficielDto) _then;

/// Create a copy of OfficielDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? firstName = freezed,Object? lastName = freezed,Object? level = freezed,Object? principal = freezed,Object? days = freezed,Object? daysLabel = freezed,Object? club = freezed,}) {
  return _then(_OfficielDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,principal: freezed == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool?,days: freezed == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<Object?>?,daysLabel: freezed == daysLabel ? _self.daysLabel : daysLabel // ignore: cast_nullable_to_non_nullable
as String?,club: freezed == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
