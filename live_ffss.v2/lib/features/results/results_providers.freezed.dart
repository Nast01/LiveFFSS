// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'results_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Standings {

 List<ClubStanding> get clubs; List<LicenseeStanding> get licensees; int get finishedSeries; int get totalSeries;/// Épreuves dont les séries n'ont pu être lues, sans classement
/// antérieur : absentes des classements, que la page dit alors
/// incomplets.
 int get failedEvents;/// Épreuves que le dernier rafraîchissement n'a pu relire : leur
/// classement précédent est gardé, que la page dit alors ancien.
 int get staleEvents; DateTime get computedAt;
/// Create a copy of Standings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StandingsCopyWith<Standings> get copyWith => _$StandingsCopyWithImpl<Standings>(this as Standings, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Standings;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Standings&&const DeepCollectionEquality().equals(other.clubs, _this.clubs)&&const DeepCollectionEquality().equals(other.licensees, _this.licensees)&&(identical(other.finishedSeries, _this.finishedSeries) || other.finishedSeries == _this.finishedSeries)&&(identical(other.totalSeries, _this.totalSeries) || other.totalSeries == _this.totalSeries)&&(identical(other.failedEvents, _this.failedEvents) || other.failedEvents == _this.failedEvents)&&(identical(other.staleEvents, _this.staleEvents) || other.staleEvents == _this.staleEvents)&&(identical(other.computedAt, _this.computedAt) || other.computedAt == _this.computedAt));
}


@override
int get hashCode {
  final _this = this as Standings;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.clubs),const DeepCollectionEquality().hash(_this.licensees),_this.finishedSeries,_this.totalSeries,_this.failedEvents,_this.staleEvents,_this.computedAt);
}

@override
String toString() {
  final _this = this as Standings;
  return 'Standings(clubs: ${_this.clubs}, licensees: ${_this.licensees}, finishedSeries: ${_this.finishedSeries}, totalSeries: ${_this.totalSeries}, failedEvents: ${_this.failedEvents}, staleEvents: ${_this.staleEvents}, computedAt: ${_this.computedAt})';
}


}

/// @nodoc
abstract mixin class $StandingsCopyWith<$Res>  {
  factory $StandingsCopyWith(Standings value, $Res Function(Standings) _then) = _$StandingsCopyWithImpl;
@useResult
$Res call({
 List<ClubStanding> clubs, List<LicenseeStanding> licensees, int finishedSeries, int totalSeries, int failedEvents, int staleEvents, DateTime computedAt
});




}
/// @nodoc
class _$StandingsCopyWithImpl<$Res>
    implements $StandingsCopyWith<$Res> {
  _$StandingsCopyWithImpl(this._self, this._then);

  final Standings _self;
  final $Res Function(Standings) _then;

/// Create a copy of Standings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? clubs = null,Object? licensees = null,Object? finishedSeries = null,Object? totalSeries = null,Object? failedEvents = null,Object? staleEvents = null,Object? computedAt = null,}) {
  return _then(Standings(
clubs: null == clubs ? _self.clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<ClubStanding>,licensees: null == licensees ? _self.licensees : licensees // ignore: cast_nullable_to_non_nullable
as List<LicenseeStanding>,finishedSeries: null == finishedSeries ? _self.finishedSeries : finishedSeries // ignore: cast_nullable_to_non_nullable
as int,totalSeries: null == totalSeries ? _self.totalSeries : totalSeries // ignore: cast_nullable_to_non_nullable
as int,failedEvents: null == failedEvents ? _self.failedEvents : failedEvents // ignore: cast_nullable_to_non_nullable
as int,staleEvents: null == staleEvents ? _self.staleEvents : staleEvents // ignore: cast_nullable_to_non_nullable
as int,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Standings].
extension StandingsPatterns on Standings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Standings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Standings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Standings value)  $default,){
final _that = this;
switch (_that) {
case _Standings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Standings value)?  $default,){
final _that = this;
switch (_that) {
case _Standings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ClubStanding> clubs,  List<LicenseeStanding> licensees,  int finishedSeries,  int totalSeries,  int failedEvents,  int staleEvents,  DateTime computedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Standings() when $default != null:
return $default(_that.clubs,_that.licensees,_that.finishedSeries,_that.totalSeries,_that.failedEvents,_that.staleEvents,_that.computedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ClubStanding> clubs,  List<LicenseeStanding> licensees,  int finishedSeries,  int totalSeries,  int failedEvents,  int staleEvents,  DateTime computedAt)  $default,) {final _that = this;
switch (_that) {
case _Standings():
return $default(_that.clubs,_that.licensees,_that.finishedSeries,_that.totalSeries,_that.failedEvents,_that.staleEvents,_that.computedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ClubStanding> clubs,  List<LicenseeStanding> licensees,  int finishedSeries,  int totalSeries,  int failedEvents,  int staleEvents,  DateTime computedAt)?  $default,) {final _that = this;
switch (_that) {
case _Standings() when $default != null:
return $default(_that.clubs,_that.licensees,_that.finishedSeries,_that.totalSeries,_that.failedEvents,_that.staleEvents,_that.computedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Standings implements Standings {
  const _Standings({required  List<ClubStanding> clubs, required  List<LicenseeStanding> licensees, required this.finishedSeries, required this.totalSeries, required this.failedEvents, this.staleEvents = 0, required this.computedAt}): _clubs = clubs,_licensees = licensees;
  

 final  List<ClubStanding> _clubs;
@override List<ClubStanding> get clubs {
  if (_clubs is EqualUnmodifiableListView) return _clubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_clubs);
}

 final  List<LicenseeStanding> _licensees;
@override List<LicenseeStanding> get licensees {
  if (_licensees is EqualUnmodifiableListView) return _licensees;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_licensees);
}

@override final  int finishedSeries;
@override final  int totalSeries;
/// Épreuves dont les séries n'ont pu être lues, sans classement
/// antérieur : absentes des classements, que la page dit alors
/// incomplets.
@override final  int failedEvents;
/// Épreuves que le dernier rafraîchissement n'a pu relire : leur
/// classement précédent est gardé, que la page dit alors ancien.
@override@JsonKey() final  int staleEvents;
@override final  DateTime computedAt;

/// Create a copy of Standings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StandingsCopyWith<_Standings> get copyWith => __$StandingsCopyWithImpl<_Standings>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Standings&&const DeepCollectionEquality().equals(other.clubs, _clubs)&&const DeepCollectionEquality().equals(other.licensees, _licensees)&&(identical(other.finishedSeries, finishedSeries) || other.finishedSeries == finishedSeries)&&(identical(other.totalSeries, totalSeries) || other.totalSeries == totalSeries)&&(identical(other.failedEvents, failedEvents) || other.failedEvents == failedEvents)&&(identical(other.staleEvents, staleEvents) || other.staleEvents == staleEvents)&&(identical(other.computedAt, computedAt) || other.computedAt == computedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_clubs),const DeepCollectionEquality().hash(_licensees),finishedSeries,totalSeries,failedEvents,staleEvents,computedAt);
}

@override
String toString() {
    return 'Standings(clubs: $clubs, licensees: $licensees, finishedSeries: $finishedSeries, totalSeries: $totalSeries, failedEvents: $failedEvents, staleEvents: $staleEvents, computedAt: $computedAt)';
}


}

/// @nodoc
abstract mixin class _$StandingsCopyWith<$Res> implements $StandingsCopyWith<$Res> {
  factory _$StandingsCopyWith(_Standings value, $Res Function(_Standings) _then) = __$StandingsCopyWithImpl;
@override @useResult
$Res call({
 List<ClubStanding> clubs, List<LicenseeStanding> licensees, int finishedSeries, int totalSeries, int failedEvents, int staleEvents, DateTime computedAt
});




}
/// @nodoc
class __$StandingsCopyWithImpl<$Res>
    implements _$StandingsCopyWith<$Res> {
  __$StandingsCopyWithImpl(this._self, this._then);

  final _Standings _self;
  final $Res Function(_Standings) _then;

/// Create a copy of Standings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? clubs = null,Object? licensees = null,Object? finishedSeries = null,Object? totalSeries = null,Object? failedEvents = null,Object? staleEvents = null,Object? computedAt = null,}) {
  return _then(_Standings(
clubs: null == clubs ? _self._clubs : clubs // ignore: cast_nullable_to_non_nullable
as List<ClubStanding>,licensees: null == licensees ? _self._licensees : licensees // ignore: cast_nullable_to_non_nullable
as List<LicenseeStanding>,finishedSeries: null == finishedSeries ? _self.finishedSeries : finishedSeries // ignore: cast_nullable_to_non_nullable
as int,totalSeries: null == totalSeries ? _self.totalSeries : totalSeries // ignore: cast_nullable_to_non_nullable
as int,failedEvents: null == failedEvents ? _self.failedEvents : failedEvents // ignore: cast_nullable_to_non_nullable
as int,staleEvents: null == staleEvents ? _self.staleEvents : staleEvents // ignore: cast_nullable_to_non_nullable
as int,computedAt: null == computedAt ? _self.computedAt : computedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
