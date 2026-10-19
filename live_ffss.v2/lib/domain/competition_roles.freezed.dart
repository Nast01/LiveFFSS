// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'competition_roles.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompetitionRoles {

/// Les codes de rôle (`public`, `licencie`, `officiel`…).
 List<String> get roles;/// L'identifiant du licencié du compte, qui relie ses engagements.
 int? get licenseeId; OfficialRole? get official;/// Les clubs dont le compte est référent sportif.
 List<ClubRef> get refereeClubs;
/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionRolesCopyWith<CompetitionRoles> get copyWith => _$CompetitionRolesCopyWithImpl<CompetitionRoles>(this as CompetitionRoles, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompetitionRoles;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionRoles&&const DeepCollectionEquality().equals(other.roles, _this.roles)&&(identical(other.licenseeId, _this.licenseeId) || other.licenseeId == _this.licenseeId)&&(identical(other.official, _this.official) || other.official == _this.official)&&const DeepCollectionEquality().equals(other.refereeClubs, _this.refereeClubs));
}


@override
int get hashCode {
  final _this = this as CompetitionRoles;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.roles),_this.licenseeId,_this.official,const DeepCollectionEquality().hash(_this.refereeClubs));
}

@override
String toString() {
  final _this = this as CompetitionRoles;
  return 'CompetitionRoles(roles: ${_this.roles}, licenseeId: ${_this.licenseeId}, official: ${_this.official}, refereeClubs: ${_this.refereeClubs})';
}


}

/// @nodoc
abstract mixin class $CompetitionRolesCopyWith<$Res>  {
  factory $CompetitionRolesCopyWith(CompetitionRoles value, $Res Function(CompetitionRoles) _then) = _$CompetitionRolesCopyWithImpl;
@useResult
$Res call({
 List<String> roles, int? licenseeId, OfficialRole? official, List<ClubRef> refereeClubs
});


$OfficialRoleCopyWith<$Res>? get official;

}
/// @nodoc
class _$CompetitionRolesCopyWithImpl<$Res>
    implements $CompetitionRolesCopyWith<$Res> {
  _$CompetitionRolesCopyWithImpl(this._self, this._then);

  final CompetitionRoles _self;
  final $Res Function(CompetitionRoles) _then;

/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? roles = null,Object? licenseeId = freezed,Object? official = freezed,Object? refereeClubs = null,}) {
  return _then(CompetitionRoles(
roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,licenseeId: freezed == licenseeId ? _self.licenseeId : licenseeId // ignore: cast_nullable_to_non_nullable
as int?,official: freezed == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as OfficialRole?,refereeClubs: null == refereeClubs ? _self.refereeClubs : refereeClubs // ignore: cast_nullable_to_non_nullable
as List<ClubRef>,
  ));
}
/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfficialRoleCopyWith<$Res>? get official {
    if (_self.official == null) {
    return null;
  }

  return $OfficialRoleCopyWith<$Res>(_self.official!, (value) {
    return _then(_self.copyWith(official: value));
  });
}
}


/// Adds pattern-matching-related methods to [CompetitionRoles].
extension CompetitionRolesPatterns on CompetitionRoles {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionRoles value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionRoles() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionRoles value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionRoles():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionRoles value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionRoles() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> roles,  int? licenseeId,  OfficialRole? official,  List<ClubRef> refereeClubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionRoles() when $default != null:
return $default(_that.roles,_that.licenseeId,_that.official,_that.refereeClubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> roles,  int? licenseeId,  OfficialRole? official,  List<ClubRef> refereeClubs)  $default,) {final _that = this;
switch (_that) {
case _CompetitionRoles():
return $default(_that.roles,_that.licenseeId,_that.official,_that.refereeClubs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> roles,  int? licenseeId,  OfficialRole? official,  List<ClubRef> refereeClubs)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionRoles() when $default != null:
return $default(_that.roles,_that.licenseeId,_that.official,_that.refereeClubs);case _:
  return null;

}
}

}

/// @nodoc


class _CompetitionRoles extends CompetitionRoles {
  const _CompetitionRoles({required  List<String> roles, this.licenseeId, this.official,  List<ClubRef> refereeClubs = const <ClubRef>[]}): _roles = roles,_refereeClubs = refereeClubs,super._();
  

/// Les codes de rôle (`public`, `licencie`, `officiel`…).
 final  List<String> _roles;
/// Les codes de rôle (`public`, `licencie`, `officiel`…).
@override List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

/// L'identifiant du licencié du compte, qui relie ses engagements.
@override final  int? licenseeId;
@override final  OfficialRole? official;
/// Les clubs dont le compte est référent sportif.
 final  List<ClubRef> _refereeClubs;
/// Les clubs dont le compte est référent sportif.
@override@JsonKey() List<ClubRef> get refereeClubs {
  if (_refereeClubs is EqualUnmodifiableListView) return _refereeClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_refereeClubs);
}


/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionRolesCopyWith<_CompetitionRoles> get copyWith => __$CompetitionRolesCopyWithImpl<_CompetitionRoles>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionRoles&&const DeepCollectionEquality().equals(other.roles, _roles)&&(identical(other.licenseeId, licenseeId) || other.licenseeId == licenseeId)&&(identical(other.official, official) || other.official == official)&&const DeepCollectionEquality().equals(other.refereeClubs, _refereeClubs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_roles),licenseeId,official,const DeepCollectionEquality().hash(_refereeClubs));
}

@override
String toString() {
    return 'CompetitionRoles(roles: $roles, licenseeId: $licenseeId, official: $official, refereeClubs: $refereeClubs)';
}


}

/// @nodoc
abstract mixin class _$CompetitionRolesCopyWith<$Res> implements $CompetitionRolesCopyWith<$Res> {
  factory _$CompetitionRolesCopyWith(_CompetitionRoles value, $Res Function(_CompetitionRoles) _then) = __$CompetitionRolesCopyWithImpl;
@override @useResult
$Res call({
 List<String> roles, int? licenseeId, OfficialRole? official, List<ClubRef> refereeClubs
});


@override $OfficialRoleCopyWith<$Res>? get official;

}
/// @nodoc
class __$CompetitionRolesCopyWithImpl<$Res>
    implements _$CompetitionRolesCopyWith<$Res> {
  __$CompetitionRolesCopyWithImpl(this._self, this._then);

  final _CompetitionRoles _self;
  final $Res Function(_CompetitionRoles) _then;

/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? roles = null,Object? licenseeId = freezed,Object? official = freezed,Object? refereeClubs = null,}) {
  return _then(_CompetitionRoles(
roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,licenseeId: freezed == licenseeId ? _self.licenseeId : licenseeId // ignore: cast_nullable_to_non_nullable
as int?,official: freezed == official ? _self.official : official // ignore: cast_nullable_to_non_nullable
as OfficialRole?,refereeClubs: null == refereeClubs ? _self._refereeClubs : refereeClubs // ignore: cast_nullable_to_non_nullable
as List<ClubRef>,
  ));
}

/// Create a copy of CompetitionRoles
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OfficialRoleCopyWith<$Res>? get official {
    if (_self.official == null) {
    return null;
  }

  return $OfficialRoleCopyWith<$Res>(_self.official!, (value) {
    return _then(_self.copyWith(official: value));
  });
}
}

/// @nodoc
mixin _$OfficialRole {

/// Le code du niveau (`A`, `B`, `C`…).
 String get level; String get levelLabel; bool get principal;
/// Create a copy of OfficialRole
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfficialRoleCopyWith<OfficialRole> get copyWith => _$OfficialRoleCopyWithImpl<OfficialRole>(this as OfficialRole, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OfficialRole;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfficialRole&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.levelLabel, _this.levelLabel) || other.levelLabel == _this.levelLabel)&&(identical(other.principal, _this.principal) || other.principal == _this.principal));
}


@override
int get hashCode {
  final _this = this as OfficialRole;
  return Object.hash(runtimeType,_this.level,_this.levelLabel,_this.principal);
}

@override
String toString() {
  final _this = this as OfficialRole;
  return 'OfficialRole(level: ${_this.level}, levelLabel: ${_this.levelLabel}, principal: ${_this.principal})';
}


}

/// @nodoc
abstract mixin class $OfficialRoleCopyWith<$Res>  {
  factory $OfficialRoleCopyWith(OfficialRole value, $Res Function(OfficialRole) _then) = _$OfficialRoleCopyWithImpl;
@useResult
$Res call({
 String level, String levelLabel, bool principal
});




}
/// @nodoc
class _$OfficialRoleCopyWithImpl<$Res>
    implements $OfficialRoleCopyWith<$Res> {
  _$OfficialRoleCopyWithImpl(this._self, this._then);

  final OfficialRole _self;
  final $Res Function(OfficialRole) _then;

/// Create a copy of OfficialRole
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? level = null,Object? levelLabel = null,Object? principal = null,}) {
  return _then(OfficialRole(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,levelLabel: null == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [OfficialRole].
extension OfficialRolePatterns on OfficialRole {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfficialRole value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfficialRole() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfficialRole value)  $default,){
final _that = this;
switch (_that) {
case _OfficialRole():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfficialRole value)?  $default,){
final _that = this;
switch (_that) {
case _OfficialRole() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String level,  String levelLabel,  bool principal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfficialRole() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String level,  String levelLabel,  bool principal)  $default,) {final _that = this;
switch (_that) {
case _OfficialRole():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String level,  String levelLabel,  bool principal)?  $default,) {final _that = this;
switch (_that) {
case _OfficialRole() when $default != null:
return $default(_that.level,_that.levelLabel,_that.principal);case _:
  return null;

}
}

}

/// @nodoc


class _OfficialRole implements OfficialRole {
  const _OfficialRole({required this.level, required this.levelLabel, required this.principal});
  

/// Le code du niveau (`A`, `B`, `C`…).
@override final  String level;
@override final  String levelLabel;
@override final  bool principal;

/// Create a copy of OfficialRole
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfficialRoleCopyWith<_OfficialRole> get copyWith => __$OfficialRoleCopyWithImpl<_OfficialRole>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfficialRole&&(identical(other.level, level) || other.level == level)&&(identical(other.levelLabel, levelLabel) || other.levelLabel == levelLabel)&&(identical(other.principal, principal) || other.principal == principal));
}


@override
int get hashCode {
    return Object.hash(runtimeType,level,levelLabel,principal);
}

@override
String toString() {
    return 'OfficialRole(level: $level, levelLabel: $levelLabel, principal: $principal)';
}


}

/// @nodoc
abstract mixin class _$OfficialRoleCopyWith<$Res> implements $OfficialRoleCopyWith<$Res> {
  factory _$OfficialRoleCopyWith(_OfficialRole value, $Res Function(_OfficialRole) _then) = __$OfficialRoleCopyWithImpl;
@override @useResult
$Res call({
 String level, String levelLabel, bool principal
});




}
/// @nodoc
class __$OfficialRoleCopyWithImpl<$Res>
    implements _$OfficialRoleCopyWith<$Res> {
  __$OfficialRoleCopyWithImpl(this._self, this._then);

  final _OfficialRole _self;
  final $Res Function(_OfficialRole) _then;

/// Create a copy of OfficialRole
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? level = null,Object? levelLabel = null,Object? principal = null,}) {
  return _then(_OfficialRole(
level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,levelLabel: null == levelLabel ? _self.levelLabel : levelLabel // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ClubRef {

 int get id; String get label;
/// Create a copy of ClubRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubRefCopyWith<ClubRef> get copyWith => _$ClubRefCopyWithImpl<ClubRef>(this as ClubRef, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubRef;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubRef&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as ClubRef;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as ClubRef;
  return 'ClubRef(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $ClubRefCopyWith<$Res>  {
  factory $ClubRefCopyWith(ClubRef value, $Res Function(ClubRef) _then) = _$ClubRefCopyWithImpl;
@useResult
$Res call({
 int id, String label
});




}
/// @nodoc
class _$ClubRefCopyWithImpl<$Res>
    implements $ClubRefCopyWith<$Res> {
  _$ClubRefCopyWithImpl(this._self, this._then);

  final ClubRef _self;
  final $Res Function(ClubRef) _then;

/// Create a copy of ClubRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(ClubRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubRef].
extension ClubRefPatterns on ClubRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubRef value)  $default,){
final _that = this;
switch (_that) {
case _ClubRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubRef value)?  $default,){
final _that = this;
switch (_that) {
case _ClubRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubRef() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String label)  $default,) {final _that = this;
switch (_that) {
case _ClubRef():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ClubRef() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ClubRef implements ClubRef {
  const _ClubRef({required this.id, required this.label});
  

@override final  int id;
@override final  String label;

/// Create a copy of ClubRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubRefCopyWith<_ClubRef> get copyWith => __$ClubRefCopyWithImpl<_ClubRef>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubRef&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'ClubRef(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ClubRefCopyWith<$Res> implements $ClubRefCopyWith<$Res> {
  factory _$ClubRefCopyWith(_ClubRef value, $Res Function(_ClubRef) _then) = __$ClubRefCopyWithImpl;
@override @useResult
$Res call({
 int id, String label
});




}
/// @nodoc
class __$ClubRefCopyWithImpl<$Res>
    implements _$ClubRefCopyWith<$Res> {
  __$ClubRefCopyWithImpl(this._self, this._then);

  final _ClubRef _self;
  final $Res Function(_ClubRef) _then;

/// Create a copy of ClubRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_ClubRef(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
