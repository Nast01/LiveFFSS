// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follows.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowedAthlete {

 int get participantId; String get name; String get club; List<int> get entryIds;
/// Create a copy of FollowedAthlete
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowedAthleteCopyWith<FollowedAthlete> get copyWith => _$FollowedAthleteCopyWithImpl<FollowedAthlete>(this as FollowedAthlete, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FollowedAthlete;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowedAthlete&&(identical(other.participantId, _this.participantId) || other.participantId == _this.participantId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.club, _this.club) || other.club == _this.club)&&const DeepCollectionEquality().equals(other.entryIds, _this.entryIds));
}


@override
int get hashCode {
  final _this = this as FollowedAthlete;
  return Object.hash(runtimeType,_this.participantId,_this.name,_this.club,const DeepCollectionEquality().hash(_this.entryIds));
}

@override
String toString() {
  final _this = this as FollowedAthlete;
  return 'FollowedAthlete(participantId: ${_this.participantId}, name: ${_this.name}, club: ${_this.club}, entryIds: ${_this.entryIds})';
}


}

/// @nodoc
abstract mixin class $FollowedAthleteCopyWith<$Res>  {
  factory $FollowedAthleteCopyWith(FollowedAthlete value, $Res Function(FollowedAthlete) _then) = _$FollowedAthleteCopyWithImpl;
@useResult
$Res call({
 int participantId, String name, String club, List<int> entryIds
});




}
/// @nodoc
class _$FollowedAthleteCopyWithImpl<$Res>
    implements $FollowedAthleteCopyWith<$Res> {
  _$FollowedAthleteCopyWithImpl(this._self, this._then);

  final FollowedAthlete _self;
  final $Res Function(FollowedAthlete) _then;

/// Create a copy of FollowedAthlete
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? participantId = null,Object? name = null,Object? club = null,Object? entryIds = null,}) {
  return _then(FollowedAthlete(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,entryIds: null == entryIds ? _self.entryIds : entryIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowedAthlete].
extension FollowedAthletePatterns on FollowedAthlete {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowedAthlete value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowedAthlete() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowedAthlete value)  $default,){
final _that = this;
switch (_that) {
case _FollowedAthlete():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowedAthlete value)?  $default,){
final _that = this;
switch (_that) {
case _FollowedAthlete() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int participantId,  String name,  String club,  List<int> entryIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowedAthlete() when $default != null:
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int participantId,  String name,  String club,  List<int> entryIds)  $default,) {final _that = this;
switch (_that) {
case _FollowedAthlete():
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int participantId,  String name,  String club,  List<int> entryIds)?  $default,) {final _that = this;
switch (_that) {
case _FollowedAthlete() when $default != null:
return $default(_that.participantId,_that.name,_that.club,_that.entryIds);case _:
  return null;

}
}

}

/// @nodoc


class _FollowedAthlete implements FollowedAthlete {
  const _FollowedAthlete({required this.participantId, required this.name, this.club = '',  List<int> entryIds = const <int>[]}): _entryIds = entryIds;
  

@override final  int participantId;
@override final  String name;
@override@JsonKey() final  String club;
 final  List<int> _entryIds;
@override@JsonKey() List<int> get entryIds {
  if (_entryIds is EqualUnmodifiableListView) return _entryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entryIds);
}


/// Create a copy of FollowedAthlete
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowedAthleteCopyWith<_FollowedAthlete> get copyWith => __$FollowedAthleteCopyWithImpl<_FollowedAthlete>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowedAthlete&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.name, name) || other.name == name)&&(identical(other.club, club) || other.club == club)&&const DeepCollectionEquality().equals(other.entryIds, _entryIds));
}


@override
int get hashCode {
    return Object.hash(runtimeType,participantId,name,club,const DeepCollectionEquality().hash(_entryIds));
}

@override
String toString() {
    return 'FollowedAthlete(participantId: $participantId, name: $name, club: $club, entryIds: $entryIds)';
}


}

/// @nodoc
abstract mixin class _$FollowedAthleteCopyWith<$Res> implements $FollowedAthleteCopyWith<$Res> {
  factory _$FollowedAthleteCopyWith(_FollowedAthlete value, $Res Function(_FollowedAthlete) _then) = __$FollowedAthleteCopyWithImpl;
@override @useResult
$Res call({
 int participantId, String name, String club, List<int> entryIds
});




}
/// @nodoc
class __$FollowedAthleteCopyWithImpl<$Res>
    implements _$FollowedAthleteCopyWith<$Res> {
  __$FollowedAthleteCopyWithImpl(this._self, this._then);

  final _FollowedAthlete _self;
  final $Res Function(_FollowedAthlete) _then;

/// Create a copy of FollowedAthlete
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? participantId = null,Object? name = null,Object? club = null,Object? entryIds = null,}) {
  return _then(_FollowedAthlete(
participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,entryIds: null == entryIds ? _self._entryIds : entryIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

/// @nodoc
mixin _$FollowedClub {

 int get id; String get label;
/// Create a copy of FollowedClub
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowedClubCopyWith<FollowedClub> get copyWith => _$FollowedClubCopyWithImpl<FollowedClub>(this as FollowedClub, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FollowedClub;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowedClub&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.label, _this.label) || other.label == _this.label));
}


@override
int get hashCode {
  final _this = this as FollowedClub;
  return Object.hash(runtimeType,_this.id,_this.label);
}

@override
String toString() {
  final _this = this as FollowedClub;
  return 'FollowedClub(id: ${_this.id}, label: ${_this.label})';
}


}

/// @nodoc
abstract mixin class $FollowedClubCopyWith<$Res>  {
  factory $FollowedClubCopyWith(FollowedClub value, $Res Function(FollowedClub) _then) = _$FollowedClubCopyWithImpl;
@useResult
$Res call({
 int id, String label
});




}
/// @nodoc
class _$FollowedClubCopyWithImpl<$Res>
    implements $FollowedClubCopyWith<$Res> {
  _$FollowedClubCopyWithImpl(this._self, this._then);

  final FollowedClub _self;
  final $Res Function(FollowedClub) _then;

/// Create a copy of FollowedClub
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = null,}) {
  return _then(FollowedClub(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowedClub].
extension FollowedClubPatterns on FollowedClub {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowedClub value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowedClub() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowedClub value)  $default,){
final _that = this;
switch (_that) {
case _FollowedClub():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowedClub value)?  $default,){
final _that = this;
switch (_that) {
case _FollowedClub() when $default != null:
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
case _FollowedClub() when $default != null:
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
case _FollowedClub():
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
case _FollowedClub() when $default != null:
return $default(_that.id,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _FollowedClub implements FollowedClub {
  const _FollowedClub({required this.id, required this.label});
  

@override final  int id;
@override final  String label;

/// Create a copy of FollowedClub
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowedClubCopyWith<_FollowedClub> get copyWith => __$FollowedClubCopyWithImpl<_FollowedClub>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowedClub&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,label);
}

@override
String toString() {
    return 'FollowedClub(id: $id, label: $label)';
}


}

/// @nodoc
abstract mixin class _$FollowedClubCopyWith<$Res> implements $FollowedClubCopyWith<$Res> {
  factory _$FollowedClubCopyWith(_FollowedClub value, $Res Function(_FollowedClub) _then) = __$FollowedClubCopyWithImpl;
@override @useResult
$Res call({
 int id, String label
});




}
/// @nodoc
class __$FollowedClubCopyWithImpl<$Res>
    implements _$FollowedClubCopyWith<$Res> {
  __$FollowedClubCopyWithImpl(this._self, this._then);

  final _FollowedClub _self;
  final $Res Function(_FollowedClub) _then;

/// Create a copy of FollowedClub
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = null,}) {
  return _then(_FollowedClub(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Follows {

 List<FollowedAthlete> get athletes; List<FollowedClub> get clubs;
/// Create a copy of Follows
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowsCopyWith<Follows> get copyWith => _$FollowsCopyWithImpl<Follows>(this as Follows, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Follows;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Follows&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&const DeepCollectionEquality().equals(other.clubs, _this.clubs));
}


@override
int get hashCode {
  final _this = this as Follows;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.athletes),const DeepCollectionEquality().hash(_this.clubs));
}

@override
String toString() {
  final _this = this as Follows;
  return 'Follows(athletes: ${_this.athletes}, clubs: ${_this.clubs})';
}


}

/// @nodoc
abstract mixin class $FollowsCopyWith<$Res>  {
  factory $FollowsCopyWith(Follows value, $Res Function(Follows) _then) = _$FollowsCopyWithImpl;
@useResult
$Res call({
 List<FollowedAthlete> athletes, List<FollowedClub> clubs
});




}
/// @nodoc
class _$FollowsCopyWithImpl<$Res>
    implements $FollowsCopyWith<$Res> {
  _$FollowsCopyWithImpl(this._self, this._then);

  final Follows _self;
  final $Res Function(Follows) _then;

/// Create a copy of Follows
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? athletes = null,Object? clubs = null,}) {
  return _then(Follows(
athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<FollowedAthlete>,clubs: null == clubs ? _self.clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<FollowedClub>,
  ));
}

}


/// Adds pattern-matching-related methods to [Follows].
extension FollowsPatterns on Follows {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Follows value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Follows() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Follows value)  $default,){
final _that = this;
switch (_that) {
case _Follows():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Follows value)?  $default,){
final _that = this;
switch (_that) {
case _Follows() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<FollowedAthlete> athletes,  List<FollowedClub> clubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Follows() when $default != null:
return $default(_that.athletes,_that.clubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<FollowedAthlete> athletes,  List<FollowedClub> clubs)  $default,) {final _that = this;
switch (_that) {
case _Follows():
return $default(_that.athletes,_that.clubs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<FollowedAthlete> athletes,  List<FollowedClub> clubs)?  $default,) {final _that = this;
switch (_that) {
case _Follows() when $default != null:
return $default(_that.athletes,_that.clubs);case _:
  return null;

}
}

}

/// @nodoc


class _Follows extends Follows {
  const _Follows({ List<FollowedAthlete> athletes = const <FollowedAthlete>[],  List<FollowedClub> clubs = const <FollowedClub>[]}): _athletes = athletes,_clubs = clubs,super._();
  

 final  List<FollowedAthlete> _athletes;
@override@JsonKey() List<FollowedAthlete> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

 final  List<FollowedClub> _clubs;
@override@JsonKey() List<FollowedClub> get clubs {
  if (_clubs is EqualUnmodifiableListView) return _clubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clubs);
}


/// Create a copy of Follows
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowsCopyWith<_Follows> get copyWith => __$FollowsCopyWithImpl<_Follows>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Follows&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&const DeepCollectionEquality().equals(other.clubs, _clubs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_athletes),const DeepCollectionEquality().hash(_clubs));
}

@override
String toString() {
    return 'Follows(athletes: $athletes, clubs: $clubs)';
}


}

/// @nodoc
abstract mixin class _$FollowsCopyWith<$Res> implements $FollowsCopyWith<$Res> {
  factory _$FollowsCopyWith(_Follows value, $Res Function(_Follows) _then) = __$FollowsCopyWithImpl;
@override @useResult
$Res call({
 List<FollowedAthlete> athletes, List<FollowedClub> clubs
});




}
/// @nodoc
class __$FollowsCopyWithImpl<$Res>
    implements _$FollowsCopyWith<$Res> {
  __$FollowsCopyWithImpl(this._self, this._then);

  final _Follows _self;
  final $Res Function(_Follows) _then;

/// Create a copy of Follows
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? athletes = null,Object? clubs = null,}) {
  return _then(_Follows(
athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<FollowedAthlete>,clubs: null == clubs ? _self._clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<FollowedClub>,
  ));
}


}

// dart format on
