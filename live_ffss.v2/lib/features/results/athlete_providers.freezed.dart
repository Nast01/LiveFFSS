// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'athlete_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AthleteRace {

 CompetitionEvent get event; ParticipantEntry get entry;/// Sa série rattachée, connue aussi d'une course publiée mais pas encore
/// courue.
 LinkedSeries? get series;/// Son résultat dans le classement de l'épreuve, nul tant qu'il n'a pas
/// couru.
 RankingRow? get row;/// Place dans sa série, parmi les résultats de sa catégorie.
 int? get heatPlace;/// Le départ prévu de sa course, sinon celui de la première course du
/// tour séries de l'épreuve.
 DateTime? get plannedStart;/// Le classement de l'épreuve est provisoire (`EventRanking.provisional`),
/// ce que le rang dans l'épreuve doit dire : sa série peut être validée
/// quand les autres, ou les finales, ne le sont pas. Vrai à défaut.
 bool get eventProvisional;/// Le classement de l'épreuve n'a pu être lu : ni série ni résultat.
 bool get unavailable;
/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AthleteRaceCopyWith<AthleteRace> get copyWith => _$AthleteRaceCopyWithImpl<AthleteRace>(this as AthleteRace, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AthleteRace;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AthleteRace&&(identical(other.event, _this.event) || other.event == _this.event)&&(identical(other.entry, _this.entry) || other.entry == _this.entry)&&(identical(other.series, _this.series) || other.series == _this.series)&&(identical(other.row, _this.row) || other.row == _this.row)&&(identical(other.heatPlace, _this.heatPlace) || other.heatPlace == _this.heatPlace)&&(identical(other.plannedStart, _this.plannedStart) || other.plannedStart == _this.plannedStart)&&(identical(other.eventProvisional, _this.eventProvisional) || other.eventProvisional == _this.eventProvisional)&&(identical(other.unavailable, _this.unavailable) || other.unavailable == _this.unavailable));
}


@override
int get hashCode {
  final _this = this as AthleteRace;
  return Object.hash(runtimeType,_this.event,_this.entry,_this.series,_this.row,_this.heatPlace,_this.plannedStart,_this.eventProvisional,_this.unavailable);
}

@override
String toString() {
  final _this = this as AthleteRace;
  return 'AthleteRace(event: ${_this.event}, entry: ${_this.entry}, series: ${_this.series}, row: ${_this.row}, heatPlace: ${_this.heatPlace}, plannedStart: ${_this.plannedStart}, eventProvisional: ${_this.eventProvisional}, unavailable: ${_this.unavailable})';
}


}

/// @nodoc
abstract mixin class $AthleteRaceCopyWith<$Res>  {
  factory $AthleteRaceCopyWith(AthleteRace value, $Res Function(AthleteRace) _then) = _$AthleteRaceCopyWithImpl;
@useResult
$Res call({
 CompetitionEvent event, ParticipantEntry entry, LinkedSeries? series, RankingRow? row, int? heatPlace, DateTime? plannedStart, bool eventProvisional, bool unavailable
});


$CompetitionEventCopyWith<$Res> get event;$ParticipantEntryCopyWith<$Res> get entry;$LinkedSeriesCopyWith<$Res>? get series;$RankingRowCopyWith<$Res>? get row;

}
/// @nodoc
class _$AthleteRaceCopyWithImpl<$Res>
    implements $AthleteRaceCopyWith<$Res> {
  _$AthleteRaceCopyWithImpl(this._self, this._then);

  final AthleteRace _self;
  final $Res Function(AthleteRace) _then;

/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? event = null,Object? entry = null,Object? series = freezed,Object? row = freezed,Object? heatPlace = freezed,Object? plannedStart = freezed,Object? eventProvisional = null,Object? unavailable = null,}) {
  return _then(AthleteRace(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as ParticipantEntry,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as LinkedSeries?,row: freezed == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as RankingRow?,heatPlace: freezed == heatPlace ? _self.heatPlace : heatPlace // ignore: cast_nullable_to_non_nullable
as int?,plannedStart: freezed == plannedStart ? _self.plannedStart : plannedStart // ignore: cast_nullable_to_non_nullable
as DateTime?,eventProvisional: null == eventProvisional ? _self.eventProvisional : eventProvisional // ignore: cast_nullable_to_non_nullable
as bool,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantEntryCopyWith<$Res> get entry {
  
  return $ParticipantEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkedSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $LinkedSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankingRowCopyWith<$Res>? get row {
    if (_self.row == null) {
    return null;
  }

  return $RankingRowCopyWith<$Res>(_self.row!, (value) {
    return _then(_self.copyWith(row: value));
  });
}
}


/// Adds pattern-matching-related methods to [AthleteRace].
extension AthleteRacePatterns on AthleteRace {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AthleteRace value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AthleteRace() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AthleteRace value)  $default,){
final _that = this;
switch (_that) {
case _AthleteRace():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AthleteRace value)?  $default,){
final _that = this;
switch (_that) {
case _AthleteRace() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CompetitionEvent event,  ParticipantEntry entry,  LinkedSeries? series,  RankingRow? row,  int? heatPlace,  DateTime? plannedStart,  bool eventProvisional,  bool unavailable)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AthleteRace() when $default != null:
return $default(_that.event,_that.entry,_that.series,_that.row,_that.heatPlace,_that.plannedStart,_that.eventProvisional,_that.unavailable);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CompetitionEvent event,  ParticipantEntry entry,  LinkedSeries? series,  RankingRow? row,  int? heatPlace,  DateTime? plannedStart,  bool eventProvisional,  bool unavailable)  $default,) {final _that = this;
switch (_that) {
case _AthleteRace():
return $default(_that.event,_that.entry,_that.series,_that.row,_that.heatPlace,_that.plannedStart,_that.eventProvisional,_that.unavailable);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CompetitionEvent event,  ParticipantEntry entry,  LinkedSeries? series,  RankingRow? row,  int? heatPlace,  DateTime? plannedStart,  bool eventProvisional,  bool unavailable)?  $default,) {final _that = this;
switch (_that) {
case _AthleteRace() when $default != null:
return $default(_that.event,_that.entry,_that.series,_that.row,_that.heatPlace,_that.plannedStart,_that.eventProvisional,_that.unavailable);case _:
  return null;

}
}

}

/// @nodoc


class _AthleteRace extends AthleteRace {
  const _AthleteRace({required this.event, required this.entry, this.series, this.row, this.heatPlace, this.plannedStart, this.eventProvisional = true, this.unavailable = false}): super._();
  

@override final  CompetitionEvent event;
@override final  ParticipantEntry entry;
/// Sa série rattachée, connue aussi d'une course publiée mais pas encore
/// courue.
@override final  LinkedSeries? series;
/// Son résultat dans le classement de l'épreuve, nul tant qu'il n'a pas
/// couru.
@override final  RankingRow? row;
/// Place dans sa série, parmi les résultats de sa catégorie.
@override final  int? heatPlace;
/// Le départ prévu de sa course, sinon celui de la première course du
/// tour séries de l'épreuve.
@override final  DateTime? plannedStart;
/// Le classement de l'épreuve est provisoire (`EventRanking.provisional`),
/// ce que le rang dans l'épreuve doit dire : sa série peut être validée
/// quand les autres, ou les finales, ne le sont pas. Vrai à défaut.
@override@JsonKey() final  bool eventProvisional;
/// Le classement de l'épreuve n'a pu être lu : ni série ni résultat.
@override@JsonKey() final  bool unavailable;

/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AthleteRaceCopyWith<_AthleteRace> get copyWith => __$AthleteRaceCopyWithImpl<_AthleteRace>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AthleteRace&&(identical(other.event, event) || other.event == event)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.series, series) || other.series == series)&&(identical(other.row, row) || other.row == row)&&(identical(other.heatPlace, heatPlace) || other.heatPlace == heatPlace)&&(identical(other.plannedStart, plannedStart) || other.plannedStart == plannedStart)&&(identical(other.eventProvisional, eventProvisional) || other.eventProvisional == eventProvisional)&&(identical(other.unavailable, unavailable) || other.unavailable == unavailable));
}


@override
int get hashCode {
    return Object.hash(runtimeType,event,entry,series,row,heatPlace,plannedStart,eventProvisional,unavailable);
}

@override
String toString() {
    return 'AthleteRace(event: $event, entry: $entry, series: $series, row: $row, heatPlace: $heatPlace, plannedStart: $plannedStart, eventProvisional: $eventProvisional, unavailable: $unavailable)';
}


}

/// @nodoc
abstract mixin class _$AthleteRaceCopyWith<$Res> implements $AthleteRaceCopyWith<$Res> {
  factory _$AthleteRaceCopyWith(_AthleteRace value, $Res Function(_AthleteRace) _then) = __$AthleteRaceCopyWithImpl;
@override @useResult
$Res call({
 CompetitionEvent event, ParticipantEntry entry, LinkedSeries? series, RankingRow? row, int? heatPlace, DateTime? plannedStart, bool eventProvisional, bool unavailable
});


@override $CompetitionEventCopyWith<$Res> get event;@override $ParticipantEntryCopyWith<$Res> get entry;@override $LinkedSeriesCopyWith<$Res>? get series;@override $RankingRowCopyWith<$Res>? get row;

}
/// @nodoc
class __$AthleteRaceCopyWithImpl<$Res>
    implements _$AthleteRaceCopyWith<$Res> {
  __$AthleteRaceCopyWithImpl(this._self, this._then);

  final _AthleteRace _self;
  final $Res Function(_AthleteRace) _then;

/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? event = null,Object? entry = null,Object? series = freezed,Object? row = freezed,Object? heatPlace = freezed,Object? plannedStart = freezed,Object? eventProvisional = null,Object? unavailable = null,}) {
  return _then(_AthleteRace(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,entry: null == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as ParticipantEntry,series: freezed == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as LinkedSeries?,row: freezed == row ? _self.row : row // ignore: cast_nullable_to_non_nullable
as RankingRow?,heatPlace: freezed == heatPlace ? _self.heatPlace : heatPlace // ignore: cast_nullable_to_non_nullable
as int?,plannedStart: freezed == plannedStart ? _self.plannedStart : plannedStart // ignore: cast_nullable_to_non_nullable
as DateTime?,eventProvisional: null == eventProvisional ? _self.eventProvisional : eventProvisional // ignore: cast_nullable_to_non_nullable
as bool,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ParticipantEntryCopyWith<$Res> get entry {
  
  return $ParticipantEntryCopyWith<$Res>(_self.entry, (value) {
    return _then(_self.copyWith(entry: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkedSeriesCopyWith<$Res>? get series {
    if (_self.series == null) {
    return null;
  }

  return $LinkedSeriesCopyWith<$Res>(_self.series!, (value) {
    return _then(_self.copyWith(series: value));
  });
}/// Create a copy of AthleteRace
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RankingRowCopyWith<$Res>? get row {
    if (_self.row == null) {
    return null;
  }

  return $RankingRowCopyWith<$Res>(_self.row!, (value) {
    return _then(_self.copyWith(row: value));
  });
}
}

/// @nodoc
mixin _$LaneFound {

 Heat get heat; int get lane;
/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LaneFoundCopyWith<LaneFound> get copyWith => _$LaneFoundCopyWithImpl<LaneFound>(this as LaneFound, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LaneFound;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LaneFound&&(identical(other.heat, _this.heat) || other.heat == _this.heat)&&(identical(other.lane, _this.lane) || other.lane == _this.lane));
}


@override
int get hashCode {
  final _this = this as LaneFound;
  return Object.hash(runtimeType,_this.heat,_this.lane);
}

@override
String toString() {
  final _this = this as LaneFound;
  return 'LaneFound(heat: ${_this.heat}, lane: ${_this.lane})';
}


}

/// @nodoc
abstract mixin class $LaneFoundCopyWith<$Res>  {
  factory $LaneFoundCopyWith(LaneFound value, $Res Function(LaneFound) _then) = _$LaneFoundCopyWithImpl;
@useResult
$Res call({
 Heat heat, int lane
});


$HeatCopyWith<$Res> get heat;

}
/// @nodoc
class _$LaneFoundCopyWithImpl<$Res>
    implements $LaneFoundCopyWith<$Res> {
  _$LaneFoundCopyWithImpl(this._self, this._then);

  final LaneFound _self;
  final $Res Function(LaneFound) _then;

/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heat = null,Object? lane = null,}) {
  return _then(LaneFound(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}


/// Adds pattern-matching-related methods to [LaneFound].
extension LaneFoundPatterns on LaneFound {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LaneFound value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LaneFound() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LaneFound value)  $default,){
final _that = this;
switch (_that) {
case _LaneFound():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LaneFound value)?  $default,){
final _that = this;
switch (_that) {
case _LaneFound() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Heat heat,  int lane)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LaneFound() when $default != null:
return $default(_that.heat,_that.lane);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Heat heat,  int lane)  $default,) {final _that = this;
switch (_that) {
case _LaneFound():
return $default(_that.heat,_that.lane);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Heat heat,  int lane)?  $default,) {final _that = this;
switch (_that) {
case _LaneFound() when $default != null:
return $default(_that.heat,_that.lane);case _:
  return null;

}
}

}

/// @nodoc


class _LaneFound implements LaneFound {
  const _LaneFound({required this.heat, required this.lane});
  

@override final  Heat heat;
@override final  int lane;

/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LaneFoundCopyWith<_LaneFound> get copyWith => __$LaneFoundCopyWithImpl<_LaneFound>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LaneFound&&(identical(other.heat, heat) || other.heat == heat)&&(identical(other.lane, lane) || other.lane == lane));
}


@override
int get hashCode {
    return Object.hash(runtimeType,heat,lane);
}

@override
String toString() {
    return 'LaneFound(heat: $heat, lane: $lane)';
}


}

/// @nodoc
abstract mixin class _$LaneFoundCopyWith<$Res> implements $LaneFoundCopyWith<$Res> {
  factory _$LaneFoundCopyWith(_LaneFound value, $Res Function(_LaneFound) _then) = __$LaneFoundCopyWithImpl;
@override @useResult
$Res call({
 Heat heat, int lane
});


@override $HeatCopyWith<$Res> get heat;

}
/// @nodoc
class __$LaneFoundCopyWithImpl<$Res>
    implements _$LaneFoundCopyWith<$Res> {
  __$LaneFoundCopyWithImpl(this._self, this._then);

  final _LaneFound _self;
  final $Res Function(_LaneFound) _then;

/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heat = null,Object? lane = null,}) {
  return _then(_LaneFound(
heat: null == heat ? _self.heat : heat // ignore: cast_nullable_to_non_nullable
as Heat,lane: null == lane ? _self.lane : lane // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of LaneFound
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HeatCopyWith<$Res> get heat {
  
  return $HeatCopyWith<$Res>(_self.heat, (value) {
    return _then(_self.copyWith(heat: value));
  });
}
}

// dart format on
