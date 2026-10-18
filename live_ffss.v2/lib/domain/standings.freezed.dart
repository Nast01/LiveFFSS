// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'standings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubStanding {

 int get rank; String get club; int get points;/// Points du club précédent moins les siens ; nul pour le premier.
 int? get gapToPrevious;
/// Create a copy of ClubStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubStandingCopyWith<ClubStanding> get copyWith => _$ClubStandingCopyWithImpl<ClubStanding>(this as ClubStanding, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubStanding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubStanding&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.gapToPrevious, _this.gapToPrevious) || other.gapToPrevious == _this.gapToPrevious));
}


@override
int get hashCode {
  final _this = this as ClubStanding;
  return Object.hash(runtimeType,_this.rank,_this.club,_this.points,_this.gapToPrevious);
}

@override
String toString() {
  final _this = this as ClubStanding;
  return 'ClubStanding(rank: ${_this.rank}, club: ${_this.club}, points: ${_this.points}, gapToPrevious: ${_this.gapToPrevious})';
}


}

/// @nodoc
abstract mixin class $ClubStandingCopyWith<$Res>  {
  factory $ClubStandingCopyWith(ClubStanding value, $Res Function(ClubStanding) _then) = _$ClubStandingCopyWithImpl;
@useResult
$Res call({
 int rank, String club, int points, int? gapToPrevious
});




}
/// @nodoc
class _$ClubStandingCopyWithImpl<$Res>
    implements $ClubStandingCopyWith<$Res> {
  _$ClubStandingCopyWithImpl(this._self, this._then);

  final ClubStanding _self;
  final $Res Function(ClubStanding) _then;

/// Create a copy of ClubStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? club = null,Object? points = null,Object? gapToPrevious = freezed,}) {
  return _then(ClubStanding(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,gapToPrevious: freezed == gapToPrevious ? _self.gapToPrevious : gapToPrevious // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ClubStanding].
extension ClubStandingPatterns on ClubStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubStanding value)  $default,){
final _that = this;
switch (_that) {
case _ClubStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubStanding value)?  $default,){
final _that = this;
switch (_that) {
case _ClubStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  String club,  int points,  int? gapToPrevious)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubStanding() when $default != null:
return $default(_that.rank,_that.club,_that.points,_that.gapToPrevious);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  String club,  int points,  int? gapToPrevious)  $default,) {final _that = this;
switch (_that) {
case _ClubStanding():
return $default(_that.rank,_that.club,_that.points,_that.gapToPrevious);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  String club,  int points,  int? gapToPrevious)?  $default,) {final _that = this;
switch (_that) {
case _ClubStanding() when $default != null:
return $default(_that.rank,_that.club,_that.points,_that.gapToPrevious);case _:
  return null;

}
}

}

/// @nodoc


class _ClubStanding implements ClubStanding {
  const _ClubStanding({required this.rank, required this.club, required this.points, this.gapToPrevious});
  

@override final  int rank;
@override final  String club;
@override final  int points;
/// Points du club précédent moins les siens ; nul pour le premier.
@override final  int? gapToPrevious;

/// Create a copy of ClubStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubStandingCopyWith<_ClubStanding> get copyWith => __$ClubStandingCopyWithImpl<_ClubStanding>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubStanding&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.club, club) || other.club == club)&&(identical(other.points, points) || other.points == points)&&(identical(other.gapToPrevious, gapToPrevious) || other.gapToPrevious == gapToPrevious));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rank,club,points,gapToPrevious);
}

@override
String toString() {
    return 'ClubStanding(rank: $rank, club: $club, points: $points, gapToPrevious: $gapToPrevious)';
}


}

/// @nodoc
abstract mixin class _$ClubStandingCopyWith<$Res> implements $ClubStandingCopyWith<$Res> {
  factory _$ClubStandingCopyWith(_ClubStanding value, $Res Function(_ClubStanding) _then) = __$ClubStandingCopyWithImpl;
@override @useResult
$Res call({
 int rank, String club, int points, int? gapToPrevious
});




}
/// @nodoc
class __$ClubStandingCopyWithImpl<$Res>
    implements _$ClubStandingCopyWith<$Res> {
  __$ClubStandingCopyWithImpl(this._self, this._then);

  final _ClubStanding _self;
  final $Res Function(_ClubStanding) _then;

/// Create a copy of ClubStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? club = null,Object? points = null,Object? gapToPrevious = freezed,}) {
  return _then(_ClubStanding(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,gapToPrevious: freezed == gapToPrevious ? _self.gapToPrevious : gapToPrevious // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$LicenseeStanding {

 int get rank; int get athleteId; String get name; String get club; Gender get gender; String get categoryName; int get points;/// Lignes de classement de l'athlète, comptées ou non.
 int get races;
/// Create a copy of LicenseeStanding
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LicenseeStandingCopyWith<LicenseeStanding> get copyWith => _$LicenseeStandingCopyWithImpl<LicenseeStanding>(this as LicenseeStanding, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LicenseeStanding;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LicenseeStanding&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.athleteId, _this.athleteId) || other.athleteId == _this.athleteId)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.races, _this.races) || other.races == _this.races));
}


@override
int get hashCode {
  final _this = this as LicenseeStanding;
  return Object.hash(runtimeType,_this.rank,_this.athleteId,_this.name,_this.club,_this.gender,_this.categoryName,_this.points,_this.races);
}

@override
String toString() {
  final _this = this as LicenseeStanding;
  return 'LicenseeStanding(rank: ${_this.rank}, athleteId: ${_this.athleteId}, name: ${_this.name}, club: ${_this.club}, gender: ${_this.gender}, categoryName: ${_this.categoryName}, points: ${_this.points}, races: ${_this.races})';
}


}

/// @nodoc
abstract mixin class $LicenseeStandingCopyWith<$Res>  {
  factory $LicenseeStandingCopyWith(LicenseeStanding value, $Res Function(LicenseeStanding) _then) = _$LicenseeStandingCopyWithImpl;
@useResult
$Res call({
 int rank, int athleteId, String name, String club, Gender gender, String categoryName, int points, int races
});




}
/// @nodoc
class _$LicenseeStandingCopyWithImpl<$Res>
    implements $LicenseeStandingCopyWith<$Res> {
  _$LicenseeStandingCopyWithImpl(this._self, this._then);

  final LicenseeStanding _self;
  final $Res Function(LicenseeStanding) _then;

/// Create a copy of LicenseeStanding
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rank = null,Object? athleteId = null,Object? name = null,Object? club = null,Object? gender = null,Object? categoryName = null,Object? points = null,Object? races = null,}) {
  return _then(LicenseeStanding(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,races: null == races ? _self.races : races // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LicenseeStanding].
extension LicenseeStandingPatterns on LicenseeStanding {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LicenseeStanding value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LicenseeStanding() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LicenseeStanding value)  $default,){
final _that = this;
switch (_that) {
case _LicenseeStanding():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LicenseeStanding value)?  $default,){
final _that = this;
switch (_that) {
case _LicenseeStanding() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int rank,  int athleteId,  String name,  String club,  Gender gender,  String categoryName,  int points,  int races)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LicenseeStanding() when $default != null:
return $default(_that.rank,_that.athleteId,_that.name,_that.club,_that.gender,_that.categoryName,_that.points,_that.races);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int rank,  int athleteId,  String name,  String club,  Gender gender,  String categoryName,  int points,  int races)  $default,) {final _that = this;
switch (_that) {
case _LicenseeStanding():
return $default(_that.rank,_that.athleteId,_that.name,_that.club,_that.gender,_that.categoryName,_that.points,_that.races);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int rank,  int athleteId,  String name,  String club,  Gender gender,  String categoryName,  int points,  int races)?  $default,) {final _that = this;
switch (_that) {
case _LicenseeStanding() when $default != null:
return $default(_that.rank,_that.athleteId,_that.name,_that.club,_that.gender,_that.categoryName,_that.points,_that.races);case _:
  return null;

}
}

}

/// @nodoc


class _LicenseeStanding implements LicenseeStanding {
  const _LicenseeStanding({required this.rank, required this.athleteId, required this.name, required this.club, required this.gender, required this.categoryName, required this.points, required this.races});
  

@override final  int rank;
@override final  int athleteId;
@override final  String name;
@override final  String club;
@override final  Gender gender;
@override final  String categoryName;
@override final  int points;
/// Lignes de classement de l'athlète, comptées ou non.
@override final  int races;

/// Create a copy of LicenseeStanding
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LicenseeStandingCopyWith<_LicenseeStanding> get copyWith => __$LicenseeStandingCopyWithImpl<_LicenseeStanding>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LicenseeStanding&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.athleteId, athleteId) || other.athleteId == athleteId)&&(identical(other.name, name) || other.name == name)&&(identical(other.club, club) || other.club == club)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.points, points) || other.points == points)&&(identical(other.races, races) || other.races == races));
}


@override
int get hashCode {
    return Object.hash(runtimeType,rank,athleteId,name,club,gender,categoryName,points,races);
}

@override
String toString() {
    return 'LicenseeStanding(rank: $rank, athleteId: $athleteId, name: $name, club: $club, gender: $gender, categoryName: $categoryName, points: $points, races: $races)';
}


}

/// @nodoc
abstract mixin class _$LicenseeStandingCopyWith<$Res> implements $LicenseeStandingCopyWith<$Res> {
  factory _$LicenseeStandingCopyWith(_LicenseeStanding value, $Res Function(_LicenseeStanding) _then) = __$LicenseeStandingCopyWithImpl;
@override @useResult
$Res call({
 int rank, int athleteId, String name, String club, Gender gender, String categoryName, int points, int races
});




}
/// @nodoc
class __$LicenseeStandingCopyWithImpl<$Res>
    implements _$LicenseeStandingCopyWith<$Res> {
  __$LicenseeStandingCopyWithImpl(this._self, this._then);

  final _LicenseeStanding _self;
  final $Res Function(_LicenseeStanding) _then;

/// Create a copy of LicenseeStanding
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rank = null,Object? athleteId = null,Object? name = null,Object? club = null,Object? gender = null,Object? categoryName = null,Object? points = null,Object? races = null,}) {
  return _then(_LicenseeStanding(
rank: null == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int,athleteId: null == athleteId ? _self.athleteId : athleteId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,races: null == races ? _self.races : races // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
