// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RankingRow {

 EventResult get result;/// Nul : non classé (DQ, forfait, hors temps, sans temps).
 int? get rank; int get points; Qualification get qualification; int get seriesNumber; EventRound get round;
/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankingRowCopyWith<RankingRow> get copyWith => _$RankingRowCopyWithImpl<RankingRow>(this as RankingRow, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RankingRow;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankingRow&&(identical(other.result, _this.result) || other.result == _this.result)&&(identical(other.rank, _this.rank) || other.rank == _this.rank)&&(identical(other.points, _this.points) || other.points == _this.points)&&(identical(other.qualification, _this.qualification) || other.qualification == _this.qualification)&&(identical(other.seriesNumber, _this.seriesNumber) || other.seriesNumber == _this.seriesNumber)&&(identical(other.round, _this.round) || other.round == _this.round));
}


@override
int get hashCode {
  final _this = this as RankingRow;
  return Object.hash(runtimeType,_this.result,_this.rank,_this.points,_this.qualification,_this.seriesNumber,_this.round);
}

@override
String toString() {
  final _this = this as RankingRow;
  return 'RankingRow(result: ${_this.result}, rank: ${_this.rank}, points: ${_this.points}, qualification: ${_this.qualification}, seriesNumber: ${_this.seriesNumber}, round: ${_this.round})';
}


}

/// @nodoc
abstract mixin class $RankingRowCopyWith<$Res>  {
  factory $RankingRowCopyWith(RankingRow value, $Res Function(RankingRow) _then) = _$RankingRowCopyWithImpl;
@useResult
$Res call({
 EventResult result, int? rank, int points, Qualification qualification, int seriesNumber, EventRound round
});


$EventResultCopyWith<$Res> get result;

}
/// @nodoc
class _$RankingRowCopyWithImpl<$Res>
    implements $RankingRowCopyWith<$Res> {
  _$RankingRowCopyWithImpl(this._self, this._then);

  final RankingRow _self;
  final $Res Function(RankingRow) _then;

/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? result = null,Object? rank = freezed,Object? points = null,Object? qualification = null,Object? seriesNumber = null,Object? round = null,}) {
  return _then(RankingRow(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as EventResult,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as Qualification,seriesNumber: null == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as int,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as EventRound,
  ));
}
/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventResultCopyWith<$Res> get result {
  
  return $EventResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}


/// Adds pattern-matching-related methods to [RankingRow].
extension RankingRowPatterns on RankingRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankingRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankingRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankingRow value)  $default,){
final _that = this;
switch (_that) {
case _RankingRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankingRow value)?  $default,){
final _that = this;
switch (_that) {
case _RankingRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EventResult result,  int? rank,  int points,  Qualification qualification,  int seriesNumber,  EventRound round)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankingRow() when $default != null:
return $default(_that.result,_that.rank,_that.points,_that.qualification,_that.seriesNumber,_that.round);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EventResult result,  int? rank,  int points,  Qualification qualification,  int seriesNumber,  EventRound round)  $default,) {final _that = this;
switch (_that) {
case _RankingRow():
return $default(_that.result,_that.rank,_that.points,_that.qualification,_that.seriesNumber,_that.round);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EventResult result,  int? rank,  int points,  Qualification qualification,  int seriesNumber,  EventRound round)?  $default,) {final _that = this;
switch (_that) {
case _RankingRow() when $default != null:
return $default(_that.result,_that.rank,_that.points,_that.qualification,_that.seriesNumber,_that.round);case _:
  return null;

}
}

}

/// @nodoc


class _RankingRow implements RankingRow {
  const _RankingRow({required this.result, this.rank, required this.points, required this.qualification, required this.seriesNumber, required this.round});
  

@override final  EventResult result;
/// Nul : non classé (DQ, forfait, hors temps, sans temps).
@override final  int? rank;
@override final  int points;
@override final  Qualification qualification;
@override final  int seriesNumber;
@override final  EventRound round;

/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankingRowCopyWith<_RankingRow> get copyWith => __$RankingRowCopyWithImpl<_RankingRow>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankingRow&&(identical(other.result, result) || other.result == result)&&(identical(other.rank, rank) || other.rank == rank)&&(identical(other.points, points) || other.points == points)&&(identical(other.qualification, qualification) || other.qualification == qualification)&&(identical(other.seriesNumber, seriesNumber) || other.seriesNumber == seriesNumber)&&(identical(other.round, round) || other.round == round));
}


@override
int get hashCode {
    return Object.hash(runtimeType,result,rank,points,qualification,seriesNumber,round);
}

@override
String toString() {
    return 'RankingRow(result: $result, rank: $rank, points: $points, qualification: $qualification, seriesNumber: $seriesNumber, round: $round)';
}


}

/// @nodoc
abstract mixin class _$RankingRowCopyWith<$Res> implements $RankingRowCopyWith<$Res> {
  factory _$RankingRowCopyWith(_RankingRow value, $Res Function(_RankingRow) _then) = __$RankingRowCopyWithImpl;
@override @useResult
$Res call({
 EventResult result, int? rank, int points, Qualification qualification, int seriesNumber, EventRound round
});


@override $EventResultCopyWith<$Res> get result;

}
/// @nodoc
class __$RankingRowCopyWithImpl<$Res>
    implements _$RankingRowCopyWith<$Res> {
  __$RankingRowCopyWithImpl(this._self, this._then);

  final _RankingRow _self;
  final $Res Function(_RankingRow) _then;

/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? result = null,Object? rank = freezed,Object? points = null,Object? qualification = null,Object? seriesNumber = null,Object? round = null,}) {
  return _then(_RankingRow(
result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as EventResult,rank: freezed == rank ? _self.rank : rank // ignore: cast_nullable_to_non_nullable
as int?,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,qualification: null == qualification ? _self.qualification : qualification // ignore: cast_nullable_to_non_nullable
as Qualification,seriesNumber: null == seriesNumber ? _self.seriesNumber : seriesNumber // ignore: cast_nullable_to_non_nullable
as int,round: null == round ? _self.round : round // ignore: cast_nullable_to_non_nullable
as EventRound,
  ));
}

/// Create a copy of RankingRow
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventResultCopyWith<$Res> get result {
  
  return $EventResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc
mixin _$EventRanking {

 CompetitionEvent get event; List<RankingRow> get rows; int get finishedSeries; int get totalSeries; bool get provisional;/// Les séries rattachées classées, dans l'ordre du programme : la fiche
/// d'un athlète y retrouve la série et la course de chaque ligne.
 List<LinkedSeries> get series;
/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventRankingCopyWith<EventRanking> get copyWith => _$EventRankingCopyWithImpl<EventRanking>(this as EventRanking, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as EventRanking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventRanking&&(identical(other.event, _this.event) || other.event == _this.event)&&const DeepCollectionEquality().equals(other.rows, _this.rows)&&(identical(other.finishedSeries, _this.finishedSeries) || other.finishedSeries == _this.finishedSeries)&&(identical(other.totalSeries, _this.totalSeries) || other.totalSeries == _this.totalSeries)&&(identical(other.provisional, _this.provisional) || other.provisional == _this.provisional)&&const DeepCollectionEquality().equals(other.series, _this.series));
}


@override
int get hashCode {
  final _this = this as EventRanking;
  return Object.hash(runtimeType,_this.event,const DeepCollectionEquality().hash(_this.rows),_this.finishedSeries,_this.totalSeries,_this.provisional,const DeepCollectionEquality().hash(_this.series));
}

@override
String toString() {
  final _this = this as EventRanking;
  return 'EventRanking(event: ${_this.event}, rows: ${_this.rows}, finishedSeries: ${_this.finishedSeries}, totalSeries: ${_this.totalSeries}, provisional: ${_this.provisional}, series: ${_this.series})';
}


}

/// @nodoc
abstract mixin class $EventRankingCopyWith<$Res>  {
  factory $EventRankingCopyWith(EventRanking value, $Res Function(EventRanking) _then) = _$EventRankingCopyWithImpl;
@useResult
$Res call({
 CompetitionEvent event, List<RankingRow> rows, int finishedSeries, int totalSeries, bool provisional, List<LinkedSeries> series
});


$CompetitionEventCopyWith<$Res> get event;

}
/// @nodoc
class _$EventRankingCopyWithImpl<$Res>
    implements $EventRankingCopyWith<$Res> {
  _$EventRankingCopyWithImpl(this._self, this._then);

  final EventRanking _self;
  final $Res Function(EventRanking) _then;

/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? event = null,Object? rows = null,Object? finishedSeries = null,Object? totalSeries = null,Object? provisional = null,Object? series = null,}) {
  return _then(EventRanking(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as List<RankingRow>,finishedSeries: null == finishedSeries ? _self.finishedSeries : finishedSeries // ignore: cast_nullable_to_non_nullable
as int,totalSeries: null == totalSeries ? _self.totalSeries : totalSeries // ignore: cast_nullable_to_non_nullable
as int,provisional: null == provisional ? _self.provisional : provisional // ignore: cast_nullable_to_non_nullable
as bool,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as List<LinkedSeries>,
  ));
}
/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}


/// Adds pattern-matching-related methods to [EventRanking].
extension EventRankingPatterns on EventRanking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventRanking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventRanking value)  $default,){
final _that = this;
switch (_that) {
case _EventRanking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventRanking value)?  $default,){
final _that = this;
switch (_that) {
case _EventRanking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CompetitionEvent event,  List<RankingRow> rows,  int finishedSeries,  int totalSeries,  bool provisional,  List<LinkedSeries> series)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventRanking() when $default != null:
return $default(_that.event,_that.rows,_that.finishedSeries,_that.totalSeries,_that.provisional,_that.series);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CompetitionEvent event,  List<RankingRow> rows,  int finishedSeries,  int totalSeries,  bool provisional,  List<LinkedSeries> series)  $default,) {final _that = this;
switch (_that) {
case _EventRanking():
return $default(_that.event,_that.rows,_that.finishedSeries,_that.totalSeries,_that.provisional,_that.series);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CompetitionEvent event,  List<RankingRow> rows,  int finishedSeries,  int totalSeries,  bool provisional,  List<LinkedSeries> series)?  $default,) {final _that = this;
switch (_that) {
case _EventRanking() when $default != null:
return $default(_that.event,_that.rows,_that.finishedSeries,_that.totalSeries,_that.provisional,_that.series);case _:
  return null;

}
}

}

/// @nodoc


class _EventRanking implements EventRanking {
  const _EventRanking({required this.event, required  List<RankingRow> rows, required this.finishedSeries, required this.totalSeries, required this.provisional,  List<LinkedSeries> series = const <LinkedSeries>[]}): _rows = rows,_series = series;
  

@override final  CompetitionEvent event;
 final  List<RankingRow> _rows;
@override List<RankingRow> get rows {
  if (_rows is EqualUnmodifiableListView) return _rows;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rows);
}

@override final  int finishedSeries;
@override final  int totalSeries;
@override final  bool provisional;
/// Les séries rattachées classées, dans l'ordre du programme : la fiche
/// d'un athlète y retrouve la série et la course de chaque ligne.
 final  List<LinkedSeries> _series;
/// Les séries rattachées classées, dans l'ordre du programme : la fiche
/// d'un athlète y retrouve la série et la course de chaque ligne.
@override@JsonKey() List<LinkedSeries> get series {
  if (_series is EqualUnmodifiableListView) return _series;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_series);
}


/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventRankingCopyWith<_EventRanking> get copyWith => __$EventRankingCopyWithImpl<_EventRanking>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventRanking&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other.rows, _rows)&&(identical(other.finishedSeries, finishedSeries) || other.finishedSeries == finishedSeries)&&(identical(other.totalSeries, totalSeries) || other.totalSeries == totalSeries)&&(identical(other.provisional, provisional) || other.provisional == provisional)&&const DeepCollectionEquality().equals(other.series, _series));
}


@override
int get hashCode {
    return Object.hash(runtimeType,event,const DeepCollectionEquality().hash(_rows),finishedSeries,totalSeries,provisional,const DeepCollectionEquality().hash(_series));
}

@override
String toString() {
    return 'EventRanking(event: $event, rows: $rows, finishedSeries: $finishedSeries, totalSeries: $totalSeries, provisional: $provisional, series: $series)';
}


}

/// @nodoc
abstract mixin class _$EventRankingCopyWith<$Res> implements $EventRankingCopyWith<$Res> {
  factory _$EventRankingCopyWith(_EventRanking value, $Res Function(_EventRanking) _then) = __$EventRankingCopyWithImpl;
@override @useResult
$Res call({
 CompetitionEvent event, List<RankingRow> rows, int finishedSeries, int totalSeries, bool provisional, List<LinkedSeries> series
});


@override $CompetitionEventCopyWith<$Res> get event;

}
/// @nodoc
class __$EventRankingCopyWithImpl<$Res>
    implements _$EventRankingCopyWith<$Res> {
  __$EventRankingCopyWithImpl(this._self, this._then);

  final _EventRanking _self;
  final $Res Function(_EventRanking) _then;

/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? event = null,Object? rows = null,Object? finishedSeries = null,Object? totalSeries = null,Object? provisional = null,Object? series = null,}) {
  return _then(_EventRanking(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as CompetitionEvent,rows: null == rows ? _self._rows : rows // ignore: cast_nullable_to_non_nullable
as List<RankingRow>,finishedSeries: null == finishedSeries ? _self.finishedSeries : finishedSeries // ignore: cast_nullable_to_non_nullable
as int,totalSeries: null == totalSeries ? _self.totalSeries : totalSeries // ignore: cast_nullable_to_non_nullable
as int,provisional: null == provisional ? _self.provisional : provisional // ignore: cast_nullable_to_non_nullable
as bool,series: null == series ? _self._series : series // ignore: cast_nullable_to_non_nullable
as List<LinkedSeries>,
  ));
}

/// Create a copy of EventRanking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CompetitionEventCopyWith<$Res> get event {
  
  return $CompetitionEventCopyWith<$Res>(_self.event, (value) {
    return _then(_self.copyWith(event: value));
  });
}
}

// dart format on
