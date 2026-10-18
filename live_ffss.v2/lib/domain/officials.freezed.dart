// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'officials.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CompetitionOfficial {

 int get id;/// « NOM Prénom », comme le libellé d'un compte.
 String get name;/// Le code du niveau (`A`, `B`, `C`…).
 String get level; bool get principal;/// Les jours de la compétition où il officie.
 List<int> get days; String get daysLabel; String get club;
/// Create a copy of CompetitionOfficial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompetitionOfficialCopyWith<CompetitionOfficial> get copyWith => _$CompetitionOfficialCopyWithImpl<CompetitionOfficial>(this as CompetitionOfficial, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as CompetitionOfficial;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompetitionOfficial&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.level, _this.level) || other.level == _this.level)&&(identical(other.principal, _this.principal) || other.principal == _this.principal)&&const DeepCollectionEquality().equals(other.days, _this.days)&&(identical(other.daysLabel, _this.daysLabel) || other.daysLabel == _this.daysLabel)&&(identical(other.club, _this.club) || other.club == _this.club));
}


@override
int get hashCode {
  final _this = this as CompetitionOfficial;
  return Object.hash(runtimeType,_this.id,_this.name,_this.level,_this.principal,const DeepCollectionEquality().hash(_this.days),_this.daysLabel,_this.club);
}

@override
String toString() {
  final _this = this as CompetitionOfficial;
  return 'CompetitionOfficial(id: ${_this.id}, name: ${_this.name}, level: ${_this.level}, principal: ${_this.principal}, days: ${_this.days}, daysLabel: ${_this.daysLabel}, club: ${_this.club})';
}


}

/// @nodoc
abstract mixin class $CompetitionOfficialCopyWith<$Res>  {
  factory $CompetitionOfficialCopyWith(CompetitionOfficial value, $Res Function(CompetitionOfficial) _then) = _$CompetitionOfficialCopyWithImpl;
@useResult
$Res call({
 int id, String name, String level, bool principal, List<int> days, String daysLabel, String club
});




}
/// @nodoc
class _$CompetitionOfficialCopyWithImpl<$Res>
    implements $CompetitionOfficialCopyWith<$Res> {
  _$CompetitionOfficialCopyWithImpl(this._self, this._then);

  final CompetitionOfficial _self;
  final $Res Function(CompetitionOfficial) _then;

/// Create a copy of CompetitionOfficial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? level = null,Object? principal = null,Object? days = null,Object? daysLabel = null,Object? club = null,}) {
  return _then(CompetitionOfficial(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool,days: null == days ? _self.days : days // ignore: cast_nullable_to_non_nullable
as List<int>,daysLabel: null == daysLabel ? _self.daysLabel : daysLabel // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CompetitionOfficial].
extension CompetitionOfficialPatterns on CompetitionOfficial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CompetitionOfficial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CompetitionOfficial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CompetitionOfficial value)  $default,){
final _that = this;
switch (_that) {
case _CompetitionOfficial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CompetitionOfficial value)?  $default,){
final _that = this;
switch (_that) {
case _CompetitionOfficial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String level,  bool principal,  List<int> days,  String daysLabel,  String club)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CompetitionOfficial() when $default != null:
return $default(_that.id,_that.name,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String level,  bool principal,  List<int> days,  String daysLabel,  String club)  $default,) {final _that = this;
switch (_that) {
case _CompetitionOfficial():
return $default(_that.id,_that.name,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String level,  bool principal,  List<int> days,  String daysLabel,  String club)?  $default,) {final _that = this;
switch (_that) {
case _CompetitionOfficial() when $default != null:
return $default(_that.id,_that.name,_that.level,_that.principal,_that.days,_that.daysLabel,_that.club);case _:
  return null;

}
}

}

/// @nodoc


class _CompetitionOfficial implements CompetitionOfficial {
  const _CompetitionOfficial({required this.id, required this.name, required this.level, required this.principal, required  List<int> days, required this.daysLabel, required this.club}): _days = days;
  

@override final  int id;
/// « NOM Prénom », comme le libellé d'un compte.
@override final  String name;
/// Le code du niveau (`A`, `B`, `C`…).
@override final  String level;
@override final  bool principal;
/// Les jours de la compétition où il officie.
 final  List<int> _days;
/// Les jours de la compétition où il officie.
@override List<int> get days {
  if (_days is EqualUnmodifiableListView) return _days;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_days);
}

@override final  String daysLabel;
@override final  String club;

/// Create a copy of CompetitionOfficial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CompetitionOfficialCopyWith<_CompetitionOfficial> get copyWith => __$CompetitionOfficialCopyWithImpl<_CompetitionOfficial>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CompetitionOfficial&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.level, level) || other.level == level)&&(identical(other.principal, principal) || other.principal == principal)&&const DeepCollectionEquality().equals(other.days, _days)&&(identical(other.daysLabel, daysLabel) || other.daysLabel == daysLabel)&&(identical(other.club, club) || other.club == club));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,level,principal,const DeepCollectionEquality().hash(_days),daysLabel,club);
}

@override
String toString() {
    return 'CompetitionOfficial(id: $id, name: $name, level: $level, principal: $principal, days: $days, daysLabel: $daysLabel, club: $club)';
}


}

/// @nodoc
abstract mixin class _$CompetitionOfficialCopyWith<$Res> implements $CompetitionOfficialCopyWith<$Res> {
  factory _$CompetitionOfficialCopyWith(_CompetitionOfficial value, $Res Function(_CompetitionOfficial) _then) = __$CompetitionOfficialCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String level, bool principal, List<int> days, String daysLabel, String club
});




}
/// @nodoc
class __$CompetitionOfficialCopyWithImpl<$Res>
    implements _$CompetitionOfficialCopyWith<$Res> {
  __$CompetitionOfficialCopyWithImpl(this._self, this._then);

  final _CompetitionOfficial _self;
  final $Res Function(_CompetitionOfficial) _then;

/// Create a copy of CompetitionOfficial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? level = null,Object? principal = null,Object? days = null,Object? daysLabel = null,Object? club = null,}) {
  return _then(_CompetitionOfficial(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as String,principal: null == principal ? _self.principal : principal // ignore: cast_nullable_to_non_nullable
as bool,days: null == days ? _self._days : days // ignore: cast_nullable_to_non_nullable
as List<int>,daysLabel: null == daysLabel ? _self.daysLabel : daysLabel // ignore: cast_nullable_to_non_nullable
as String,club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
