// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition_me_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompetitionMeDto {

 List<Object?> get roles;@JsonKey(name: 'licencie', readValue: readMap) Object? get licensee;@JsonKey(name: 'officiel', readValue: readMap) Object? get official;@JsonKey(name: 'referent_sportif', readValue: readList) List<Object?> get refereeClubs;
/// Create a copy of CompetitionMeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionMeDtoCopyWith<CompetitionMeDto> get copyWith => _$CompetitionMeDtoCopyWithImpl<CompetitionMeDto>(this as CompetitionMeDto, _$identity);

  /// Serializes this CompetitionMeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CompetitionMeDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionMeDto&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&const DeepCollectionEquality().equals(other.licensee, _this.licensee)&&const DeepCollectionEquality().equals(other.official, _this.official)&&const DeepCollectionEquality().equals(other.refereeClubs, _this.refereeClubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CompetitionMeDto;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.roles),const DeepCollectionEquality().hash(_this.licensee),const DeepCollectionEquality().hash(_this.official),const DeepCollectionEquality().hash(_this.refereeClubs));
}

@override
String toString() {
  final _this = this as CompetitionMeDto;
  return 'CompetitionMeDto(roles: ${_this.roles}, licensee: ${_this.licensee}, official: ${_this.official}, refereeClubs: ${_this.refereeClubs})';
}


}

/// @nodoc
abstract mixin class $CompetitionMeDtoCopyWith<$Res>  {
  factory $CompetitionMeDtoCopyWith(CompetitionMeDto value, $Res Function(CompetitionMeDto) _then) = _$CompetitionMeDtoCopyWithImpl;
@useResult
$Res call({
 List<Object?> roles,@JsonKey(name: 'licencie', readValue: readMap) Object? licensee,@JsonKey(name: 'officiel', readValue: readMap) Object? official,@JsonKey(name: 'referent_sportif', readValue: readList) List<Object?> refereeClubs
});




}
/// @nodoc
class _$CompetitionMeDtoCopyWithImpl<$Res>
    implements $CompetitionMeDtoCopyWith<$Res> {
  _$CompetitionMeDtoCopyWithImpl(this._self, this._then);

  final CompetitionMeDto _self;
  final $Res Function(CompetitionMeDto) _then;

/// Create a copy of CompetitionMeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roles = null,Object? licensee = freezed,Object? official = freezed,Object? refereeClubs = null,}) {
  return _then(CompetitionMeDto(
roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<Object?>,licensee: freezed == licensee ? _self.licensee : licensee ,official: freezed == official ? _self.official : official ,refereeClubs: null == refereeClubs ? _self.refereeClubs : refereeClubs // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [CompetitionMeDto].
extension CompetitionMeDtoPatterns on CompetitionMeDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionMeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionMeDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionMeDto value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionMeDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionMeDto value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionMeDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Object?> roles, @JsonKey(name: 'licencie', readValue: readMap)  Object? licensee, @JsonKey(name: 'officiel', readValue: readMap)  Object? official, @JsonKey(name: 'referent_sportif', readValue: readList)  List<Object?> refereeClubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionMeDto() when $default != null:
return $default(_that.roles,_that.licensee,_that.official,_that.refereeClubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Object?> roles, @JsonKey(name: 'licencie', readValue: readMap)  Object? licensee, @JsonKey(name: 'officiel', readValue: readMap)  Object? official, @JsonKey(name: 'referent_sportif', readValue: readList)  List<Object?> refereeClubs)  $default,) {final _that = this;
switch (_that) {
case _CompetitionMeDto():
return $default(_that.roles,_that.licensee,_that.official,_that.refereeClubs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Object?> roles, @JsonKey(name: 'licencie', readValue: readMap)  Object? licensee, @JsonKey(name: 'officiel', readValue: readMap)  Object? official, @JsonKey(name: 'referent_sportif', readValue: readList)  List<Object?> refereeClubs)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionMeDto() when $default != null:
return $default(_that.roles,_that.licensee,_that.official,_that.refereeClubs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CompetitionMeDto implements CompetitionMeDto {
  const _CompetitionMeDto({ List<Object?> roles = const <Object?>[], @JsonKey(name: 'licencie', readValue: readMap) this.licensee, @JsonKey(name: 'officiel', readValue: readMap) this.official, @JsonKey(name: 'referent_sportif', readValue: readList)  List<Object?> refereeClubs = const <Object?>[]}): _roles = roles,_refereeClubs = refereeClubs;
  factory _CompetitionMeDto.fromJson(Map<String, dynamic> json) => _$CompetitionMeDtoFromJson(json);

 final  List<Object?> _roles;
@override@JsonKey() List<Object?> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override@JsonKey(name: 'licencie', readValue: readMap) final  Object? licensee;
@override@JsonKey(name: 'officiel', readValue: readMap) final  Object? official;
 final  List<Object?> _refereeClubs;
@override@JsonKey(name: 'referent_sportif', readValue: readList) List<Object?> get refereeClubs {
  if (_refereeClubs is EqualUnmodifiableListView) return _refereeClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_refereeClubs);
}


/// Create a copy of CompetitionMeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionMeDtoCopyWith<_CompetitionMeDto> get copyWith => __$CompetitionMeDtoCopyWithImpl<_CompetitionMeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CompetitionMeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionMeDto&&const DeepCollectionEquality().equals(other.roles, _roles)&&const DeepCollectionEquality().equals(other.licensee, licensee)&&const DeepCollectionEquality().equals(other.official, official)&&const DeepCollectionEquality().equals(other.refereeClubs, _refereeClubs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_roles),const DeepCollectionEquality().hash(licensee),const DeepCollectionEquality().hash(official),const DeepCollectionEquality().hash(_refereeClubs));
}

@override
String toString() {
    return 'CompetitionMeDto(roles: $roles, licensee: $licensee, official: $official, refereeClubs: $refereeClubs)';
}


}

/// @nodoc
abstract mixin class _$CompetitionMeDtoCopyWith<$Res> implements $CompetitionMeDtoCopyWith<$Res> {
  factory _$CompetitionMeDtoCopyWith(_CompetitionMeDto value, $Res Function(_CompetitionMeDto) _then) = __$CompetitionMeDtoCopyWithImpl;
@override @useResult
$Res call({
 List<Object?> roles,@JsonKey(name: 'licencie', readValue: readMap) Object? licensee,@JsonKey(name: 'officiel', readValue: readMap) Object? official,@JsonKey(name: 'referent_sportif', readValue: readList) List<Object?> refereeClubs
});




}
/// @nodoc
class __$CompetitionMeDtoCopyWithImpl<$Res>
    implements _$CompetitionMeDtoCopyWith<$Res> {
  __$CompetitionMeDtoCopyWithImpl(this._self, this._then);

  final _CompetitionMeDto _self;
  final $Res Function(_CompetitionMeDto) _then;

/// Create a copy of CompetitionMeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roles = null,Object? licensee = freezed,Object? official = freezed,Object? refereeClubs = null,}) {
  return _then(_CompetitionMeDto(
roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<Object?>,licensee: freezed == licensee ? _self.licensee : licensee ,official: freezed == official ? _self.official : official ,refereeClubs: null == refereeClubs ? _self._refereeClubs : refereeClubs // ignore: cast_nullable_to_non_nullable
as List<Object?>,
  ));
}


}


/// @nodoc
mixin _$LicencieDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;
/// Create a copy of LicencieDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LicencieDtoCopyWith<LicencieDto> get copyWith => _$LicencieDtoCopyWithImpl<LicencieDto>(this as LicencieDto, _$identity);

  /// Serializes this LicencieDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LicencieDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LicencieDto&&(identical(other.id, _this.id) || other.id == _this.id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LicencieDto;
  return Object.hash(runtimeType,_this.id);
}

@override
String toString() {
  final _this = this as LicencieDto;
  return 'LicencieDto(id: ${_this.id})';
}


}

/// @nodoc
abstract mixin class $LicencieDtoCopyWith<$Res>  {
  factory $LicencieDtoCopyWith(LicencieDto value, $Res Function(LicencieDto) _then) = _$LicencieDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id
});




}
/// @nodoc
class _$LicencieDtoCopyWithImpl<$Res>
    implements $LicencieDtoCopyWith<$Res> {
  _$LicencieDtoCopyWithImpl(this._self, this._then);

  final LicencieDto _self;
  final $Res Function(LicencieDto) _then;

/// Create a copy of LicencieDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,}) {
  return _then(LicencieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [LicencieDto].
extension LicencieDtoPatterns on LicencieDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LicencieDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LicencieDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LicencieDto value)  $default,){
final _that = this;
switch (_that) {
case _LicencieDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LicencieDto value)?  $default,){
final _that = this;
switch (_that) {
case _LicencieDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LicencieDto() when $default != null:
return $default(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id)  $default,) {final _that = this;
switch (_that) {
case _LicencieDto():
return $default(_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id)?  $default,) {final _that = this;
switch (_that) {
case _LicencieDto() when $default != null:
return $default(_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LicencieDto implements LicencieDto {
  const _LicencieDto({@JsonKey(name: 'id', readValue: readInt) this.id});
  factory _LicencieDto.fromJson(Map<String, dynamic> json) => _$LicencieDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;

/// Create a copy of LicencieDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LicencieDtoCopyWith<_LicencieDto> get copyWith => __$LicencieDtoCopyWithImpl<_LicencieDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LicencieDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LicencieDto&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id);
}

@override
String toString() {
    return 'LicencieDto(id: $id)';
}


}

/// @nodoc
abstract mixin class _$LicencieDtoCopyWith<$Res> implements $LicencieDtoCopyWith<$Res> {
  factory _$LicencieDtoCopyWith(_LicencieDto value, $Res Function(_LicencieDto) _then) = __$LicencieDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id
});




}
/// @nodoc
class __$LicencieDtoCopyWithImpl<$Res>
    implements _$LicencieDtoCopyWith<$Res> {
  __$LicencieDtoCopyWithImpl(this._self, this._then);

  final _LicencieDto _self;
  final $Res Function(_LicencieDto) _then;

/// Create a copy of LicencieDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,}) {
  return _then(_LicencieDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$OfficialRoleDto {

@JsonKey(name: 'niveau') String? get level;@JsonKey(name: 'niveauLabel') String? get levelLabel;@JsonKey(name: 'principal') bool? get principal;
/// Create a copy of OfficialRoleDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfficialRoleDtoCopyWith<OfficialRoleDto> get copyWith => _$OfficialRoleDtoCopyWithImpl<OfficialRoleDto>(this as OfficialRoleDto, _$identity);

  /// Serializes this OfficialRoleDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as OfficialRoleDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfficialRoleDto&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.levelLabel, _this.levelLabel) || other.levelLabel == _this.levelLabel)&&(identical(other.principal, _this.principal) || other.principal == _this.principal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as OfficialRoleDto;
  return Object.hash(runtimeType,_this.level,_this.levelLabel,_this.principal);
}

@override
String toString() {
  final _this = this as OfficialRoleDto;
  return 'OfficialRoleDto(level: ${_this.level}, levelLabel: ${_this.levelLabel}, principal: ${_this.principal})';
}


}

/// @nodoc
abstract mixin class $OfficialRoleDtoCopyWith<$Res>  {
  factory $OfficialRoleDtoCopyWith(OfficialRoleDto value, $Res Function(OfficialRoleDto) _then) = _$OfficialRoleDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'niveau') String? level,@JsonKey(name: 'niveauLabel') String? levelLabel,@JsonKey(name: 'principal') bool? principal
});




}
/// @nodoc
class _$OfficialRoleDtoCopyWithImpl<$Res>
    implements $OfficialRoleDtoCopyWith<$Res> {
  _$OfficialRoleDtoCopyWithImpl(this._self, this._then);

  final OfficialRoleDto _self;
  final $Res Function(OfficialRoleDto) _then;

/// Create a copy of OfficialRoleDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = freezed,Object? levelLabel = freezed,Object? principal = freezed,}) {
  return _then(OfficialRoleDto(
level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,levelLabel: freezed == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String?,principal: freezed == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfficialRoleDto].
extension OfficialRoleDtoPatterns on OfficialRoleDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfficialRoleDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfficialRoleDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfficialRoleDto value)  $default,){
final _that = this;
switch (_that) {
case _OfficialRoleDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfficialRoleDto value)?  $default,){
final _that = this;
switch (_that) {
case _OfficialRoleDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'niveauLabel')  String? levelLabel, @JsonKey(name: 'principal')  bool? principal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfficialRoleDto() when $default != null:
return $default(_that.level,_that.levelLabel,_that.principal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'niveauLabel')  String? levelLabel, @JsonKey(name: 'principal')  bool? principal)  $default,) {final _that = this;
switch (_that) {
case _OfficialRoleDto():
return $default(_that.level,_that.levelLabel,_that.principal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'niveau')  String? level, @JsonKey(name: 'niveauLabel')  String? levelLabel, @JsonKey(name: 'principal')  bool? principal)?  $default,) {final _that = this;
switch (_that) {
case _OfficialRoleDto() when $default != null:
return $default(_that.level,_that.levelLabel,_that.principal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OfficialRoleDto implements OfficialRoleDto {
  const _OfficialRoleDto({@JsonKey(name: 'niveau') this.level, @JsonKey(name: 'niveauLabel') this.levelLabel, @JsonKey(name: 'principal') this.principal});
  factory _OfficialRoleDto.fromJson(Map<String, dynamic> json) => _$OfficialRoleDtoFromJson(json);

@override@JsonKey(name: 'niveau') final  String? level;
@override@JsonKey(name: 'niveauLabel') final  String? levelLabel;
@override@JsonKey(name: 'principal') final  bool? principal;

/// Create a copy of OfficialRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfficialRoleDtoCopyWith<_OfficialRoleDto> get copyWith => __$OfficialRoleDtoCopyWithImpl<_OfficialRoleDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfficialRoleDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfficialRoleDto&&(identical(other.level, level) || other.level == level)&&(identical(other.levelLabel, levelLabel) || other.levelLabel == levelLabel)&&(identical(other.principal, principal) || other.principal == principal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,level,levelLabel,principal);
}

@override
String toString() {
    return 'OfficialRoleDto(level: $level, levelLabel: $levelLabel, principal: $principal)';
}


}

/// @nodoc
abstract mixin class _$OfficialRoleDtoCopyWith<$Res> implements $OfficialRoleDtoCopyWith<$Res> {
  factory _$OfficialRoleDtoCopyWith(_OfficialRoleDto value, $Res Function(_OfficialRoleDto) _then) = __$OfficialRoleDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'niveau') String? level,@JsonKey(name: 'niveauLabel') String? levelLabel,@JsonKey(name: 'principal') bool? principal
});




}
/// @nodoc
class __$OfficialRoleDtoCopyWithImpl<$Res>
    implements _$OfficialRoleDtoCopyWith<$Res> {
  __$OfficialRoleDtoCopyWithImpl(this._self, this._then);

  final _OfficialRoleDto _self;
  final $Res Function(_OfficialRoleDto) _then;

/// Create a copy of OfficialRoleDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = freezed,Object? levelLabel = freezed,Object? principal = freezed,}) {
  return _then(_OfficialRoleDto(
level: freezed == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String?,levelLabel: freezed == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String?,principal: freezed == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}


/// @nodoc
mixin _$ClubRefDto {

@JsonKey(name: 'id', readValue: readInt) int? get id;@JsonKey(name: 'label') String? get label;
/// Create a copy of ClubRefDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubRefDtoCopyWith<ClubRefDto> get copyWith => _$ClubRefDtoCopyWithImpl<ClubRefDto>(this as ClubRefDto, _$identity);

  /// Serializes this ClubRefDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ClubRefDto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubRefDto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ClubRefDto;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as ClubRefDto;
  return 'ClubRefDto(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $ClubRefDtoCopyWith<$Res>  {
  factory $ClubRefDtoCopyWith(ClubRefDto value, $Res Function(ClubRefDto) _then) = _$ClubRefDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class _$ClubRefDtoCopyWithImpl<$Res>
    implements $ClubRefDtoCopyWith<$Res> {
  _$ClubRefDtoCopyWithImpl(this._self, this._then);

  final ClubRefDto _self;
  final $Res Function(ClubRefDto) _then;

/// Create a copy of ClubRefDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? label = freezed,}) {
  return _then(ClubRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubRefDto].
extension ClubRefDtoPatterns on ClubRefDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubRefDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubRefDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubRefDto value)  $default,){
final _that = this;
switch (_that) {
case _ClubRefDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubRefDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClubRefDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubRefDto() when $default != null:
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label)  $default,) {final _that = this;
switch (_that) {
case _ClubRefDto():
return $default(_that.id,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id', readValue: readInt)  int? id, @JsonKey(name: 'label')  String? label)?  $default,) {final _that = this;
switch (_that) {
case _ClubRefDto() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubRefDto implements ClubRefDto {
  const _ClubRefDto({@JsonKey(name: 'id', readValue: readInt) this.id, @JsonKey(name: 'label') this.label});
  factory _ClubRefDto.fromJson(Map<String, dynamic> json) => _$ClubRefDtoFromJson(json);

@override@JsonKey(name: 'id', readValue: readInt) final  int? id;
@override@JsonKey(name: 'label') final  String? label;

/// Create a copy of ClubRefDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubRefDtoCopyWith<_ClubRefDto> get copyWith => __$ClubRefDtoCopyWithImpl<_ClubRefDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubRefDtoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubRefDto&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'ClubRefDto(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ClubRefDtoCopyWith<$Res> implements $ClubRefDtoCopyWith<$Res> {
  factory _$ClubRefDtoCopyWith(_ClubRefDto value, $Res Function(_ClubRefDto) _then) = __$ClubRefDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id', readValue: readInt) int? id,@JsonKey(name: 'label') String? label
});




}
/// @nodoc
class __$ClubRefDtoCopyWithImpl<$Res>
    implements _$ClubRefDtoCopyWith<$Res> {
  __$ClubRefDtoCopyWithImpl(this._self, this._then);

  final _ClubRefDto _self;
  final $Res Function(_ClubRefDto) _then;

/// Create a copy of ClubRefDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? label = freezed,}) {
  return _then(_ClubRefDto(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
