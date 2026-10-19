// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_forfeits_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubForfeit {

 int get entryId; CompetitionEvent get event;/// Ceux du club qui le courent : plusieurs pour un relais.
 List<String> get athletes;/// Sa course et son couloir, nuls tant qu'aucune place lue ne le porte.
 Heat? get heat; int? get lane;/// Nul sans place qui le porte : seule la place dit le forfait.
 bool? get forfeit;/// Une place du tour n'a pu être lue : elle pouvait le porter.
 bool get placesUnread; DateTime? get deadline;/// Plus rien à déclarer, quelle que soit l'heure : sa course est
/// courue, ou aucune échéance n'est connue.
 bool get locked; ForfeitSent? get lastSent; ForfeitSending get sending;
/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubForfeitCopyWith<ClubForfeit> get copyWith => _$ClubForfeitCopyWithImpl<ClubForfeit>(this as ClubForfeit, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as ClubForfeit;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubForfeit&&(identical(other.entryId, _this.entryId) || other.entryId == _this.entryId)&&(identical(other.event, _this.event) || other.event == _this.event)&&const DeepCollectionEquality().equals(other.athletes, _this.athletes)&&(identical(other.heat, _this.heat) || other.heat == _this.heat)&&(identical(other.lane, _this.lane) || other.lane == _this.lane)&&(identical(other.forfeit, _this.forfeit) || other.forfeit == _this.forfeit)&&(identical(other.placesUnread, _this.placesUnread) || other.placesUnread == _this.placesUnread)&&(identical(other.deadline, _this.deadline) || other.deadline == _this.deadline)&&(identical(other.locked, _this.locked) || other.locked == _this.locked)&&(identical(other.lastSent, _this.lastSent) || other.lastSent == _this.lastSent)&&(identical(other.sending, _this.sending) || other.sending == _this.sending));
}


@override
int get hashCode {
  final _this = this as ClubForfeit;
  return Object.hash(runtimeType,_this.entryId,_this.event,const DeepCollectionEquality().hash(_this.athletes),_this.heat,_this.lane,_this.forfeit,_this.placesUnread,_this.deadline,_this.locked,_this.lastSent,_this.sending);
}

@override
String toString() {
  final _this = this as ClubForfeit;
  return 'ClubForfeit(entryId: ${_this.entryId}, event: ${_this.event}, athletes: ${_this.athletes}, heat: ${_this.heat}, lane: ${_this.lane}, forfeit: ${_this.forfeit}, placesUnread: ${_this.placesUnread}, deadline: ${_this.deadline}, locked: ${_this.locked}, lastSent: ${_this.lastSent}, sending: ${_this.sending})';
}


}

/// @nodoc
abstract mixin class $ClubForfeitCopyWith<$Res>  {
  factory $ClubForfeitCopyWith(ClubForfeit value, $Res Function(ClubForfeit) _then) = _$ClubForfeitCopyWithImpl;
@useResult
$Res call({
 int entryId, CompetitionEvent event, List<String> athletes, Heat? heat, int? lane, bool? forfeit, bool placesUnread, DateTime? deadline, bool locked, ForfeitSent? lastSent, ForfeitSending sending
});


$CompetitionEventCopyWith<$Res> get event;$HeatCopyWith<$Res>? get heat;

}
/// @nodoc
class _$ClubForfeitCopyWithImpl<$Res>
    implements $ClubForfeitCopyWith<$Res> {
  _$ClubForfeitCopyWithImpl(this._self, this._then);

  final ClubForfeit _self;
  final $Res Function(ClubForfeit) _then;

/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entryId = null,Object? event = null,Object? athletes = null,Object? heat = freezed,Object? lane = freezed,Object? forfeit = freezed,Object? placesUnread = null,Object? deadline = freezed,Object? locked = null,Object? lastSent = freezed,Object? sending = null,}) {
  return _then(ClubForfeit(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,athletes: null == athletes ? _self.athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<String>,heat: freezed == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat?,lane: freezed == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int?,forfeit: freezed == forfeit ? _self.forfeit : forfeit // ignore: cast_nullable_to_non_nullable
as bool?,placesUnread: null == placesUnread ? _self.placesUnread : placesUnread // ignore: cast_nullable_to_non_nullable
as bool,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,lastSent: freezed == lastSent ? _self.lastSent : lastSent // ignore: cast_nullable_to_non_nullable
as ForfeitSent?,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as ForfeitSending,
  ));
}
/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res>? get heat {
    if (_self.heat == null) {
    return null;
  }

  return $HeatCopyWith<$Res>(_self.heat!, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClubForfeit].
extension ClubForfeitPatterns on ClubForfeit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubForfeit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubForfeit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubForfeit value)  $default,){
final _that = this;
switch (_that) {
case _ClubForfeit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubForfeit value)?  $default,){
final _that = this;
switch (_that) {
case _ClubForfeit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int entryId,  CompetitionEvent event,  List<String> athletes,  Heat? heat,  int? lane,  bool? forfeit,  bool placesUnread,  DateTime? deadline,  bool locked,  ForfeitSent? lastSent,  ForfeitSending sending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubForfeit() when $default != null:
return $default(_that.entryId,_that.event,_that.athletes,_that.heat,_that.lane,_that.forfeit,_that.placesUnread,_that.deadline,_that.locked,_that.lastSent,_that.sending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int entryId,  CompetitionEvent event,  List<String> athletes,  Heat? heat,  int? lane,  bool? forfeit,  bool placesUnread,  DateTime? deadline,  bool locked,  ForfeitSent? lastSent,  ForfeitSending sending)  $default,) {final _that = this;
switch (_that) {
case _ClubForfeit():
return $default(_that.entryId,_that.event,_that.athletes,_that.heat,_that.lane,_that.forfeit,_that.placesUnread,_that.deadline,_that.locked,_that.lastSent,_that.sending);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int entryId,  CompetitionEvent event,  List<String> athletes,  Heat? heat,  int? lane,  bool? forfeit,  bool placesUnread,  DateTime? deadline,  bool locked,  ForfeitSent? lastSent,  ForfeitSending sending)?  $default,) {final _that = this;
switch (_that) {
case _ClubForfeit() when $default != null:
return $default(_that.entryId,_that.event,_that.athletes,_that.heat,_that.lane,_that.forfeit,_that.placesUnread,_that.deadline,_that.locked,_that.lastSent,_that.sending);case _:
  return null;

}
}

}

/// @nodoc


class _ClubForfeit implements ClubForfeit {
  const _ClubForfeit({required this.entryId, required this.event, required  List<String> athletes, this.heat, this.lane, this.forfeit, this.placesUnread = false, this.deadline, this.locked = false, this.lastSent, this.sending = ForfeitSending.idle}): _athletes = athletes;
  

@override final  int entryId;
@override final  CompetitionEvent event;
/// Ceux du club qui le courent : plusieurs pour un relais.
 final  List<String> _athletes;
/// Ceux du club qui le courent : plusieurs pour un relais.
@override List<String> get athletes {
  if (_athletes is EqualUnmodifiableListView) return _athletes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_athletes);
}

/// Sa course et son couloir, nuls tant qu'aucune place lue ne le porte.
@override final  Heat? heat;
@override final  int? lane;
/// Nul sans place qui le porte : seule la place dit le forfait.
@override final  bool? forfeit;
/// Une place du tour n'a pu être lue : elle pouvait le porter.
@override@JsonKey() final  bool placesUnread;
@override final  DateTime? deadline;
/// Plus rien à déclarer, quelle que soit l'heure : sa course est
/// courue, ou aucune échéance n'est connue.
@override@JsonKey() final  bool locked;
@override final  ForfeitSent? lastSent;
@override@JsonKey() final  ForfeitSending sending;

/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubForfeitCopyWith<_ClubForfeit> get copyWith => __$ClubForfeitCopyWithImpl<_ClubForfeit>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubForfeit&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.athletes, _athletes)&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.lane, lane) || other.lane == lane)&&(identical(other.forfeit, forfeit) || other.forfeit == forfeit)&&(identical(other.placesUnread, placesUnread) || other.placesUnread == placesUnread)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.locked, locked) || other.locked == locked)&&(identical(other.lastSent, lastSent) || other.lastSent == lastSent)&&(identical(other.sending, sending) || other.sending == sending));
}


@override
int get hashCode {
    return Object.hash(runtimeType,entryId,event,const DeepCollectionEquality().hash(_athletes),heat,lane,forfeit,placesUnread,deadline,locked,lastSent,sending);
}

@override
String toString() {
    return 'ClubForfeit(entryId: $entryId, event: $event, athletes: $athletes, heat: $heat, lane: $lane, forfeit: $forfeit, placesUnread: $placesUnread, deadline: $deadline, locked: $locked, lastSent: $lastSent, sending: $sending)';
}


}

/// @nodoc
abstract mixin class _$ClubForfeitCopyWith<$Res> implements $ClubForfeitCopyWith<$Res> {
  factory _$ClubForfeitCopyWith(_ClubForfeit value, $Res Function(_ClubForfeit) _then) = __$ClubForfeitCopyWithImpl;
@override @useResult
$Res call({
 int entryId, CompetitionEvent event, List<String> athletes, Heat? heat, int? lane, bool? forfeit, bool placesUnread, DateTime? deadline, bool locked, ForfeitSent? lastSent, ForfeitSending sending
});


@override $CompetitionEventCopyWith<$Res> get event;@override $HeatCopyWith<$Res>? get heat;

}
/// @nodoc
class __$ClubForfeitCopyWithImpl<$Res>
    implements _$ClubForfeitCopyWith<$Res> {
  __$ClubForfeitCopyWithImpl(this._self, this._then);

  final _ClubForfeit _self;
  final $Res Function(_ClubForfeit) _then;

/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entryId = null,Object? event = null,Object? athletes = null,Object? heat = freezed,Object? lane = freezed,Object? forfeit = freezed,Object? placesUnread = null,Object? deadline = freezed,Object? locked = null,Object? lastSent = freezed,Object? sending = null,}) {
  return _then(_ClubForfeit(
entryId: null == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as int,event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,athletes: null == athletes ? _self._athletes : athletes // ignore: cast_nullable_to_non_nullable
as List<String>,heat: freezed == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat?,lane: freezed == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int?,forfeit: freezed == forfeit ? _self.forfeit : forfeit // ignore: cast_nullable_to_non_nullable
as bool?,placesUnread: null == placesUnread ? _self.placesUnread : placesUnread // ignore: cast_nullable_to_non_nullable
as bool,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,locked: null == locked ? _self.locked : locked // ignore: cast_nullable_to_non_nullable
as bool,lastSent: freezed == lastSent ? _self.lastSent : lastSent // ignore: cast_nullable_to_non_nullable
as ForfeitSent?,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as ForfeitSending,
  ));
}

/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}/// Create a copy of ClubForfeit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res>? get heat {
    if (_self.heat == null) {
    return null;
  }

  return $HeatCopyWith<$Res>(_self.heat!, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}

// dart format on
