// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_results.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompetitionEvent {

 int get id; int get disciplineId; String get disciplineName; Gender get gender; int get categoryId; String get categoryName; int get teamSize;/// La spécialité de la discipline ; nulle quand FFSS n'en donne pas une
/// connue : l'épreuve n'est alors montrée nulle part.
 Discipline? get discipline;
/// Create a copy of CompetitionEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<CompetitionEvent> get copyWith => _$CompetitionEventCopyWithImpl<CompetitionEvent>(this as CompetitionEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompetitionEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionEvent&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.disciplineId, _this.disciplineId) || other.disciplineId == _this.disciplineId)&&(identical(other.disciplineName, _this.disciplineName) || other.disciplineName == _this.disciplineName)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.categoryId, _this.categoryId) || other.categoryId == _this.categoryId)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.teamSize, _this.teamSize) || other.teamSize == _this.teamSize)&&(identical(other.discipline, _this.discipline) || other.discipline == _this.discipline));
}


@override
int get hashCode {
  final _this = this as CompetitionEvent;
  return Object.hash(runtimeType,_this.id,_this.disciplineId,_this.disciplineName,_this.gender,_this.categoryId,_this.categoryName,_this.teamSize,_this.discipline);
}

@override
String toString() {
  final _this = this as CompetitionEvent;
  return 'CompetitionEvent(id: ${_this.id}, disciplineId: ${_this.disciplineId}, disciplineName: ${_this.disciplineName}, gender: ${_this.gender}, categoryId: ${_this.categoryId}, categoryName: ${_this.categoryName}, teamSize: ${_this.teamSize}, discipline: ${_this.discipline})';
}


}

/// @nodoc
abstract mixin class $CompetitionEventCopyWith<$Res>  {
  factory $CompetitionEventCopyWith(CompetitionEvent value, $Res Function(CompetitionEvent) _then) = _$CompetitionEventCopyWithImpl;
@useResult
$Res call({
 int id, int disciplineId, String disciplineName, Gender gender, int categoryId, String categoryName, int teamSize, Discipline? discipline
});




}
/// @nodoc
class _$CompetitionEventCopyWithImpl<$Res>
    implements $CompetitionEventCopyWith<$Res> {
  _$CompetitionEventCopyWithImpl(this._self, this._then);

  final CompetitionEvent _self;
  final $Res Function(CompetitionEvent) _then;

/// Create a copy of CompetitionEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? disciplineId = null,Object? disciplineName = null,Object? gender = null,Object? categoryId = null,Object? categoryName = null,Object? teamSize = null,Object? discipline = freezed,}) {
  return _then(CompetitionEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,disciplineId: null == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int,disciplineName: null == disciplineName ? _self.disciplineName : disciplineName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,teamSize: null == teamSize ? _self.teamSize : teamSize // ignore: cast_nullable_to_non_nullable
as int,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as Discipline?,
  ));
}

}


/// Adds pattern-matching-related methods to [CompetitionEvent].
extension CompetitionEventPatterns on CompetitionEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionEvent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionEvent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionEvent value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionEvent value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionEvent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int disciplineId,  String disciplineName,  Gender gender,  int categoryId,  String categoryName,  int teamSize,  Discipline? discipline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionEvent() when $default != null:
return $default(_that.id,_that.disciplineId,_that.disciplineName,_that.gender,_that.categoryId,_that.categoryName,_that.teamSize,_that.discipline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int disciplineId,  String disciplineName,  Gender gender,  int categoryId,  String categoryName,  int teamSize,  Discipline? discipline)  $default,) {final _that = this;
switch (_that) {
case _CompetitionEvent():
return $default(_that.id,_that.disciplineId,_that.disciplineName,_that.gender,_that.categoryId,_that.categoryName,_that.teamSize,_that.discipline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int disciplineId,  String disciplineName,  Gender gender,  int categoryId,  String categoryName,  int teamSize,  Discipline? discipline)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionEvent() when $default != null:
return $default(_that.id,_that.disciplineId,_that.disciplineName,_that.gender,_that.categoryId,_that.categoryName,_that.teamSize,_that.discipline);case _:
  return null;

}
}

}

/// @nodoc


class _CompetitionEvent extends CompetitionEvent {
  const _CompetitionEvent({required this.id, required this.disciplineId, required this.disciplineName, required this.gender, required this.categoryId, required this.categoryName, required this.teamSize, this.discipline}): super._();
  

@override final  int id;
@override final  int disciplineId;
@override final  String disciplineName;
@override final  Gender gender;
@override final  int categoryId;
@override final  String categoryName;
@override final  int teamSize;
/// La spécialité de la discipline ; nulle quand FFSS n'en donne pas une
/// connue : l'épreuve n'est alors montrée nulle part.
@override final  Discipline? discipline;

/// Create a copy of CompetitionEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionEventCopyWith<_CompetitionEvent> get copyWith => __$CompetitionEventCopyWithImpl<_CompetitionEvent>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionEvent&&(identical(other.id, id) || other.id == id)&&(identical(other.disciplineId, disciplineId) || other.disciplineId == disciplineId)&&(identical(other.disciplineName, disciplineName) || other.disciplineName == disciplineName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.teamSize, teamSize) || other.teamSize == teamSize)&&(identical(other.discipline, discipline) || other.discipline == discipline));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,disciplineId,disciplineName,gender,categoryId,categoryName,teamSize,discipline);
}

@override
String toString() {
    return 'CompetitionEvent(id: $id, disciplineId: $disciplineId, disciplineName: $disciplineName, gender: $gender, categoryId: $categoryId, categoryName: $categoryName, teamSize: $teamSize, discipline: $discipline)';
}


}

/// @nodoc
abstract mixin class _$CompetitionEventCopyWith<$Res> implements $CompetitionEventCopyWith<$Res> {
  factory _$CompetitionEventCopyWith(_CompetitionEvent value, $Res Function(_CompetitionEvent) _then) = __$CompetitionEventCopyWithImpl;
@override @useResult
$Res call({
 int id, int disciplineId, String disciplineName, Gender gender, int categoryId, String categoryName, int teamSize, Discipline? discipline
});




}
/// @nodoc
class __$CompetitionEventCopyWithImpl<$Res>
    implements _$CompetitionEventCopyWith<$Res> {
  __$CompetitionEventCopyWithImpl(this._self, this._then);

  final _CompetitionEvent _self;
  final $Res Function(_CompetitionEvent) _then;

/// Create a copy of CompetitionEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? disciplineId = null,Object? disciplineName = null,Object? gender = null,Object? categoryId = null,Object? categoryName = null,Object? teamSize = null,Object? discipline = freezed,}) {
  return _then(_CompetitionEvent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,disciplineId: null == disciplineId ? _self.disciplineId : disciplineId // ignore: cast_nullable_to_non_nullable
as int,disciplineName: null == disciplineName ? _self.disciplineName : disciplineName // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,teamSize: null == teamSize ? _self.teamSize : teamSize // ignore: cast_nullable_to_non_nullable
as int,discipline: freezed == discipline ? _self.discipline : discipline // ignore: cast_nullable_to_non_nullable
as Discipline?,
  ));
}


}

/// @nodoc
mixin _$ResultAthlete {

 int get id; String get name; Gender? get gender; String get club; String? get nationality; bool get isGuest;
/// Create a copy of ResultAthlete
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultAthleteCopyWith<ResultAthlete> get copyWith => _$ResultAthleteCopyWithImpl<ResultAthlete>(this as ResultAthlete, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ResultAthlete;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultAthlete&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.nationality, _this.nationality) || other.nationality == _this.nationality)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest));
}


@override
int get hashCode {
  final _this = this as ResultAthlete;
  return Object.hash(runtimeType,_this.id,_this.name,_this.gender,_this.club,_this.nationality,_this.isGuest);
}

@override
String toString() {
  final _this = this as ResultAthlete;
  return 'ResultAthlete(id: ${_this.id}, name: ${_this.name}, gender: ${_this.gender}, club: ${_this.club}, nationality: ${_this.nationality}, isGuest: ${_this.isGuest})';
}


}

/// @nodoc
abstract mixin class $ResultAthleteCopyWith<$Res>  {
  factory $ResultAthleteCopyWith(ResultAthlete value, $Res Function(ResultAthlete) _then) = _$ResultAthleteCopyWithImpl;
@useResult
$Res call({
 int id, String name, Gender? gender, String club, String? nationality, bool isGuest
});




}
/// @nodoc
class _$ResultAthleteCopyWithImpl<$Res>
    implements $ResultAthleteCopyWith<$Res> {
  _$ResultAthleteCopyWithImpl(this._self, this._then);

  final ResultAthlete _self;
  final $Res Function(ResultAthlete) _then;

/// Create a copy of ResultAthlete
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? gender = freezed,Object? club = null,Object? nationality = freezed,Object? isGuest = null,}) {
  return _then(ResultAthlete(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ResultAthlete].
extension ResultAthletePatterns on ResultAthlete {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResultAthlete value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResultAthlete() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResultAthlete value)  $default,){
final _that = this;
switch (_that) {
case _ResultAthlete():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResultAthlete value)?  $default,){
final _that = this;
switch (_that) {
case _ResultAthlete() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  Gender? gender,  String club,  String? nationality,  bool isGuest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResultAthlete() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  Gender? gender,  String club,  String? nationality,  bool isGuest)  $default,) {final _that = this;
switch (_that) {
case _ResultAthlete():
return $default(_that.id,_that.name,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  Gender? gender,  String club,  String? nationality,  bool isGuest)?  $default,) {final _that = this;
switch (_that) {
case _ResultAthlete() when $default != null:
return $default(_that.id,_that.name,_that.gender,_that.club,_that.nationality,_that.isGuest);case _:
  return null;

}
}

}

/// @nodoc


class _ResultAthlete implements ResultAthlete {
  const _ResultAthlete({required this.id, required this.name, this.gender, this.club = '', this.nationality, this.isGuest = false});
  

@override final  int id;
@override final  String name;
@override final  Gender? gender;
@override@JsonKey() final  String club;
@override final  String? nationality;
@override@JsonKey() final  bool isGuest;

/// Create a copy of ResultAthlete
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultAthleteCopyWith<_ResultAthlete> get copyWith => __$ResultAthleteCopyWithImpl<_ResultAthlete>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultAthlete&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.club, club) || other.club == club)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,gender,club,nationality,isGuest);
}

@override
String toString() {
    return 'ResultAthlete(id: $id, name: $name, gender: $gender, club: $club, nationality: $nationality, isGuest: $isGuest)';
}


}

/// @nodoc
abstract mixin class _$ResultAthleteCopyWith<$Res> implements $ResultAthleteCopyWith<$Res> {
  factory _$ResultAthleteCopyWith(_ResultAthlete value, $Res Function(_ResultAthlete) _then) = __$ResultAthleteCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, Gender? gender, String club, String? nationality, bool isGuest
});




}
/// @nodoc
class __$ResultAthleteCopyWithImpl<$Res>
    implements _$ResultAthleteCopyWith<$Res> {
  __$ResultAthleteCopyWithImpl(this._self, this._then);

  final _ResultAthlete _self;
  final $Res Function(_ResultAthlete) _then;

/// Create a copy of ResultAthlete
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? gender = freezed,Object? club = null,Object? nationality = freezed,Object? isGuest = null,}) {
  return _then(_ResultAthlete(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$EventResult {

 int get id; int get entryId; int get eventId; String get categoryName; int get status;/// En centièmes ; nul sans temps (absent ou nul).
 int? get time; String get complement;/// Le club du premier athlète, sinon celui de l'engagement.
 String get club; List<ResultAthlete> get athletes;
/// Create a copy of EventResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventResultCopyWith<EventResult> get copyWith => _$EventResultCopyWithImpl<EventResult>(this as EventResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventResult&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.time, _this.time) || other.time == _this.time)&&(identical(other.complement, _this.complement) || other.complement == _this.complement)&&(identical(other.club, _this.club) || other.club == _this.club)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes));
}


@override
int get hashCode {
  final _this = this as EventResult;
  return Object.hash(runtimeType,_this.id,_this.entryId,_this.eventId,_this.categoryName,_this.status,_this.time,_this.complement,_this.club,const DeepCollectionEquality().hash(_this.athletes));
}

@override
String toString() {
  final _this = this as EventResult;
  return 'EventResult(id: ${_this.id}, entryId: ${_this.entryId}, eventId: ${_this.eventId}, categoryName: ${_this.categoryName}, status: ${_this.status}, time: ${_this.time}, complement: ${_this.complement}, club: ${_this.club}, athletes: ${_this.athletes})';
}


}

/// @nodoc
abstract mixin class $EventResultCopyWith<$Res>  {
  factory $EventResultCopyWith(EventResult value, $Res Function(EventResult) _then) = _$EventResultCopyWithImpl;
@useResult
$Res call({
 int id, int entryId, int eventId, String categoryName, int status, int? time, String complement, String club, List<ResultAthlete> athletes
});




}
/// @nodoc
class _$EventResultCopyWithImpl<$Res>
    implements $EventResultCopyWith<$Res> {
  _$EventResultCopyWithImpl(this._self, this._then);

  final EventResult _self;
  final $Res Function(EventResult) _then;

/// Create a copy of EventResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? entryId = null,Object? eventId = null,Object? categoryName = null,Object? status = null,Object? time = freezed,Object? complement = null,Object? club = null,Object? athletes = null,}) {
  return _then(EventResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,complement: null == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<ResultAthlete>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventResult].
extension EventResultPatterns on EventResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventResult value)  $default,){
final _that = this;
switch (_that) {
case _EventResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventResult value)?  $default,){
final _that = this;
switch (_that) {
case _EventResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int entryId,  int eventId,  String categoryName,  int status,  int? time,  String complement,  String club,  List<ResultAthlete> athletes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventResult() when $default != null:
return $default(_that.id,_that.entryId,_that.eventId,_that.categoryName,_that.status,_that.time,_that.complement,_that.club,_that.athletes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int entryId,  int eventId,  String categoryName,  int status,  int? time,  String complement,  String club,  List<ResultAthlete> athletes)  $default,) {final _that = this;
switch (_that) {
case _EventResult():
return $default(_that.id,_that.entryId,_that.eventId,_that.categoryName,_that.status,_that.time,_that.complement,_that.club,_that.athletes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int entryId,  int eventId,  String categoryName,  int status,  int? time,  String complement,  String club,  List<ResultAthlete> athletes)?  $default,) {final _that = this;
switch (_that) {
case _EventResult() when $default != null:
return $default(_that.id,_that.entryId,_that.eventId,_that.categoryName,_that.status,_that.time,_that.complement,_that.club,_that.athletes);case _:
  return null;

}
}

}

/// @nodoc


class _EventResult implements EventResult {
  const _EventResult({required this.id, required this.entryId, required this.eventId, required this.categoryName, required this.status, this.time, this.complement = '', this.club = '',  List<ResultAthlete> athletes = const <ResultAthlete>[]}): _athletes = athletes;
  

@override final  int id;
@override final  int entryId;
@override final  int eventId;
@override final  String categoryName;
@override final  int status;
/// En centièmes ; nul sans temps (absent ou nul).
@override final  int? time;
@override@JsonKey() final  String complement;
/// Le club du premier athlète, sinon celui de l'engagement.
@override@JsonKey() final  String club;
 final  List<ResultAthlete> _athletes;
@override@JsonKey() List<ResultAthlete> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}


/// Create a copy of EventResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventResultCopyWith<_EventResult> get copyWith => __$EventResultCopyWithImpl<_EventResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventResult&&(identical(other.id, id) || other.id == id)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&(identical(other.status, status) || other.status == status)&&(identical(other.time, time) || other.time == time)&&(identical(other.complement, complement) || other.complement == complement)&&(identical(other.club, club) || other.club == club)&&const DeepCollectionEquality().equals(other.athletes, _athletes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,entryId,eventId,categoryName,status,time,complement,club,const DeepCollectionEquality().hash(_athletes));
}

@override
String toString() {
    return 'EventResult(id: $id, entryId: $entryId, eventId: $eventId, categoryName: $categoryName, status: $status, time: $time, complement: $complement, club: $club, athletes: $athletes)';
}


}

/// @nodoc
abstract mixin class _$EventResultCopyWith<$Res> implements $EventResultCopyWith<$Res> {
  factory _$EventResultCopyWith(_EventResult value, $Res Function(_EventResult) _then) = __$EventResultCopyWithImpl;
@override @useResult
$Res call({
 int id, int entryId, int eventId, String categoryName, int status, int? time, String complement, String club, List<ResultAthlete> athletes
});




}
/// @nodoc
class __$EventResultCopyWithImpl<$Res>
    implements _$EventResultCopyWith<$Res> {
  __$EventResultCopyWithImpl(this._self, this._then);

  final _EventResult _self;
  final $Res Function(_EventResult) _then;

/// Create a copy of EventResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? entryId = null,Object? eventId = null,Object? categoryName = null,Object? status = null,Object? time = freezed,Object? complement = null,Object? club = null,Object? athletes = null,}) {
  return _then(_EventResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,time: freezed == time ? _self.time : time // ignore: cast_nullable_to_non_nullable
as int?,complement: null == complement ? _self.complement : complement // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<ResultAthlete>,
  ));
}


}

/// @nodoc
mixin _$EventSeries {

 int get id; int get eventId; int get number; String get name;/// Heure locale du début, nulle tant que la série n'a pas démarré.
 DateTime? get start; List<EventResult> get results;
/// Create a copy of EventSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventSeriesCopyWith<EventSeries> get copyWith => _$EventSeriesCopyWithImpl<EventSeries>(this as EventSeries, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventSeries;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventSeries&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.number, _this.number) || other.number == _this.number)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.start, _this.start) || other.start == _this.start)&&const DeepCollectionEquality().equals(other.results, _this.results));
}


@override
int get hashCode {
  final _this = this as EventSeries;
  return Object.hash(runtimeType,_this.id,_this.eventId,_this.number,_this.name,_this.start,const DeepCollectionEquality().hash(_this.results));
}

@override
String toString() {
  final _this = this as EventSeries;
  return 'EventSeries(id: ${_this.id}, eventId: ${_this.eventId}, number: ${_this.number}, name: ${_this.name}, start: ${_this.start}, results: ${_this.results})';
}


}

/// @nodoc
abstract mixin class $EventSeriesCopyWith<$Res>  {
  factory $EventSeriesCopyWith(EventSeries value, $Res Function(EventSeries) _then) = _$EventSeriesCopyWithImpl;
@useResult
$Res call({
 int id, int eventId, int number, String name, DateTime? start, List<EventResult> results
});




}
/// @nodoc
class _$EventSeriesCopyWithImpl<$Res>
    implements $EventSeriesCopyWith<$Res> {
  _$EventSeriesCopyWithImpl(this._self, this._then);

  final EventSeries _self;
  final $Res Function(EventSeries) _then;

/// Create a copy of EventSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? eventId = null,Object? number = null,Object? name = null,Object? start = freezed,Object? results = null,}) {
  return _then(EventSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<EventResult>,
  ));
}

}


/// Adds pattern-matching-related methods to [EventSeries].
extension EventSeriesPatterns on EventSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventSeries value)  $default,){
final _that = this;
switch (_that) {
case _EventSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventSeries value)?  $default,){
final _that = this;
switch (_that) {
case _EventSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int eventId,  int number,  String name,  DateTime? start,  List<EventResult> results)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventSeries() when $default != null:
return $default(_that.id,_that.eventId,_that.number,_that.name,_that.start,_that.results);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int eventId,  int number,  String name,  DateTime? start,  List<EventResult> results)  $default,) {final _that = this;
switch (_that) {
case _EventSeries():
return $default(_that.id,_that.eventId,_that.number,_that.name,_that.start,_that.results);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int eventId,  int number,  String name,  DateTime? start,  List<EventResult> results)?  $default,) {final _that = this;
switch (_that) {
case _EventSeries() when $default != null:
return $default(_that.id,_that.eventId,_that.number,_that.name,_that.start,_that.results);case _:
  return null;

}
}

}

/// @nodoc


class _EventSeries implements EventSeries {
  const _EventSeries({required this.id, required this.eventId, required this.number, required this.name, this.start,  List<EventResult> results = const <EventResult>[]}): _results = results;
  

@override final  int id;
@override final  int eventId;
@override final  int number;
@override final  String name;
/// Heure locale du début, nulle tant que la série n'a pas démarré.
@override final  DateTime? start;
 final  List<EventResult> _results;
@override@JsonKey() List<EventResult> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}


/// Create a copy of EventSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventSeriesCopyWith<_EventSeries> get copyWith => __$EventSeriesCopyWithImpl<_EventSeries>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventSeries&&(identical(other.id, id) || other.id == id)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.number, number) || other.number == number)&&(identical(other.name, name) || other.name == name)&&(identical(other.start, start) || other.start == start)&&const DeepCollectionEquality().equals(other.results, _results));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,eventId,number,name,start,const DeepCollectionEquality().hash(_results));
}

@override
String toString() {
    return 'EventSeries(id: $id, eventId: $eventId, number: $number, name: $name, start: $start, results: $results)';
}


}

/// @nodoc
abstract mixin class _$EventSeriesCopyWith<$Res> implements $EventSeriesCopyWith<$Res> {
  factory _$EventSeriesCopyWith(_EventSeries value, $Res Function(_EventSeries) _then) = __$EventSeriesCopyWithImpl;
@override @useResult
$Res call({
 int id, int eventId, int number, String name, DateTime? start, List<EventResult> results
});




}
/// @nodoc
class __$EventSeriesCopyWithImpl<$Res>
    implements _$EventSeriesCopyWith<$Res> {
  __$EventSeriesCopyWithImpl(this._self, this._then);

  final _EventSeries _self;
  final $Res Function(_EventSeries) _then;

/// Create a copy of EventSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? eventId = null,Object? number = null,Object? name = null,Object? start = freezed,Object? results = null,}) {
  return _then(_EventSeries(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,number: null == number ? _self.number : number // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,start: freezed == start ? _self.start : start // ignore: cast_nullable_to_non_nullable
as DateTime?,results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<EventResult>,
  ));
}


}

/// @nodoc
mixin _$ParticipantEntry {

 int get entryId; int get eventId; String get categoryName;
/// Create a copy of ParticipantEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantEntryCopyWith<ParticipantEntry> get copyWith => _$ParticipantEntryCopyWithImpl<ParticipantEntry>(this as ParticipantEntry, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ParticipantEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantEntry&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.categoryName, _this.categoryName) || other.categoryName == _this.categoryName));
}


@override
int get hashCode {
  final _this = this as ParticipantEntry;
  return Object.hash(runtimeType,_this.entryId,_this.eventId,_this.categoryName);
}

@override
String toString() {
  final _this = this as ParticipantEntry;
  return 'ParticipantEntry(entryId: ${_this.entryId}, eventId: ${_this.eventId}, categoryName: ${_this.categoryName})';
}


}

/// @nodoc
abstract mixin class $ParticipantEntryCopyWith<$Res>  {
  factory $ParticipantEntryCopyWith(ParticipantEntry value, $Res Function(ParticipantEntry) _then) = _$ParticipantEntryCopyWithImpl;
@useResult
$Res call({
 int entryId, int eventId, String categoryName
});




}
/// @nodoc
class _$ParticipantEntryCopyWithImpl<$Res>
    implements $ParticipantEntryCopyWith<$Res> {
  _$ParticipantEntryCopyWithImpl(this._self, this._then);

  final ParticipantEntry _self;
  final $Res Function(ParticipantEntry) _then;

/// Create a copy of ParticipantEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entryId = null,Object? eventId = null,Object? categoryName = null,}) {
  return _then(ParticipantEntry(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ParticipantEntry].
extension ParticipantEntryPatterns on ParticipantEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParticipantEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParticipantEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParticipantEntry value)  $default,){
final _that = this;
switch (_that) {
case _ParticipantEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParticipantEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ParticipantEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int entryId,  int eventId,  String categoryName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParticipantEntry() when $default != null:
return $default(_that.entryId,_that.eventId,_that.categoryName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int entryId,  int eventId,  String categoryName)  $default,) {final _that = this;
switch (_that) {
case _ParticipantEntry():
return $default(_that.entryId,_that.eventId,_that.categoryName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int entryId,  int eventId,  String categoryName)?  $default,) {final _that = this;
switch (_that) {
case _ParticipantEntry() when $default != null:
return $default(_that.entryId,_that.eventId,_that.categoryName);case _:
  return null;

}
}

}

/// @nodoc


class _ParticipantEntry implements ParticipantEntry {
  const _ParticipantEntry({required this.entryId, required this.eventId, required this.categoryName});
  

@override final  int entryId;
@override final  int eventId;
@override final  String categoryName;

/// Create a copy of ParticipantEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantEntryCopyWith<_ParticipantEntry> get copyWith => __$ParticipantEntryCopyWithImpl<_ParticipantEntry>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParticipantEntry&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entryId,eventId,categoryName);
}

@override
String toString() {
    return 'ParticipantEntry(entryId: $entryId, eventId: $eventId, categoryName: $categoryName)';
}


}

/// @nodoc
abstract mixin class _$ParticipantEntryCopyWith<$Res> implements $ParticipantEntryCopyWith<$Res> {
  factory _$ParticipantEntryCopyWith(_ParticipantEntry value, $Res Function(_ParticipantEntry) _then) = __$ParticipantEntryCopyWithImpl;
@override @useResult
$Res call({
 int entryId, int eventId, String categoryName
});




}
/// @nodoc
class __$ParticipantEntryCopyWithImpl<$Res>
    implements _$ParticipantEntryCopyWith<$Res> {
  __$ParticipantEntryCopyWithImpl(this._self, this._then);

  final _ParticipantEntry _self;
  final $Res Function(_ParticipantEntry) _then;

/// Create a copy of ParticipantEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entryId = null,Object? eventId = null,Object? categoryName = null,}) {
  return _then(_ParticipantEntry(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,eventId: null == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as int,categoryName: null == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$Participant {

 int get id; String get firstName; String get lastName; Gender? get gender; String get club; bool get isGuest; List<ParticipantEntry> get entries;
/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParticipantCopyWith<Participant> get copyWith => _$ParticipantCopyWithImpl<Participant>(this as Participant, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Participant;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Participant&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.firstName, _this.firstName) || other.firstName == _this.firstName)&&(identical(other.lastName, _this.lastName) || other.lastName == _this.lastName)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.club, _this.club) || other.club == _this.club)&&(identical(other.isGuest, _this.isGuest) || other.isGuest == _this.isGuest)&&const DeepCollectionEquality().equals(other.entries, _this.entries));
}


@override
int get hashCode {
  final _this = this as Participant;
  return Object.hash(runtimeType,_this.id,_this.firstName,_this.lastName,_this.gender,_this.club,_this.isGuest,const DeepCollectionEquality().hash(_this.entries));
}

@override
String toString() {
  final _this = this as Participant;
  return 'Participant(id: ${_this.id}, firstName: ${_this.firstName}, lastName: ${_this.lastName}, gender: ${_this.gender}, club: ${_this.club}, isGuest: ${_this.isGuest}, entries: ${_this.entries})';
}


}

/// @nodoc
abstract mixin class $ParticipantCopyWith<$Res>  {
  factory $ParticipantCopyWith(Participant value, $Res Function(Participant) _then) = _$ParticipantCopyWithImpl;
@useResult
$Res call({
 int id, String firstName, String lastName, Gender? gender, String club, bool isGuest, List<ParticipantEntry> entries
});




}
/// @nodoc
class _$ParticipantCopyWithImpl<$Res>
    implements $ParticipantCopyWith<$Res> {
  _$ParticipantCopyWithImpl(this._self, this._then);

  final Participant _self;
  final $Res Function(Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? gender = freezed,Object? club = null,Object? isGuest = null,Object? entries = null,}) {
  return _then(Participant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<ParticipantEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [Participant].
extension ParticipantPatterns on Participant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Participant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Participant value)  $default,){
final _that = this;
switch (_that) {
case _Participant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Participant value)?  $default,){
final _that = this;
switch (_that) {
case _Participant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  Gender? gender,  String club,  bool isGuest,  List<ParticipantEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String firstName,  String lastName,  Gender? gender,  String club,  bool isGuest,  List<ParticipantEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _Participant():
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String firstName,  String lastName,  Gender? gender,  String club,  bool isGuest,  List<ParticipantEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _Participant() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.gender,_that.club,_that.isGuest,_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _Participant implements Participant {
  const _Participant({required this.id, required this.firstName, required this.lastName, this.gender, this.club = '', this.isGuest = false,  List<ParticipantEntry> entries = const <ParticipantEntry>[]}): _entries = entries;
  

@override final  int id;
@override final  String firstName;
@override final  String lastName;
@override final  Gender? gender;
@override@JsonKey() final  String club;
@override@JsonKey() final  bool isGuest;
 final  List<ParticipantEntry> _entries;
@override@JsonKey() List<ParticipantEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParticipantCopyWith<_Participant> get copyWith => __$ParticipantCopyWithImpl<_Participant>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Participant&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.club, club) || other.club == club)&&(identical(other.isGuest, isGuest) || other.isGuest == isGuest)&&const DeepCollectionEquality().equals(other.entries, _entries));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,firstName,lastName,gender,club,isGuest,const DeepCollectionEquality().hash(_entries));
}

@override
String toString() {
    return 'Participant(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, club: $club, isGuest: $isGuest, entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$ParticipantCopyWith<$Res> implements $ParticipantCopyWith<$Res> {
  factory _$ParticipantCopyWith(_Participant value, $Res Function(_Participant) _then) = __$ParticipantCopyWithImpl;
@override @useResult
$Res call({
 int id, String firstName, String lastName, Gender? gender, String club, bool isGuest, List<ParticipantEntry> entries
});




}
/// @nodoc
class __$ParticipantCopyWithImpl<$Res>
    implements _$ParticipantCopyWith<$Res> {
  __$ParticipantCopyWithImpl(this._self, this._then);

  final _Participant _self;
  final $Res Function(_Participant) _then;

/// Create a copy of Participant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = null,Object? gender = freezed,Object? club = null,Object? isGuest = null,Object? entries = null,}) {
  return _then(_Participant(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,isGuest: null == isGuest ? _self.isGuest : isGuest // ignore: cast_nullable_to_non_nullable
as bool,entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<ParticipantEntry>,
  ));
}


}

// dart format on
